import SwiftUI

enum BlockchainSettingsModule {
    static func view() -> some View {
        let core = Core.shared
        let viewModel = BlockchainSettingsViewModel(
            btcBlockchainManager: core.btcBlockchainManager,
            evmBlockchainManager: core.evmBlockchainManager,
            qvmBlockchainManager: core.qvmBlockchainManager,
            evmSyncSourceManager: core.evmSyncSourceManager,
            qvmSyncSourceManager: core.qvmSyncSourceManager,
            moneroNodeManager: core.moneroNodeManager,
            zanoNodeManager: core.zanoNodeManager,
            marketKit: core.marketKit
        )
        print("[NAV-DEBUG] BlockchainSettingsModule.view() built new VM <\(ObjectIdentifier(viewModel).hashValue)>")
        return BlockchainSettingsView(viewModel: viewModel)
            .onAppear { print("[NAV-DEBUG] BlockchainSettingsView .onAppear") }
            .onDisappear { print("[NAV-DEBUG] BlockchainSettingsView .onDisappear") }
    }
}
