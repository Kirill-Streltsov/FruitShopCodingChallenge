import Foundation
import os

extension Logger {
    public init(category: String) {
        let subsystem = Bundle.main.bundleIdentifier!
        self.init(subsystem: subsystem, category: category)
    }
}
