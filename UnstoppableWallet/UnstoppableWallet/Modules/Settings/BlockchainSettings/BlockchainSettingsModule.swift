import SwiftUI

enum BlockchainSettingsModule {
    static func view() -> some View {
        print("[NAV-DEBUG] BlockchainSettingsModule.view() begin")
        let core = Core.shared
        print("[NAV-DEBUG]  - btcBlockchainManager")
        let btc = core.btcBlockchainManager
        print("[NAV-DEBUG]  - evmBlockchainManager")
        let evm = core.evmBlockchainManager
        print("[NAV-DEBUG]  - qvmBlockchainManager")
        let qvm = core.qvmBlockchainManager
        print("[NAV-DEBUG]  - evmSyncSourceManager")
        let evmSync = core.evmSyncSourceManager
        print("[NAV-DEBUG]  - qvmSyncSourceManager")
        let qvmSync = core.qvmSyncSourceManager
        print("[NAV-DEBUG]  - moneroNodeManager")
        let monero = core.moneroNodeManager
        print("[NAV-DEBUG]  - zanoNodeManager")
        let zano = core.zanoNodeManager
        print("[NAV-DEBUG]  - marketKit")
        let market = core.marketKit
        print("[NAV-DEBUG]  - building viewModel")
        let viewModel = BlockchainSettingsViewModel(
            btcBlockchainManager: btc,
            evmBlockchainManager: evm,
            qvmBlockchainManager: qvm,
            evmSyncSourceManager: evmSync,
            qvmSyncSourceManager: qvmSync,
            moneroNodeManager: monero,
            zanoNodeManager: zano,
            marketKit: market
        )
        print("[NAV-DEBUG] BlockchainSettingsModule.view() end")
        return BlockchainSettingsView(viewModel: viewModel)
            .onAppear { print("[NAV-DEBUG] BlockchainSettingsView .onAppear") }
            .onDisappear { print("[NAV-DEBUG] BlockchainSettingsView .onDisappear") }
    }
}
