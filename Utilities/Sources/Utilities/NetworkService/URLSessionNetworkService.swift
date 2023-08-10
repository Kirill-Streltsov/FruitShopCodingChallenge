import Foundation

public final class URLSessionNetworkService: NetworkService {

    let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    public func data(from url: URL) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }
}

extension NetworkService where Self == URLSessionNetworkService {
    public static var sharedURLSession: NetworkService {
        Self(session: .shared)
    }
}
