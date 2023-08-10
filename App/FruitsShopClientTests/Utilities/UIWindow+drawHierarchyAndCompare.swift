import os
import UIKit
import XCTest

extension UIWindow {

    func drawnHierarchyIsEqualTo(
        snapshot: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> Bool {
        guard ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] == "iPhone 14" else {
            throw SnapshotError.wrongDeviceSimulator // must be iPhone 14
        }

        let bundle = Bundle.module
        let snapshot = try XCTUnwrap(bundle.url(forResource: snapshot, withExtension: "png"), file: file, line: line)

        try await Task.sleep(nanoseconds: 500_000_000)

        let format = UIGraphicsImageRendererFormat()
        format.scale = screen.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        let actualImageData = try XCTUnwrap(UIImage(data: XCTUnwrap(image.pngData()))?.pngData())
        let expectedImageData = try XCTUnwrap(UIImage(data: Data(contentsOf: snapshot))?.pngData())

        if actualImageData == expectedImageData {
            return true
        } else {
            let filename = snapshot.deletingPathExtension().lastPathComponent
            let actualSnapshot = snapshot.deletingLastPathComponent().appendingPathComponent("\(filename)-expected.png")
            logger.debug("Actual snapshot written to \(actualSnapshot.path, privacy: .public)")
            try actualImageData.write(to: actualSnapshot)
            return false
        }
    }

    enum SnapshotError: Error {
        /// The snapshot tests have to be performed with the same simultor model every time in order to be comparable.
        /// Please select iPhone 14.
        case wrongDeviceSimulator
    }
}

private let logger = Logger(category: "UIWindow+drawnHierarchyIsEqualTo")
