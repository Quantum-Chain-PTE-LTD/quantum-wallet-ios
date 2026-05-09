import Foundation
import MarketKit
import RxSwift

class QvmNetworkViewModel: ObservableObject {
    let blockchain: Blockchain
    private let qvmSyncSourceManager = Core.shared.qvmSyncSourceManager
    private let disposeBag = DisposeBag()

    let defaultSources: [QvmSyncSource]
    @Published var customSources: [QvmSyncSource] = []

    @Published var currentSource: QvmSyncSource {
        didSet {
            saveEnabled = selectedSource != currentSource
        }
    }

    @Published var selectedSource: QvmSyncSource {
        didSet {
            saveEnabled = selectedSource != currentSource
        }
    }

    @Published var saveEnabled = false

    init(blockchain: Blockchain) {
        self.blockchain = blockchain

        defaultSources = qvmSyncSourceManager.defaultSyncSources(blockchainType: blockchain.type)

        let currentSource = qvmSyncSourceManager.syncSource(blockchainType: blockchain.type)
        self.currentSource = currentSource
        selectedSource = currentSource

        subscribe(disposeBag, qvmSyncSourceManager.syncSourcesUpdatedObservable) { [weak self] _ in
            DispatchQueue.main.async { self?.syncCustomSources() }
        }

        syncCustomSources()
    }

    private func syncCustomSources() {
        customSources = qvmSyncSourceManager.customSyncSources(blockchainType: blockchain.type)
    }
}

extension QvmNetworkViewModel {
    func remove(syncSource: QvmSyncSource) {
        qvmSyncSourceManager.delete(syncSource: syncSource, blockchainType: blockchain.type)

        if selectedSource == syncSource, let defaultSource = defaultSources.first {
            selectedSource = defaultSource
        }

        currentSource = qvmSyncSourceManager.syncSource(blockchainType: blockchain.type)
    }

    func save() {
        qvmSyncSourceManager.saveCurrent(syncSource: selectedSource, blockchainType: blockchain.type)
    }
}