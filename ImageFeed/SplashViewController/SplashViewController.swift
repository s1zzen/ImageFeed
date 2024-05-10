//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 12.04.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private let profileService = ProfileService.shared
    private let profileImage = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let token = oauth2TokenStorage.token
        if let token = token { fetchProfile(token) }
        else { showAuthenticationScreen() }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        let imageView = UIImageView(image: UIImage(named: "launchScreenImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func showAuthenticationScreen() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .overFullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first 
        else {
            assertionFailure("[SplashViewController switchToTabBarController]: Invalid Window Configuration")
            return
        }
        guard let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController 
        else { 
            assertionFailure("[SplashViewController switchToTabBarController]: Invalid TabBar Configuration")
            return }
        tabBarController.selectedIndex = 0
        window.rootViewController = tabBarController
    }
    
}

extension SplashViewController {
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token, completion: ({ [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { 
                assertionFailure("[SplashViewController fetchProfile]: self undefined")
                return
            }
            
            switch result {
            case .success(let profile):
                self.fetchProfileImage(profile.username)
                self.switchToTabBarController()
            case .failure(let error):
                assertionFailure("[SplashViewController fetchProfile]: profile fetching Error - Error: \(error)")
            }
        }))
    }
    
    private func fetchProfileImage(_ username: String) {
        profileImage.fetchProfileImage(username: username, { result in
            switch result {
            case .success(_): break
            case .failure(let error):
                assertionFailure("[SplashViewController fetchProfileImage]: profile image fetching Error - Error: \(error)")
            }
        })
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController) {
        dismiss(animated: true) { [weak self] in
            guard let self = self,
            let token = oauth2TokenStorage.token
            else { 
                assertionFailure("[SplashViewController authViewControllerDelegate Extension]: self or token undefined")
                return
            }
            fetchProfile(token)
        }
    }
    
}

