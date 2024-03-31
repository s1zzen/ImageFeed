import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let date = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier { // 1
            guard
                let viewController = segue.destination as? SingleImageViewController, // 2
                let indexPath = sender as? IndexPath // 3
            else {
                assertionFailure("Invalid segue destination") // 4
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row]) // 5
            viewController.image = image // 6
        } else {
            super.prepare(for: segue, sender: sender) // 7
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let likeImage = indexPath.row % 2 == 0 ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        
        cell.dateLabel?.text = dateFormatter.string(from: date)
        cell.likeButton?.setImage(likeImage, for: .normal)
        cell.contentImage?.image = UIImage(named: photosName[indexPath.row]) ?? UIImage()
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = cell.gradientView?.bounds ?? CGRectZero
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientMaskLayer.locations = [0.1, 0.9]
        cell.gradientView?.layer.mask = gradientMaskLayer
        
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return .zero }
        
        let cellWidth = tableView.contentSize.width - 32
        let cellHeight = cellWidth / image.size.width * image.size.height
        return cellHeight + 8
    }
}
