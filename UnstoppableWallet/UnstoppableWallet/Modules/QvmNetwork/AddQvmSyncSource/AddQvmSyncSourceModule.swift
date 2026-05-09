import Foundation
import MarketKit
import SwiftUI
import UIKit

enum AddQvmSyncSourceModule {
    static func viewController(blockchainType: BlockchainType) -> UIViewController {
        let service = AddQvmSyncSourceService(blockchainType: blockchainType, qvmSyncSourceManager: Core.shared.qvmSyncSourceManager)
        let viewModel = AddQvmSyncSourceViewModel(service: service)
        let viewController = AddQvmSyncSourceViewController(viewModel: viewModel)

        return ThemeNavigationController(rootViewController: viewController)
    }
}

struct AddQvmSyncSourceSheetView: UIViewControllerRepresentable {
    let blockchainType: BlockchainType

    func makeUIViewController(context _: Context) -> UIViewController {
        AddQvmSyncSourceModule.viewController(blockchainType: blockchainType)
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}