import UIKit

import Kingfisher
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet private weak var dateTitle: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    static let  reuseIdentifier = "ImagesListCell"
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}

extension ImagesListCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        cardImage.kf.cancelDownloadTask()
    }
    
    func configCell(date: String, isLiked: Bool) {
        self.selectionStyle = .none
        cardImage.layer.cornerRadius = 16
        cardImage.layer.masksToBounds = true

        dateTitle.text = date
        setIsLiked(isLiked: isLiked)
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "FavoritesActive") : UIImage(named: "FavoritesNoActive")
        likeButton.imageView?.image = likeImage
    }
}

