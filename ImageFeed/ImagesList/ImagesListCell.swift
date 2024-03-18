import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var contentImage: UIImageView?
    @IBOutlet var likeButton: UIButton?
    @IBOutlet var gradientView: UIView?
    static let reuseIdentifier = "ImagesListCell"
    
}

