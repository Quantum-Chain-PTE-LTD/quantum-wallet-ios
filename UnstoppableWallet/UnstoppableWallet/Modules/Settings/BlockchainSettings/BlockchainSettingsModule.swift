import SwiftUI

enum BlockchainSettingsModule {
    static func view() -> some View {
        BlockchainSettingsScreen()
    }
}

private struct BlockchainSettingsScreen: View {
    @StateObject private var viewModel = BlockchainSettingsScreen.makeViewModel()

    var body: some View {
        BlockchainSettingsView(viewModel: viewModel)
    }

    private static func makeViewModel() -> BlockchainSettingsViewModel {
        let core = Core.shared
        return BlockchainSettingsViewModel(
            btcBlockchainManager: core.btcBlockchainManager,
            evmBlockchainManager: core.evmBlockchainManager,
            qvmBlockchainManager: core.qvmBlockchainManager,
            evmSyncSourceManager: core.evmSyncSourceManager,
            qvmSyncSourceManager: core.qvmSyncSourceManager,
            moneroNodeManager: core.moneroNodeManager,
            zanoNodeManager: core.zanoNodeManager,
            marketKit: core.marketKit
        )
    }
}
