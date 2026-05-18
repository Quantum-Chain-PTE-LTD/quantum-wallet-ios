import Foundation
import HsExtensions

class AppStateManager {
    static let instance = AppStateManager()

    // Quantum Wallet: swap is permanently disabled. Mirrors Android b6954986.
    @PostPublished private(set) var swapEnabled: Bool = false

    private init() {}

    func syncIfRequired() {}

    func sync() {}
}
