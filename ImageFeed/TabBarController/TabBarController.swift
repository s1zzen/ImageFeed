//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 09.05.2024.
//
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        
        super.viewDidLoad()
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .ypBlack
        self.tabBar.tintColor = .ypWhite
        self.tabBar.standardAppearance = appearance
        
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
