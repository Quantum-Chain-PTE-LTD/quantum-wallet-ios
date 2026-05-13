import Alamofire
import Foundation
import HsExtensions
import HsToolKit
import ObjectMapper

class AppStateManager {
    static let instance = AppStateManager()

    private let syncInterval: TimeInterval = 60 * 60

    private let localStorage = LocalStorage(userDefaultsStorage: UserDefaultsStorage())
    private let networkManager = NetworkManager()

    // Quantum Wallet: swap is permanently disabled. Mirrors Android b6954986.
    @PostPublished private(set) var swapEnabled: Bool = false

    init() {
        // Persist disabled state so any cached LocalStorage value can't re-enable it.
        localStorage.swapEnabled = false
    }

    func syncIfRequired() {}

    func sync() {}
}

extension AppStateManager {
    struct Response: ImmutableMappable {
        let swapEnabled: Bool

        init(map: Map) throws {
            swapEnabled = try map.value("swap_enabled")
        }
    }
}
