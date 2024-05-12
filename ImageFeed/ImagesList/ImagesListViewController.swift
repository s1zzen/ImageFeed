import UIKit

final class ImagesListViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        return tableView
    }()
    
//    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let date = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
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
        
        imagesListService.fetchPhotosNextPage()
        
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showSingleImageSegueIdentifier { // 1
//            guard
//                let viewController = segue.destination as? SingleImageViewController, // 2
//                let indexPath = sender as? IndexPath // 3
//            else {
//                assertionFailure("Invalid segue destination") // 4
//                return
//            }
//            
//            let image = UIImage(named: photosName[indexPath.row]) // 5
//            viewController.image = image // 6
//        } else {
//            super.prepare(for: segue, sender: sender) // 7
//        }
//    }
    
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
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        let url = photos[indexPath.row].thumbImageURL
        
        let isLiked = photos[indexPath.row].isLiked
        
        imageListCell.cardImage.kf.indicatorType = .activity
        imageListCell.cardImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "images_stub")
        ) { _ in
            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)],
                                 with: .automatic)
        }
        
        if let createdAt = photos[indexPath.row].createdAt {
            let date = dateFormatter.string(from: createdAt)
            imageListCell.configCell(date: date, isLiked: isLiked)
        } else {
            imageListCell.configCell(date: "", isLiked: isLiked)
        }
        
        return imageListCell
    }

}

//extension ImagesListViewController {
//    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
//        let likeImage = indexPath.row % 2 == 0 ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
//        
//        cell.dateLabel?.text = dateFormatter.string(from: date)
//        cell.likeButton?.setImage(likeImage, for: .normal)
//        cell.contentImage?.image = UIImage(named: photosName[indexPath.row]) ?? UIImage()
//        let gradientMaskLayer = CAGradientLayer()
//        gradientMaskLayer.frame = cell.gradientView?.bounds ?? CGRectZero
//        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//        gradientMaskLayer.locations = [0.1, 0.9]
//        cell.gradientView?.layer.mask = gradientMaskLayer
//        
//    }
//}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleVC = SingleImageViewController()
        
        let url = photos[indexPath.row].largeImageURL
        singleVC.url = url
        singleVC.modalPresentationStyle = .overFullScreen
        present(singleVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard indexPath.row + 1 == photos.count else { return }
        imagesListService.fetchPhotosNextPage()
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked, { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = imagesListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "\(error)",
                    preferredStyle: .alert
                )
                let action = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}
