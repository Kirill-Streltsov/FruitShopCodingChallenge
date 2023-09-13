import UIKit

extension UIImage {
    
    public func aspectFitThumbnail(size: CGSize) -> UIImage {
        
        // The intention of this method is to return an image that is smaller.
        if size.height >= self.size.height, size.width >= self.size.width {
            assertionFailure("The provided size should be smaller then the current image's size.")
        }
        
        // The image should not be cropped. If the aspect ratio of the provided
        // `size` is different than the original image's aspect ratio, the
        // resulting image must have transparent padding.
        
        // e.g. original 100x40
        // ┌──────────────────────────┐
        // │                          │
        // │                          │
        // │                          │
        // │                          │
        // └──────────────────────────┘
        
        // thumbnail 20x20
        // ┌───────┐
        // │-------│
        // │       │
        // │-------│
        // └───────┘
        
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        
        let aspectRatio = min(aspectWidth, aspectHeight)
        let aspectRatioWidth = self.size.width * aspectRatio
        let aspectRationHeight = self.size.height * aspectRatio
                
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: aspectRatioWidth, height: aspectRationHeight))
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        } else {
            return UIImage()
        }
    }
    
}
