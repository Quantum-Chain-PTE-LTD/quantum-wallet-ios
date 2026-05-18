import SwiftUI

enum BlockchainSettingsModule {
    static func view() -> some View {
        BlockchainSettingsScreen()
    }
}

private struct BlockchainSettingsScreen: View {
    @StateObject private var viewModel = BlockchainSettingsScreen.makeViewModel()

    var body: some View {
        let _ = Self._printChanges()
        BlockchainSettingsView(viewModel: viewModel)
            .onAppear { print("[NAV-DEBUG] BlockchainSettingsView .onAppear") }
            .onDisappear { print("[NAV-DEBUG] BlockchainSettingsView .onDisappear") }
    }

    private static func makeViewModel() -> BlockchainSettingsViewModel {
        print("[NAV-DEBUG] BlockchainSettingsScreen makeViewModel() — VM constructed once via @StateObject")
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
