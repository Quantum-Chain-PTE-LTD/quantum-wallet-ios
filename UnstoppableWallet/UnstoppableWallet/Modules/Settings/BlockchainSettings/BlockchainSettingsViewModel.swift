import BitcoinCore
import Combine
import MarketKit
import RxRelay
import RxSwift

class BlockchainSettingsViewModel: ObservableObject {
    private let btcBlockchainManager: BtcBlockchainManager
    private let evmBlockchainManager: EvmBlockchainManager
    private let qvmBlockchainManager: QvmBlockchainManager
    private let evmSyncSourceManager: EvmSyncSourceManager
    private let qvmSyncSourceManager: QvmSyncSourceManager
    private let moneroNodeManager: MoneroNodeManager
    private let zanoNodeManager: ZanoNodeManager
    private let marketKit: MarketKit.Kit
    private let disposeBag = DisposeBag()

    @Published var evmItems: [Item] = []
    @Published var qvmItems: [Item] = []
    @Published var btcItems: [Item] = []
    @Published var tronItem: Item?

    init(btcBlockchainManager: BtcBlockchainManager, evmBlockchainManager: EvmBlockchainManager, qvmBlockchainManager: QvmBlockchainManager, evmSyncSourceManager: EvmSyncSourceManager, qvmSyncSourceManager: QvmSyncSourceManager, moneroNodeManager: MoneroNodeManager, zanoNodeManager: ZanoNodeManager, marketKit: MarketKit.Kit) {
        self.btcBlockchainManager = btcBlockchainManager
        self.evmBlockchainManager = evmBlockchainManager
        self.qvmBlockchainManager = qvmBlockchainManager
        self.evmSyncSourceManager = evmSyncSourceManager
        self.qvmSyncSourceManager = qvmSyncSourceManager
        self.moneroNodeManager = moneroNodeManager
        self.zanoNodeManager = zanoNodeManager
        self.marketKit = marketKit

        subscribe(MainScheduler.instance, disposeBag, btcBlockchainManager.restoreModeUpdatedObservable) { [weak self] _ in self?.syncBtcItems() }
        subscribe(MainScheduler.instance, disposeBag, evmSyncSourceManager.syncSourceObservable) { [weak self] blockchainType in
            if blockchainType == .tron {
                self?.syncTronItem()
            } else {
                self?.syncEvmItems()
            }
        }
        subscribe(MainScheduler.instance, disposeBag, qvmSyncSourceManager.syncSourceObservable) { [weak self] _ in self?.syncQvmItems() }
        subscribe(MainScheduler.instance, disposeBag, moneroNodeManager.nodeObservable) { [weak self] _ in self?.syncBtcItems() }
        subscribe(MainScheduler.instance, disposeBag, zanoNodeManager.nodeObservable) { [weak self] _ in self?.syncBtcItems() }

        syncBtcItems()
        syncQvmItems()
        syncEvmItems()
        syncTronItem()
    }

    private func syncBtcItems() {
        var items = btcBlockchainManager.allBlockchains
            .map { blockchain in
                let restoreMode = btcBlockchainManager.restoreMode(blockchainType: blockchain.type)
                return Item(blockchain: blockchain, type: .btc(restoreMode: restoreMode))
            }

        if let blockchain = try? marketKit.blockchain(uid: BlockchainType.monero.uid) {
            let moneroNode = moneroNodeManager.node(blockchainType: .monero)
            items.append(.init(blockchain: blockchain, type: .monero(node: moneroNode)))
        }

        if let blockchain = try? marketKit.blockchain(uid: BlockchainType.zano.uid) {
            let zanoNode = zanoNodeManager.node(blockchainType: .zano)
            items.append(.init(blockchain: blockchain, type: .zano(node: zanoNode)))
        }

        btcItems = items.sorted { $0.blockchain.type.order < $1.blockchain.type.order }
    }

    private func syncEvmItems() {
        evmItems = evmBlockchainManager.allBlockchains
            .map { blockchain in
                let syncSource = evmSyncSourceManager.syncSource(blockchainType: blockchain.type)
                return Item(blockchain: blockchain, type: .evm(syncSource: syncSource))
            }
            .sorted { $0.blockchain.type.order < $1.blockchain.type.order }
    }

    private func syncQvmItems() {
        qvmItems = qvmBlockchainManager.allBlockchains
            .map { blockchain in
                let syncSource = qvmSyncSourceManager.syncSource(blockchainType: blockchain.type)
                return Item(blockchain: blockchain, type: .qvm(syncSource: syncSource))
            }
            .sorted { $0.blockchain.type.order < $1.blockchain.type.order }
    }

    private func syncTronItem() {
        guard let blockchain = try? marketKit.blockchain(uid: BlockchainType.tron.uid) else { return }
        let syncSource = evmSyncSourceManager.syncSource(blockchainType: .tron)
        tronItem = Item(blockchain: blockchain, type: .evm(syncSource: syncSource))
    }
}

extension BlockchainSettingsViewModel {
    struct Item {
        let blockchain: Blockchain
        let type: ItemType

        var title: String {
            switch type {
            case let .evm(syncSource): return syncSource.name
            case let .qvm(syncSource): return syncSource.name
            case let .btc(restoreMode): return restoreMode.title(blockchain: blockchain)
            case let .monero(node): return node.name
            case let .zano(node): return node.name
            }
        }
    }

    enum ItemType {
        case evm(syncSource: EvmSyncSource)
        case qvm(syncSource: QvmSyncSource)
        case btc(restoreMode: BtcRestoreMode)
        case monero(node: MoneroNode)
        case zano(node: ZanoNode)
    }
}
