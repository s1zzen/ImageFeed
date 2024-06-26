import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    var profile: Profile? { get set }
    func prepareImage(url: URL)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
        
    var presenter: ProfilePresenterProtocol?
    var profile: Profile?
    
    private let profileService = ProfileService.shared
    private let profileImage = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private let gradientAnimation = GradientAnimation.shared
    private let gradient = CAGradientLayer()
    private var animationLayers: [CALayer] = []
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = UIColor.ypWhite
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
         let label = UILabel()
         label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
         label.textColor = UIColor.ypWhite
         return label
     }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "logout_button") ?? UIImage(systemName: "ipad.and.arrow.forward"), for: .normal)
        button.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
        button.accessibilityIdentifier = "ProfileLogoutButton"
        button.addTarget(self, action: #selector(handleLogoutButtonTap), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLogoutButtonTap() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Вы уверенны что хотите выйти?",
            preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.profileLogoutService.logout()
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
        }
        let noAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
        presenter?.setAvatar()
        profile = presenter?.getProfile()
        guard let profile else {
            return
        }
        setupLabels(profile)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard isViewLoaded else { return }
        presenter?.updateAvatar(notification: notification)
    }
    
    private func setupViews() {
        [profileImageView,
         nameLabel,
         loginLabel,
         descriptionLabel,
         logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        [profileImageView, nameLabel, loginLabel, descriptionLabel].forEach { $0.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true }
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
        
        gradientAnimation.addGradient(view: profileImageView, width: 70, height: 70, cornerRadius: 35)
        gradientAnimation.addGradient(view: nameLabel, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height, cornerRadius: 13)
        gradientAnimation.addGradient(view: loginLabel, width: loginLabel.intrinsicContentSize.width, height: loginLabel.intrinsicContentSize.height, cornerRadius: 8)
        gradientAnimation.addGradient(view: descriptionLabel, width: descriptionLabel.intrinsicContentSize.width, height: descriptionLabel.intrinsicContentSize.height, cornerRadius: 8)
    }
    
    private func setupLabels(_ profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func prepareImage(url: URL) {
        profileImageView.kf.setImage(
            with: url,
            completionHandler: { [weak self] _ in
                guard let self = self else { return }
                self.gradientAnimation.removeFromSuperLayer(views: [self.profileImageView, self.nameLabel, self.loginLabel, self.descriptionLabel])
            }
        )
    }
}

