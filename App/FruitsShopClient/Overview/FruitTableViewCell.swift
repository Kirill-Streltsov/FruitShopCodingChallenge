import UIKit

final class FruitTableViewCell: UITableViewCell {

    static let thumbnailSize = CGSize(width: 55, height: 50)

    var product = Product(id: -1, name: "", detailsURL: .init(fileURLWithPath: "/")) {
        didSet {
            #warning("TODO: display the product's id in brackets and its name")
            // e.g. [1] Banana
        }
    }

    var thumbnail = UIImage() {
        didSet {
            #warning("TODO: display the thumbnail")
        }
    }
}
