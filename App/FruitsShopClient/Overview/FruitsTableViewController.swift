import os
import UIKit
import Utilities

final class FruitsTableViewController: UITableViewController {

    private let productTableViewCellReuseIdentifier = String(describing: FruitTableViewCell.self)

    private let client: FruitsClient
    private let cache: BLOBCache

    private var products = [Product]()

    init(
        client: FruitsClient,
        cache: BLOBCache
    ) {
        self.client = client
        self.cache = cache
        super.init(nibName: .none, bundle: .none)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Fruits"
        setupTableView()
        refreshControlBegin()
        reload(deleteAllFromCache: false)
    }

    private func setupTableView() {
        tableView.register(FruitTableViewCell.self, forCellReuseIdentifier: productTableViewCellReuseIdentifier)
    }

    private func refreshControlBegin() {
        refreshControl = .init(frame: .zero, primaryAction: .init { _ in
            self.reload(deleteAllFromCache: true)
        })
        refreshControl?.attributedTitle = .init(string: "Refreshing products list ...")
        refreshControl?.beginRefreshing()
        tableView.contentOffset = .init(x: 0, y: -refreshControl!.frame.height)
    }

    private func reload(deleteAllFromCache: Bool) {
        Task {
            do {
                // clear everything
                products = []
                tableView.reloadData()
                if deleteAllFromCache {
                    try await cache.deleteAll()
                }

                // start loading from scratch
                products = try await client.fetchProductList()
                tableView.reloadData()
            } catch {
                // skip proper error handling
                logger.error("\(String(reflecting: error))")
            }
            refreshControl?.endRefreshing()
        }
    }

    // MARK: TableViewDelegate

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 60 }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath) as? FruitTableViewCell,
            cell.thumbnail != .init()
        else { return tableView.deselectRow(at: indexPath, animated: true) }

        let product = products[indexPath.row]
        let detailViewController = FruitDetailViewController(
            product: product,
            cache: cache,
            client: client
        )
        navigationController!.pushViewController(detailViewController, animated: true)
    }

    // MARK: TableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { products.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: productTableViewCellReuseIdentifier, for: indexPath)
        if let cell = cell as? FruitTableViewCell {
            let product = products[indexPath.row]
            cell.product = product
            cell.thumbnail = .init()
            loadThumbnailFor(product, intoCellAt: indexPath)
        }
        return cell
    }

    private func loadThumbnailFor(_ product: Product, intoCellAt indexPath: IndexPath) {
        Task {
            do {
                // try to load thumbnail from cache
                let data = try await cache.load(key: product.thumbnailCacheKey)
                if let data,
                   let cell = tableView.cellForRow(at: indexPath) as? FruitTableViewCell,
                   let thumbnail = UIImage(data: data) {
                    return cell.thumbnail = thumbnail
                }

                // try to load from API and store the image and a thumbnail of the image in cache
                guard let image = try await client.fetchProductImage(productID: product.id) else {
                    // show placeholder
                    if let cell = tableView.cellForRow(at: indexPath) as? FruitTableViewCell {
                        cell.thumbnail = UIImage(systemName: "questionmark.diamond.fill")!
                            .withTintColor(.black, renderingMode: .alwaysOriginal)
                    }
                    return
                }
                let thumbnail = await Task { image.aspectFitThumbnail(size: FruitTableViewCell.thumbnailSize) }.value
                if let data = await Task(operation: { image.jpegData(compressionQuality: 0.9) }).value {
                    try await cache.store(data, key: product.imageCacheKey)
                }
                if let data = await Task(operation: { thumbnail.jpegData(compressionQuality: 0.8) }).value {
                    try await cache.store(data, key: product.thumbnailCacheKey)
                }

                // show thumbnail
                if let cell = tableView.cellForRow(at: indexPath) as? FruitTableViewCell {
                    cell.thumbnail = thumbnail
                }
            } catch {
                // skip proper error handling
                fatalError(String(reflecting: error))
            }
        }
    }
}

private let logger = Logger(category: String(describing: FruitsTableViewController.self))
