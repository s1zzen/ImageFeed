//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 09.05.2024.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

struct ProfileResult: Decodable {
    let username: String
    let first_name: String?
    let last_name: String?
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

final class ProfileService {
    static let shared = ProfileService()
    private init() { }
    
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private let session = URLSession.shared
    
    func makeProfileInfoRequest(token: String) -> URLRequest? {
        guard var components = URLComponents(string: "\(Constants.defaultBaseURL)") else {
            print("[ProfileService makeProfileInfoRequest]: UrlComponents Failed")
            return nil
        }
        components.path = "/me"
        
        guard let url = components.url else {
            print("[ProfileService makeProfileInfoRequest]: Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread, "[ProfileService fetchProfile]: Thread is not Main")
        guard lastToken != token else {
            print("[ProfileService fetchProfile]: token dupe")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileInfoRequest(token: token) else {
            print("[ProfileService fetchProfile]: request error")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = session.objectTask(for: request, completion: { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profile):
                self?.profile = Profile(
                    username: profile.username,
                    name: "\(profile.first_name ?? "") \(profile.last_name ?? "")",
                    loginName: "@\(profile.username)",
                    bio: profile.bio ?? "")
                
                guard let profile = self?.profile else {
                    print("[ProfileService fetchProfile]: Failed to create profile")
                    return
                }
                completion(.success(profile))
                
            case .failure(let error):
                print("[ProfileService fetchProfile]: session error - Error: \(error)")
                completion(.failure(error))
            }
            
            self?.task = nil
            self?.lastToken = nil
        })
        
        task.resume()
    }
    
    func cleanProfile() {
        profile = nil
    }
    
}
