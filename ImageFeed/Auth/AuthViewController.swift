//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сергей Баскаков on 10.04.2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController)
    func showErrorAlert(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private var imageView = UIImageView(image: UIImage(named: "logo_of_unsplash"))
    private var loginButton: UIButton = UIButton()
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        loginButton.setTitle("Войти", for: .normal)
        loginButton.setTitleColor(.ypBlack, for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        loginButton.backgroundColor = .ypWhite
        loginButton.layer.cornerRadius = 16
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(loginButton)
        view.backgroundColor = .ypBlack
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
            
        ])
    }
    
    @objc
    private func didTapLoginButton() {
        let webViewController = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        
        
        webViewController.delegate = self
        
        webViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewController
        
        webViewController.modalPresentationStyle = .overFullScreen
        present(webViewController, animated: true, completion: nil)
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else {
                print("[AuthViewController fetchOAuthToken]: self undefined")
                return
            }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                delegate?.authViewController(self)
            case .failure(_):
                delegate?.showErrorAlert(self)
            }
        }
    }
}


extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        fetchOAuthToken(code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
