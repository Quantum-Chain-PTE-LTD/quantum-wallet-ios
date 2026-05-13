import QvmKit
import Foundation
import HsToolKit
import MarketKit

class QvmBlockchainManager {
    static let blockchainTypes: [BlockchainType] = [
        .quantumChain
    ]

    private let syncSourceManager: QvmSyncSourceManager
    private let testNetManager: TestNetManager
    private let marketKit: MarketKit.Kit
    private let accountManagerFactory: QvmAccountManagerFactory

    private var qvmKitManagerMap = [BlockchainType: QvmKitManager]()
    private var qvmAccountManagerMap = [BlockchainType: QvmAccountManager]()

    let allBlockchains: [Blockchain]

    private let queue = DispatchQueue(label: "\(AppConfig.label).qvm_blockchain_manager", qos: .userInitiated)

    init(syncSourceManager: QvmSyncSourceManager, testNetManager: TestNetManager, marketKit: MarketKit.Kit, accountManagerFactory: QvmAccountManagerFactory) {
        self.syncSourceManager = syncSourceManager
        self.testNetManager = testNetManager
        self.marketKit = marketKit
        self.accountManagerFactory = accountManagerFactory

        do {
            allBlockchains = try marketKit.blockchains(uids: Self.blockchainTypes.map(\.uid))
        } catch {
            allBlockchains = []
        }
    }

    private func qvmManagers(blockchainType: BlockchainType) throws -> (QvmKitManager, QvmAccountManager) {
        try queue.sync {
            if let qvmKitManager = qvmKitManagerMap[blockchainType], let qvmAccountManager = qvmAccountManagerMap[blockchainType] {
                return (qvmKitManager, qvmAccountManager)
            }

            let qvmKitManager = try QvmKitManager(chain: chain(blockchainType: blockchainType), syncSourceManager: syncSourceManager)
            let qvmAccountManager = accountManagerFactory.qvmAccountManager(blockchainType: blockchainType, qvmKitManager: qvmKitManager)

            qvmKitManagerMap[blockchainType] = qvmKitManager
            qvmAccountManagerMap[blockchainType] = qvmAccountManager

            return (qvmKitManager, qvmAccountManager)
        }
    }
}

extension QvmBlockchainManager {
    func blockchain(chainId: Int) -> Blockchain? {
        allBlockchains.first(where: { (try? chain(blockchainType: $0.type).id) == chainId })
    }

    func blockchain(token: Token) -> Blockchain? {
        allBlockchains.first(where: { token.blockchain == $0 })
    }

    func blockchain(type: BlockchainType) -> Blockchain? {
        allBlockchains.first(where: { $0.type == type })
    }

    func chain(chainId: Int) -> Chain? {
        blockchain(chainId: chainId).flatMap { try? chain(blockchainType: $0.type) }
    }

    func chain(blockchainType: BlockchainType) throws -> Chain {
        switch blockchainType {
        case .quantumChain:
            if testNetManager.testNetEnabled {
                return Chain(
                    id: 11_155_111,
                    coinType: 1,
                    syncInterval: 15,
                    isQIP1559Supported: true
                )
            } else {
                return .quantumChain
            }
        default: throw ChainError.unsupportedBlockchain
        }
    }

    func baseToken(blockchainType: BlockchainType) -> Token? {
        let query = TokenQuery(blockchainType: blockchainType, tokenType: .native)
        return try? marketKit.token(query: query)
    }

    func qvmKitManager(blockchainType: BlockchainType) throws -> QvmKitManager {
        try qvmManagers(blockchainType: blockchainType).0
    }

    func qvmAccountManager(blockchainType: BlockchainType) throws -> QvmAccountManager {
        try qvmManagers(blockchainType: blockchainType).1
    }
}

extension QvmBlockchainManager {
    enum ChainError: Error {
        case unsupportedBlockchain
    }
}
