//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 12.04.2024.
//

import Foundation
enum OAuthErrors: Error {
    case requestUrlError
    case invalidRequest
    case codeDupe
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init(){}
    
    private func makeRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: Constants.grandType),
            
        ]
        
        guard let urlRequest = urlComponents?.url
        else {
            assertionFailure("[makeRequest]: url Error")
            return nil }
        var request = URLRequest(url: urlRequest)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            assertionFailure("[fetchOAuthToken]: code dupe Error")
            handler(.failure(OAuthErrors.codeDupe))
            return
        }
        
        task?.cancel()
        
        lastCode = code
        
        guard let request = makeRequest(code: code) else {
            assertionFailure("[fetchOAuthToken]: makeRequest Error")
            handler(.failure(OAuthErrors.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result{
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(OAuth2TokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = response.accessToken
                    handler(.success(response.accessToken))
                } catch {
                    assertionFailure("[fetchOAuthToken task]: Decode Error - Error: \(error)")
                    handler(.failure(error))
                }
            case .failure(let er):
                assertionFailure("[fetchOAuthToken task]: URLSession Error - Error: \(er)")
                handler(.failure(er))
            }
            
        }
        task.resume()
    }
}
