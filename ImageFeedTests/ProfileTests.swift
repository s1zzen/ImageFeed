//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Сергей Баскаков on 22.05.2024.
//

@testable import ImageFeed
import XCTest
import ImageFeed
import Foundation

final class ProfilePresenterStub: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    func updateAvatar(notification: Notification) { }
    
    func setAvatar() { }
    
    func getProfile() -> Profile? {
        Profile(
            username: "username",
            name: "name",
            loginName: "loginName",
            bio: "bio"
        )
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var didCallUpdateAvatar = false
    var didCallSetAvatar = false
    
    func updateAvatar(notification: Notification) {
        didCallUpdateAvatar = true
    }
    
    func setAvatar() {
        didCallSetAvatar = true
    }
    
    func getProfile() -> ImageFeed.Profile? { nil }
    
    
}

final class ProfileTests: XCTestCase {
    func testGetProfile() {
        //given
        let profilePresenter = ProfilePresenterStub()
        let profileViewController = ProfileViewController()
        profilePresenter.view = profileViewController
        profileViewController.presenter = profilePresenter
        
        //then
        _ = profileViewController.view
        
        //when
        XCTAssertEqual(profileViewController.profile?.username, "username")
        XCTAssertEqual(profileViewController.profile?.name, "name")
        XCTAssertEqual(profileViewController.profile?.loginName, "loginName")
        XCTAssertEqual(profileViewController.profile?.bio, "bio")
    }
    
    func testViewControllerCallsUpdateAvatar() {
        //given
        let profilePresenter = ProfilePresenterSpy()
        let profileViewController = ProfileViewController()
        profilePresenter.view = profileViewController
        profileViewController.presenter = profilePresenter
        
        //then
        _ = profileViewController.view
        NotificationCenter.default
            .post(
                name: ProfileImageService.didChangeNotification,
                object: self,
                userInfo: [:]
            )
        
        //when
        XCTAssertTrue(profilePresenter.didCallUpdateAvatar)
    }
    
    func testViewControllerCallsSetAvatar() {
        //given
        let profilePresenter = ProfilePresenterSpy()
        let profileViewController = ProfileViewController()
        profilePresenter.view = profileViewController
        profileViewController.presenter = profilePresenter
        
        //then
        _ = profileViewController.view
        
        //when
        XCTAssertTrue(profilePresenter.didCallSetAvatar)
    }
}
