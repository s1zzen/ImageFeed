import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var contentImage: UIImageView?
    @IBOutlet var likeButton: UIButton?
    static let reuseIdentifier = "ImagesListCell"
}
