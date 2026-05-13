import Foundation
import SwiftUI

class AppSceneDelegate: NSObject, UIWindowSceneDelegate {
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let core = Core.instance else { return }
        let windowScene = scene as? UIWindowScene

        core.coverManager.windowScene = windowScene
        core.lockManager.windowScene = windowScene
    }

    func sceneDidEnterBackground(_: UIScene) {
        guard let core = Core.instance else { return }
        core.appManager.didEnterBackground()

        backgroundTask = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
    }

    func sceneWillEnterForeground(_: UIScene) {
        guard let core = Core.instance else { return }
        core.appManager.willEnterForeground()

        if backgroundTask != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
    }

    func sceneDidBecomeActive(_: UIScene) {
        Core.instance?.appManager.didBecomeActive()
    }

    func sceneWillResignActive(_: UIScene) {
        Core.instance?.appManager.willResignActive()
    }
}
