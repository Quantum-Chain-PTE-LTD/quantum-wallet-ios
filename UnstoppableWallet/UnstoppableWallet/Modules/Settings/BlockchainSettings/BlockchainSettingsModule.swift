import SwiftUI

enum BlockchainSettingsModule {
    static func view() -> some View {
        let viewModel = BlockchainSettingsViewModel(
            btcBlockchainManager: Core.shared.btcBlockchainManager,
            evmBlockchainManager: Core.shared.evmBlockchainManager,
            qvmBlockchainManager: Core.shared.qvmBlockchainManager,
            evmSyncSourceManager: Core.shared.evmSyncSourceManager,
            qvmSyncSourceManager: Core.shared.qvmSyncSourceManager,
            moneroNodeManager: Core.shared.moneroNodeManager,
            zanoNodeManager: Core.shared.zanoNodeManager,
            marketKit: Core.shared.marketKit
        )
        return BlockchainSettingsView(viewModel: viewModel)
    }
}
