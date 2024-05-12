//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 12.05.2024.
//

import Foundation
import UIKit

enum ImageListServiceError: Error {
    case invalidRequest
    case decoderError
    case taskNil
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: URL?
    let largeImageURL: URL?
    let isLiked: Bool
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoResult: Decodable {
    let id: String
    let created_at: String
    let width: Int
    let height: Int
    let liked_by_user: Bool
    let description: String?
    let urls: UrlsResult
}

final class ImagesListService {
    private let dateFormatter = ISO8601DateFormatter()
    
    static let shared = ImagesListService()
    private init() { }
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let oAuthToken = OAuth2TokenStorage.shared
    
    //    MARK: - Private functions
    private func makeImageListRequest(page: Int) -> URLRequest? {
        guard var components = URLComponents(string: "\(Constants.defaultBaseURL)") else {
            print("Failed to create URL")
            return nil
        }
        components.path = "/photos"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components.url else {
            print("Failed to create URL")
            return nil
        }
        
        guard let token = oAuthToken.token else {
            print("Failed to get token from storage")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard var components = URLComponents(string: "\(Constants.defaultBaseURL)") else {
            print("Failed to create URL")
            return nil
        }
        components.path = "/photos/\(photoId)/like"
        
        guard let url = components.url else {
            print("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        guard let token = oAuthToken.token else {
            print("Failed to get token from storage")
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "DELETE" : "POST"
        return request
    }
    
    //    MARK: - Public functions
    func fetchPhotosNextPage() {
        
        guard task == nil else {
            print("\(ImageListServiceError.taskNil)")
            return
        }
        
        let nextPageNumber = (lastLoadedPage ?? 0) + 1
        guard let request = makeImageListRequest(page: nextPageNumber) else {
            print("\(ImageListServiceError.invalidRequest)")
            return
        }
        
        let task = urlSession.objectTask(for: request, completion: { [weak self] (result : Result<[PhotoResult], Error>) in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let photosResult):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    for photoResult in photosResult {
                        let photo = Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: dateFormatter.date(from: photoResult.created_at),
                            welcomeDescription: photoResult.description,
                            thumbImageURL: URL(string: photoResult.urls.thumb),
                            largeImageURL: URL(string: photoResult.urls.full),
                            isLiked: photoResult.liked_by_user
                        )
                        self.lastLoadedPage = nextPageNumber
                        self.photos.append(photo)
                    }
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["Photo": self.photos])
                }
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage] failure - \(error)")
            }
            self.task = nil
        })
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            completion(.failure(ImageListServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request, completion: { [weak self] (result: Result<Data, Error>) in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if let index = self.photos.firstIndex(where: {$0.id == photoId}) {
                        let photo = self.photos[index]
                        
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(Void()))
                }
            case .failure(let error):
                print("[ImagesListService.changeLike] failure - \(error)")
                completion(.failure(error))
            }
        })
        task.resume()
    }
    
    func clearPhotos() {
        photos = []
    }
}

