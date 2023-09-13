import UIKit

final class FruitDetailView:  UIView {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    private var imageViewAspectRatioConstraint: NSLayoutConstraint?

    var productImage = UIImage() {
        didSet {
            if let imageViewAspectRatioConstraint {
                imageView.removeConstraint(imageViewAspectRatioConstraint)
            }

            imageView.image = productImage
            let ratio = productImage.size.width / productImage.size.height
            imageViewAspectRatioConstraint = .init(item: imageView!, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: ratio, constant: 0)
            imageViewAspectRatioConstraint?.isActive = true
        }
    }

    var price = "" {
        didSet { priceLabel.text = price }
    }

    var productDescription = "" {
        didSet { descriptionLabel.text = productDescription }
    }
}
