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
        guard let token = token else {
            showAuthenticationScreen()
            return
        }
        fetchProfile(token)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        let imageView = UIImageView(image: UIImage(named: "LaunchScreen"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func showAuthenticationScreen() {
        let authVC = AuthViewController()
        authVC.delegate = self
        authVC.modalPresentationStyle = .overFullScreen
        present(authVC, animated: true, completion: nil)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first 
        else {
            assertionFailure("Invalid Window Configuration")
            return
        }
        guard let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController 
        else { assertionFailure("Invalid TabBar Configuration")
            return }
        tabBarController.selectedIndex = 1
        window.rootViewController = tabBarController
    }
    
}

extension SplashViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showAuthenticationScreenSegueIdentifier {
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let viewController = navigationController.viewControllers[0] as? AuthViewController
//            else { assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
//                return }
//            viewController.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token, completion: ({ [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.fetchProfileImage(profile.username)
                self.switchToTabBarController()
            case .failure(let error):
                print(error)
            }
        }))
    }
    
    private func fetchProfileImage(_ username: String) {
        profileImage.fetchProfileImage(username: username, { result in
            switch result {
            case .success(_): break
            case .failure(let error):
                print(error)
            }
        })
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController) {
        dismiss(animated: true) { [weak self] in
            guard let self = self,
            let token = oauth2TokenStorage.token
            else { return }
            fetchProfile(token)
        }
    }
    
}

