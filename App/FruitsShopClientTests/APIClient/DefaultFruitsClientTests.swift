import XCTest
@testable import FruitsShopClient

final class DefaultFruitsClientTests: XCTestCase {

    var sut: DefaultFruitsClient!
    var networkServiceMock: NetworkServiceMock!

    override func setUp() async throws {
        networkServiceMock = .init()
        sut = .init(networkService: networkServiceMock)
    }

    override func tearDown() async throws {
        sut = nil
        networkServiceMock = nil
    }

    // Test the implementation

    func skip() {}
}
