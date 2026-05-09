import Foundation
import MarketKit

class QvmAccountManagerFactory {
    private let accountManager: AccountManager
    private let walletManager: WalletManager
    private let restoreStateManager: RestoreStateManager
    private let marketKit: MarketKit.Kit

    init(accountManager: AccountManager, walletManager: WalletManager, restoreStateManager: RestoreStateManager, marketKit: MarketKit.Kit) {
        self.accountManager = accountManager
        self.walletManager = walletManager
        self.restoreStateManager = restoreStateManager
        self.marketKit = marketKit
    }
}

extension QvmAccountManagerFactory {
    func qvmAccountManager(blockchainType: BlockchainType, qvmKitManager: QvmKitManager) -> QvmAccountManager {
        QvmAccountManager(
            blockchainType: blockchainType,
            accountManager: accountManager,
            walletManager: walletManager,
            marketKit: marketKit,
            qvmKitManager: qvmKitManager,
            restoreStateManager: restoreStateManager
        )
    }
}
