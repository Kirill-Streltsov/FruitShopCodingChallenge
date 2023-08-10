import CryptoKit
import Foundation
import os

public actor TemporaryDirectoryBasedBLOBCache: BLOBCache {

    private let fileManager = FileManager()

    private(set) var temporaryDirectory: URL?

    public init() {}

    deinit {
        do {
            if let temporaryDirectory {
                logger.debug("Deleting temporary cache directory: \(temporaryDirectory.path, privacy: .public)")
                try fileManager.removeItem(at: temporaryDirectory)
            }
        } catch {
            let message = String(reflecting: error)
            logger.error("Failed to clean up the temporary cache directory: \(message, privacy: .public)")
        }
    }

    public func store(_ data: Data, key: String) throws {
        try createTemporaryDirectoryIfNeeded()
        let filename = try sha256hash(key)
        let url = temporaryDirectory!.appendingPathComponent(filename)
        logger.debug("Writing data for key \(key) to: \(url.path, privacy: .public)")
        try data.write(to: url, options: .atomic)
    }

    public func load(key: String) throws -> Data? {
        let filename = try sha256hash(key)
        if let url = temporaryDirectory?.appendingPathComponent(filename), fileManager.fileExists(atPath: url.path) {
            logger.debug("Loading data for key \(key) from: \(url.path, privacy: .public)")
            return try Data(contentsOf: url)
        } else {
            logger.error("No data exists for key: \(key, privacy: .public)")
            return nil
        }
    }

    public func delete(key: String) throws {
        let filename = try sha256hash(key)
        if let url = temporaryDirectory?.appendingPathComponent(filename) {
            logger.debug("Deleting data for key \(key): \(url.path, privacy: .public)")
            try fileManager.removeItem(at: url)
        }
    }

    public func deleteAll() throws {
        if let temporaryDirectory {
            logger.debug("Deleting temporary cache directory: \(temporaryDirectory.path, privacy: .public)")
            try fileManager.removeItem(at: temporaryDirectory)
        }
        temporaryDirectory = .none
    }

    private func createTemporaryDirectoryIfNeeded() throws {
        guard temporaryDirectory == nil else { return }
        logger.debug("Creating temporary cache directory ...")

        // needed as argument `appropriateFor`
        let cachesDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: .none,
            create: false
        )
        temporaryDirectory = try fileManager.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: cachesDirectory,
            create: true
        )
        let path = temporaryDirectory!.path
        logger.debug("Created temporary cache directory: \(path, privacy: .public)")
    }

    private func sha256hash(_ string: String) throws -> String {
        let data = string.data(using: .utf8)!
        let digest = String(describing: CryptoKit.SHA256.hash(data: data))
        let startIndex = digest.index(digest.startIndex, offsetBy: "SHA256 digest: ".count)
        return String(digest[startIndex...])
    }
}

private let logger = Logger(category: String(describing: TemporaryDirectoryBasedBLOBCache.self))
