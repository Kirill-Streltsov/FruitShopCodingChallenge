import Foundation

public protocol NetworkService {
    func data(from url: URL) async throws -> (Data, URLResponse)
}
