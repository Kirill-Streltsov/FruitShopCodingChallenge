import XCTest
@testable import FruitsShopClient

@MainActor
final class FruitDetailViewControllerTests: XCTestCase {

    var sut: FruitDetailViewController!
    var networkServiceMock: NetworkServiceMock!
    var window: UIWindow!

    override func setUp() async throws {
        networkServiceMock = .init()
        sut = .init(
            product: .init(id: .max, name: "Lorem Ipsum Dolor Sit Amet", detailsURL: .init(string: "https://example.org")!),
            cache: VolatileMemoryCache(),
            client: DefaultFruitsClient(networkService: networkServiceMock)
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
        let isEqual = try await window.drawnHierarchyIsEqualTo(snapshot: "FruitDetailViewController")
        XCTAssertTrue(isEqual)
    }
}
