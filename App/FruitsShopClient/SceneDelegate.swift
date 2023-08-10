import UIKit
import Utilities

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let windowScene = scene as! UIWindowScene
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        defer {
            window.makeKeyAndVisible()
        }

        #if DEBUG
        guard !ProcessInfo.processInfo.environment.keys.contains("runningAsUnitTestsHostApplication") else {
            return window.rootViewController = .init()
        }
        #endif

        let rootViewController = FruitsTableViewController(
            client: DefaultFruitsClient(networkService: .sharedURLSession),
            cache: TemporaryDirectoryBasedBLOBCache()
        )
        window.rootViewController = UINavigationController(rootViewController: rootViewController)
    }
}
