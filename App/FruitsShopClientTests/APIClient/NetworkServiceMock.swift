@testable import FruitsShopClient
import Utilities
import Foundation

final class NetworkServiceMock: NetworkService {

    typealias MockedResult = Result<(Data, URLResponse), Error>
    var results = [URL: MockedResult]()

    func data(from url: URL) async throws -> (Data, URLResponse) {
        switch results[url] {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        case .none:
            return (.init(), HTTPURLResponse(url: url, statusCode: 404, httpVersion: .none, headerFields: .none)!)
        }
    }
}
