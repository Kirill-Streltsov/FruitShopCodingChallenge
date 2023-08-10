import os
import UIKit
import Utilities

final class FruitDetailViewController: UIViewController {

    let product: Product
    let cache: BLOBCache
    let client: FruitsClient

    init(product: Product, cache: BLOBCache, client: FruitsClient) {
        self.product = product
        self.cache = cache
        self.client = client
        super.init(nibName: .none, bundle: .none)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let view = view as! FruitDetailView
        view.productDescription = try! String(contentsOf: Bundle.main.url(forResource: "LoremIpsum", withExtension: "txt")!)
        title = "[\(product.id)] " + product.name

        Task {
            await loadImageFromCacheAndShow()
            await fetchAndShowPrice()
        }
    }

    private func loadImageFromCacheAndShow() async {
        let view = view as! FruitDetailView
        lazy var placeholderImage = UIImage(systemName: "questionmark.diamond.fill")!
            .withTintColor(.black, renderingMode: .alwaysOriginal)

        do {
            guard
                let data = try await cache.load(key: product.imageCacheKey),
                let image = UIImage(data: data)
            else { return view.productImage = placeholderImage }
            view.productImage = image
        } catch {
            logger.error("Failed to retrieve image from cache: \(String(reflecting: error), privacy: .public)")
            view.productImage = placeholderImage
        }
    }

    private func fetchAndShowPrice() async {
        let view = view as! FruitDetailView
        view.price = "…"

        do {
            let price = try await client.fetchProductPrice(productDetailsURL: product.detailsURL)
            let numberFormatter = NumberFormatter()
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.numberStyle = .currency
            numberFormatter.currencySymbol = "€"
            view.price = numberFormatter.string(from: price as NSNumber)!
        } catch {
            view.price = "?"
        }
    }
}

private let logger = Logger(category: .init(describing: FruitDetailViewController.self))
