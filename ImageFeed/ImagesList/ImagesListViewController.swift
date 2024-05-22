import Kingfisher
import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func showAlert(error: Error)
    func updateTable(oldCount: Int, newCount: Int)
    func showUIBlockingProgressHUD()
    func dismissUIBlockingProgressHUD()
}

final class ImagesListViewController: UIViewController,
                                      ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?

    //MARK: - Private Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        return tableView
    }()
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
        configureTableView()
        
        presenter?.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(UINib(nibName: "ImagesListCell", bundle: nil), forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
    

    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated(notification:)),
            name: ImagesListService.didChangeNotification,
            object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ImagesListService.didChangeNotification,
            object: nil)
    }
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc
    private func updateTableViewAnimated(notification: Notification) {
        presenter?.updateTableView()
    }
    
    func updateTable(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func showUIBlockingProgressHUD() {
        UIBlockingProgressHUD.show()
    }
    
    func dismissUIBlockingProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }
}

//MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let singleViewController = SingleImageViewController()
        
        guard let url = presenter?.getPhotoAtIndex(indexPath.row)?.largeImageURL else { return }
        singleViewController.url = url
        singleViewController.modalPresentationStyle = .overFullScreen
        present(singleViewController, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let photo = presenter?.getPhotoAtIndex(indexPath.row)?.size else { return CGFloat() }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        presenter?.willDisplay(indexPath: indexPath.row)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let presenter =  presenter else { return 0 }
        return presenter.getPhotosCount()
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        guard let photo = presenter?.getPhotoAtIndex(indexPath.row) else { return UITableViewCell() }
        let url = photo.thumbImageURL
        
        let isLiked = photo.isLiked
        
        imageListCell.cardImage.kf.indicatorType = .activity
        imageListCell.cardImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "images_stub")
        ) { _ in
            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)],
                                 with: .automatic)
        }
        
        if let createdAt = photo.createdAt,
           let date = presenter?.formatDate(createdAt) {
            imageListCell.configCell(date: date, isLiked: isLiked)
        } else {
            imageListCell.configCell(date: "", isLiked: isLiked)
        }
        
        return imageListCell
    }
}

//MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didLikeButtonTapped(indexPath.row, cell)
    }
    func showAlert(error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "\(error)",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

