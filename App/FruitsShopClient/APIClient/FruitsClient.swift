import UIKit

protocol FruitsClient {
    func fetchProductList() async throws -> [Product]
    func fetchProductPrice(productDetailsURL: URL) async throws -> Float
    func fetchProductImage(productID: Int) async throws -> UIImage?
}
