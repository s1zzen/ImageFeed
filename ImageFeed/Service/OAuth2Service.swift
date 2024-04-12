//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 12.04.2024.
//

import Foundation
enum OAuthErrors: Error {
    case requestUrlError
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
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
        
        guard let urlRequest = urlComponents?.url else {return nil }
        print(urlRequest.absoluteString)
        var request = URLRequest(url: urlRequest)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeRequest(code: code) else { return }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result{
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuth2TokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = response.accessToken
                    handler(.success(response.accessToken))
                } catch { handler(.failure(error)) }
            case .failure(let er):
                handler(.failure(er))
            }
            
        }
        task.resume()
    }
}
