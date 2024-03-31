import UIKit

final class ProfileViewController: UIViewController {
    private var profileImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginLabel: UILabel!
    private var descriptionLabel: UILabel!

    private var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImageView()
        setupNameLabel()
        setupForwardButton()
        setupLoginLabel()
        setupDescriptionLabel()
    }
    
    private func setupProfileImageView() {
        let profileImage = UIImage(named: "profileImage") ?? UIImage(systemName: "person.crop.circle.fill")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        self.profileImageView = imageView
    }
    
    private func setupNameLabel() {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = UIColor.ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ])
        self.nameLabel = label
    }
    
    private func setupLoginLabel() {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        self.loginLabel = label
    }
    
    private func setupDescriptionLabel() {
        let label = UILabel()
        label.text = "Hello, World!"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ])
        self.descriptionLabel = label
    }
    
    private func setupForwardButton() {
        let button = UIButton.systemButton(
            with: UIImage(named: "logout_button") ?? UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(didTapLogoutButton)
        )
        button.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: profileImageView.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        self.logoutButton = button
        
    }
    @objc
    private func didTapLogoutButton(){}
}
