import Foundation
import Utilities

actor VolatileMemoryCache: BLOBCache {

    var cache = [String: Data]()

    func store(_ data: Data, key: String) async throws {
        cache[key] = data
    }

    func load(key: String) async throws -> Data? {
        cache[key]
    }

    func delete(key: String) async throws {
        cache.removeValue(forKey: key)
    }

    func deleteAll() async throws {
        cache.removeAll()
    }
}
