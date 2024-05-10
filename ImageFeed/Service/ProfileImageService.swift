//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 09.05.2024.
//

import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
    case decoderError
}

struct UserResult: Codable {
    let profile_image: [String: String]
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let session = URLSession.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private init() {}
    
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private var lastUsername: String?
    private let urlSession = URLSession.shared
    
    func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let token = oauth2TokenStorage.token else {
            
            assertionFailure("[ProfileImageService makeProfileImageRequest]: token is nil")
            return nil
        }
        
        guard var components = URLComponents(string: "\(Constants.defaultBaseURL)") else {
            assertionFailure("[ProfileImageService makeProfileImageRequest]: Failed to create URL")
            return nil
        }
        
        components.path = "/users/\(username)"

        guard let url = components.url else {
            assertionFailure("[ProfileImageService makeProfileImageRequest]: Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImage(username: String, _ completion: @escaping (Result<String, Error>)-> Void) {
        assert(Thread.isMainThread)
        
        guard lastUsername != username else {
            assertionFailure("[ProfileImageService fetchProfileImage]: username dupe")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastUsername = username
        
        guard let request = makeProfileImageRequest(username: username) else {
            assertionFailure("[ProfileImageService fetchProfileImage]: invalid request")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request, completion: { [weak self] (result: Result<UserResult, Error>) in
            
            guard let self = self else {
                assertionFailure("[ProfileImageService fetchProfileImage]:  self undefined")
                return
            }
            
            switch result {
            case .success(let response):
                self.avatarURL = response.profile_image["large"]
                
                guard let avatarURL = self.avatarURL else {
                    assertionFailure("[ProfileImageService fetchProfileImage]: Failed to create profile image")
                    return
                }
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                
                completion(.success(avatarURL))
            case .failure(let error):
                assertionFailure("[ProfileImageService fetchProfileImage]: urlSession Error - Error: \(error)")
                completion(.failure(error))
            }

            self.task = nil
            self.lastUsername = nil
        })
        
        task.resume()
    }
}
