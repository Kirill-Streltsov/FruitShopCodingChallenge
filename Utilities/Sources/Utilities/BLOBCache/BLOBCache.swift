import Foundation

/// Temporary storage for any type of data.
/// It will be cleared on destruction.
public protocol BLOBCache {
    func store(_ data: Data, key: String) async throws
    func load(key: String) async throws -> Data?
    func delete(key: String) async throws
    func deleteAll() async throws
}
