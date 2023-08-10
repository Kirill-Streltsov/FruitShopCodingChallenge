import XCTest
@testable import Utilities

final class URLSessionNetworkServiceTests: XCTestCase {

    var sut: NetworkService!

    func testSharedURLSessionInitialization() throws {
        let networkService = try XCTUnwrap(URLSessionNetworkService.sharedURLSession as? URLSessionNetworkService)
        XCTAssert(networkService.session === URLSession.shared)
    }
}
