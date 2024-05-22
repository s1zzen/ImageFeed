//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 22.05.2024.
//

import Foundation

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func updateAvatar(notification: Notification)
    func setAvatar()
    func getProfile() -> Profile?
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileImage: ProfileImageServiceProtocol
    private let profileService: ProfileServiceProtocol
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImage: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.profileService = profileService
        self.profileImage = profileImage
    }
    
    func updateAvatar(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL) else { return }
        
        view?.prepareImage(url: url)
    }
    
    func setAvatar() {
        if let avatarURL = profileImage.avatarURL,
           let url = URL(string: avatarURL) {
            view?.prepareImage(url: url)
        }
    }
    
    func getProfile() -> Profile? {
        profileService.profile
    }
}
