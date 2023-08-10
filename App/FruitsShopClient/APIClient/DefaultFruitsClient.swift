import UIKit
import Utilities

public final class DefaultFruitsClient: FruitsClient {

    private let networkService: NetworkService

    public init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func fetchProductList() async throws -> [Product] {
        // Fetch the list of products from the `/products` endpoint (using GET).
        // Don't paginate, get "all" at once (set limit to 100).
        // Note: This is a public API, it may return inconsistent data. But it is
        // supposed to be reset regularly.
        #warning("TODO: remove the following line and return the fetched products")
        return []
    }

    func fetchProductPrice(productDetailsURL: URL) async throws -> Float {
        // Fetch the details of a product from the `/products/{id}` endpoint (using GET).
        // The only interesting value is the "price" value.
        #warning("TODO: remove the following line and return the price of the product")
        return .nan
    }

    func fetchProductImage(productID: Int) async throws -> UIImage? {
        // Fetch the image of a product from the `/products/{id}/image` endpoint (using GET).
        // If a http status code of 404 is received, return `nil`.
        // If an intance of `UIImage` cannot be created from the received data, throw
        // `FruitsClientError.imageCannotBeCreatedFromData`
        #warning("TODO: remove the following line and return the price of the product")
        return .none
    }
}
