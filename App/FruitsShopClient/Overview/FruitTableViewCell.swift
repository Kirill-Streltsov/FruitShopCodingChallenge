import UIKit

final class FruitTableViewCell: UITableViewCell {

    static let thumbnailSize = CGSize(width: 55, height: 50)

    var product = Product(id: -1, name: "", detailsURL: .init(fileURLWithPath: "/")) {
        didSet {
            self.textLabel?.text = "[\(product.id)] \(product.name)"
        }
    }

    var thumbnail = UIImage() {
        didSet {
            self.imageView?.image = thumbnail
            self.imageView?.sizeToFit()
            self.setNeedsLayout()
        }
    }
}
