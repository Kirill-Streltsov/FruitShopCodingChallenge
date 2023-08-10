import XCTest
@testable import FruitsShopClient

@MainActor
final class FruitsTableViewControllerTests: XCTestCase {

    var sut: FruitsTableViewController!
    var networkServiceMock: NetworkServiceMock!
    var window: UIWindow!

    override func setUp() async throws {
        networkServiceMock = .init()
        networkServiceMock.results = [
            .init(string: "https://api.predic8.de/shop/v2/products?start=1&limit=100")!: .success((mockResponse, .init())),
            .init(string: "https://api.predic8.de/shop/v2/products/17/image")!: .success((patternImage(0).pngData()!, .init())),
            .init(string: "https://api.predic8.de/shop/v2/products/16/image")!: .success((patternImage(1).pngData()!, .init())),
            .init(string: "https://api.predic8.de/shop/v2/products/15/image")!: .success((patternImage(2).pngData()!, .init())),
        ]
        sut = .init(
            client: DefaultFruitsClient(networkService: networkServiceMock),
            cache: VolatileMemoryCache()
        )
        window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow ?? .init()
        window.rootViewController = UINavigationController(rootViewController: sut)
        window.makeKeyAndVisible()
    }

    override func tearDown() async throws {
        sut = nil
        networkServiceMock = nil
    }

    func testSnapshot() async throws {
        let isEqual = try await window.drawnHierarchyIsEqualTo(snapshot: "FruitsTableViewController")
        XCTAssertTrue(isEqual)
    }

    var mockResponse: Data {
        """
        {
          "meta": {
            "count": 17,
            "start": 1,
            "limit": 3,
            "next_link": "/shop/v2/products?start=4&limit=3"
          },
          "products": [
            {
              "id": 17,
              "name": "Pineapple-Slice",
              "self_link": "/shop/v2/products/17"
            },
            {
              "id": 16,
              "name": "Pineapple",
              "self_link": "/shop/v2/products/16"
            },
            {
              "id": 15,
              "name": "Physalis",
              "self_link": "/shop/v2/products/15"
            }
          ]
        }
        """.data(using: .utf8)!
    }

    func patternImage(_ index: Int) -> UIImage {
        let image = UIImage(named: "pattern\(index)", in: .module, with: .none)
        return .init(cgImage: image!.cgImage!, scale: 1, orientation: image!.imageOrientation)
    }
}
