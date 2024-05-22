//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 22.05.2024.
//

import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func formatDate(_ date: Date) -> String
    func updateTableView()
    func didLikeButtonTapped(_ index: Int, _ cell: ImagesListCell)
    func getPhotoAtIndex(_ index: Int) -> Photo?
    func willDisplay(indexPath: Int)
    func getPhotosCount() -> Int
    func viewDidLoad()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    private let imagesListService: ImagesListServiceProtocol
    private let UITestMode = "\(ProcessInfo.processInfo.arguments)".contains("XCTestDevices")
    
    init (imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func updateTableView() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTable(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    func getPhotoAtIndex(_ index: Int) -> Photo? {
        photos[index]
    }
    
    func didLikeButtonTapped(_ index: Int, _ cell: ImagesListCell) {
        guard let photo = getPhotoAtIndex(index) else { return }
        
        view?.showUIBlockingProgressHUD()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked, { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                let photos = imagesListService.photos
                self.photos = photos
                cell.setIsLiked(isLiked: !photo.isLiked)
                view?.dismissUIBlockingProgressHUD()
            case .failure(let error):
                view?.dismissUIBlockingProgressHUD()
                view?.showAlert(error: error)
            }
        })
    }
    
    func willDisplay(indexPath: Int) {
        guard indexPath + 1 == photos.count else { return }
        if UITestMode && imagesListService.photos.count >= 10 {
            return
        }
        imagesListService.fetchPhotosNextPage()
    }
    
    func getPhotosCount() -> Int {
        photos.count
    }
}

