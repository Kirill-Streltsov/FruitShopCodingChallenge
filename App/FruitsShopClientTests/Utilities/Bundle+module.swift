import Foundation

extension Bundle {
    static var module: Bundle {
        .init(for: Dummy.self)
    }
}

private class Dummy {}
