import XCTest
@testable import Utilities

final class DefaultBLOBCacheTests: XCTestCase {

    var sut: TemporaryDirectoryBasedBLOBCache!

    override func setUp() async throws {
        sut = .init()
    }

    override func tearDown() async throws {
        sut = nil
    }

    func testInitialization() async {
        let temporaryDirectory = await sut.temporaryDirectory
        XCTAssertNil(temporaryDirectory)
    }

    func testLoadingNonExistentData() async throws {
        let data = try await sut.load(key: "abcdef")
        XCTAssertNil(data)
    }

    func testDeletingNonExistentDataDoesntThrow() async throws {
        try await sut.delete(key: "abcdef")
    }

    func testDeletingAllWhenNotInitializedDoesntThrow() async throws {
        try await sut.deleteAll()
    }

    func testStoringCreatesFile() async throws {
        let data = "some data".data(using: .utf8)!
        try await sut.store(data, key: #function)

        guard let temporaryDirectory = await sut.temporaryDirectory else {
            return XCTFail("temporaryDirectory is nil")
        }
        let contents = try FileManager.default.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: .none)
        XCTAssertEqual(contents.count, 1)
    }

    func testLoadingStoredData() async throws {
        let storedData = "some data".data(using: .utf8)!
        try await sut.store(storedData, key: #function)

        let loadedData = try await sut.load(key: #function)
        XCTAssertEqual(loadedData, storedData)
    }

    func testLoadingDeletedData() async throws {
        let data = "some data".data(using: .utf8)!
        try await sut.store(data, key: #function)
        try await sut.delete(key: #function)

        let loadedData = try await sut.load(key: #function)
        XCTAssertNil(loadedData)
    }

    func testLoadingAfterDeletingAll() async throws {
        let data = "some data".data(using: .utf8)!
        try await sut.store(data, key: #function)
        try await sut.deleteAll()

        let loadedData = try await sut.load(key: #function)
        XCTAssertNil(loadedData)
    }

    func testLoadingOverwrittenData() async throws {
        var storedData = "some data".data(using: .utf8)!
        try await sut.store(storedData, key: #function)
        storedData = "some other data".data(using: .utf8)!
        try await sut.store(storedData, key: #function)

        let loadedData = try await sut.load(key: #function)
        XCTAssertEqual(loadedData, storedData)
    }

    func testThrowingAfterTemporaryDirectoryHasBeenCleanedUp() async throws {
        let storedData = "some data".data(using: .utf8)!
        try await sut.store(storedData, key: #function)

        guard let temporaryDirectory = await sut.temporaryDirectory else {
            return XCTFail("temporaryDirectory is nil")
        }
        try FileManager.default.removeItem(at: temporaryDirectory)

        do {
            try await sut.store(storedData, key: #function)
            XCTFail("unexpected success")
        } catch {
            // ok
        }
        do {
            try await sut.delete(key: #function)
            XCTFail("unexpected success")
        } catch {
            // ok
        }
        do {
            try await sut.deleteAll()
            XCTFail("unexpected success")
        } catch {
            // ok
        }
    }

    func testTemporarDirectoryIsCleanedUp() async throws {
        let storedData = "some data".data(using: .utf8)!
        try await sut.store(storedData, key: #function)

        guard let temporaryDirectory = await sut.temporaryDirectory else {
            return XCTFail("temporaryDirectory is nil")
        }

        sut = nil

        let stillExists = FileManager.default.fileExists(atPath: temporaryDirectory.path)
        XCTAssertFalse(stillExists)
    }
}
