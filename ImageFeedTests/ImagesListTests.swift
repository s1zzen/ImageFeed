//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Сергей Баскаков on 22.05.2024.
//

@testable import ImageFeed
import XCTest
import ImageFeed
import Foundation

final class ImagesListServiceModel: ImagesListServiceProtocol {
    var photos: [Photo] = []
    
    func fetchPhotosNextPage() {
        photos.append(Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "test", thumbImageURL: URL(string: "test"), largeImageURL: URL(string: "test"), isLiked: true))
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) { }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    func showUIBlockingProgressHUD() { }
    
    func dismissUIBlockingProgressHUD() { }
    
    var presenter: ImagesListPresenterProtocol?
    var updateTableCalled = false
    
    func showAlert(error: Error) { }
    
    func updateTable(oldCount: Int, newCount: Int) {
        updateTableCalled = true
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {

    var view: ImagesListViewControllerProtocol?
    var updateTableCalled = false
    var willDisplayCalled = false
    var viewDidLoadCalled = false
    
    func formatDate(_ date: Date) -> String { return "" }
    
    func updateTableView() {
        updateTableCalled = true
    }
    
    func didLikeButtonTapped(_ index: Int, _ cell: ImagesListCell) { }
    
    func getPhotoAtIndex(_ index: Int) -> Photo? { return nil }
    
    func willDisplay(indexPath: Int) {
        willDisplayCalled = true
    }
    
    func getPhotosCount() -> Int { return 1 }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    
}

final class ImagesListTests: XCTestCase {
    func testFetchPhotosNextPage() throws {
        //given
        let service = ImagesListServiceModel()
        let presenter = ImagesListPresenter(imagesListService: service)
        
        //then
        presenter.viewDidLoad()
        
        //when
        XCTAssertEqual(service.photos.count, 1)
    }
    
    func testUpdateTableCalled() throws {
        //given
        let viewController = ImagesListViewControllerSpy()
        let service = ImagesListServiceModel()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = viewController
        viewController.presenter = presenter
        
        //then
        service.fetchPhotosNextPage()
        presenter.updateTableView()
        
        //when
        XCTAssertTrue(viewController.updateTableCalled)
    }
    
    func testPresenterUpdateTableView() throws {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //then
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self,
            userInfo: [:])
        
        //when
        XCTAssertTrue(presenter.updateTableCalled)
    }
    
    func testWillDisplay() throws {
        //given
        let service = ImagesListServiceModel()
        let presenter = ImagesListPresenter(imagesListService: service)
        
        //then
        service.fetchPhotosNextPage()
        presenter.updateTableView()
        presenter.willDisplay(indexPath: 0)
        
        //when
        XCTAssertEqual(service.photos.count, 2)
    }
    
    func testViewDidLoadCalled() throws {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //then
        _ = viewController.view
        
        //when
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
