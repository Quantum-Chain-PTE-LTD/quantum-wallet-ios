import QvmKit
import Foundation
import MarketKit
import RxRelay
import RxSwift

class QvmSyncSourceManager {
    private let testNetManager: TestNetManager
    private let blockchainSettingsStorage: BlockchainSettingsStorage
    private let qvmSyncSourceStorage: QvmSyncSourceStorage

    private let syncSourceRelay = PublishRelay<BlockchainType>()
    private let syncSourcesUpdatedRelay = PublishRelay<BlockchainType>()

    init(testNetManager: TestNetManager, blockchainSettingsStorage: BlockchainSettingsStorage, qvmSyncSourceStorage: QvmSyncSourceStorage) {
        self.testNetManager = testNetManager
        self.blockchainSettingsStorage = blockchainSettingsStorage
        self.qvmSyncSourceStorage = qvmSyncSourceStorage
    }

    private func defaultTransactionSource(blockchainType: BlockchainType) -> QvmKit.TransactionSource {
        switch blockchainType {
        case .quantumChain: return .quantumBlockscout(apiKeys: AppConfig.etherscanKeys)
        default: fatalError("Non-supported QVM blockchain")
        }
    }
}

extension QvmSyncSourceManager {
    var syncSourceObservable: Observable<BlockchainType> {
        syncSourceRelay.asObservable()
    }

    var syncSourcesUpdatedObservable: Observable<BlockchainType> {
        syncSourcesUpdatedRelay.asObservable()
    }

    func defaultSyncSources(blockchainType: BlockchainType) -> [QvmSyncSource] {
        switch blockchainType {
        case .quantumChain:
            if testNetManager.testNetEnabled {
                return []
            } else {
                return [
                    QvmSyncSource(
                        name: "Qraft",
                        rpcSource: .quantumQraftHttp(),
                        transactionSource: defaultTransactionSource(blockchainType: blockchainType)
                    )
                ]
            }
        default:
            return []
        }
    }

    func customSyncSources(blockchainType: BlockchainType?) -> [QvmSyncSource] {
        do {
            let records: [QvmSyncSourceRecord]
            if let blockchainType {
                records = try qvmSyncSourceStorage.records(blockchainTypeUid: blockchainType.uid)
            } else {
                records = try qvmSyncSourceStorage.getAll()
            }

            return records.compactMap { record in
                let blockchainType = BlockchainType(uid: record.blockchainTypeUid)
                guard let url = URL(string: record.url), let scheme = url.scheme else {
                    return nil
                }

                let rpcSource: RpcSource

                switch scheme {
                case "http", "https": rpcSource = .http(urls: [url], auth: record.auth)
                case "ws", "wss": rpcSource = .webSocket(url: url, auth: record.auth)
                default: return nil
                }

                return QvmSyncSource(
                    name: url.host ?? "",
                    rpcSource: rpcSource,
                    transactionSource: defaultTransactionSource(blockchainType: blockchainType)
                )
            }
        } catch {
            return []
        }
    }

    func allSyncSources(blockchainType: BlockchainType) -> [QvmSyncSource] {
        defaultSyncSources(blockchainType: blockchainType) + customSyncSources(blockchainType: blockchainType)
    }

    func syncSource(blockchainType: BlockchainType) -> QvmSyncSource {
        let syncSources = allSyncSources(blockchainType: blockchainType)

        if let urlString = blockchainSettingsStorage.qvmSyncSourceUrl(blockchainType: blockchainType),
           let syncSource = syncSources.first(where: { $0.rpcSource.url.absoluteString == urlString })
        {
            return syncSource
        }

        return syncSources[0]
    }

    func httpSyncSource(blockchainType: BlockchainType) -> QvmSyncSource? {
        let syncSources = allSyncSources(blockchainType: blockchainType)

        if let urlString = blockchainSettingsStorage.qvmSyncSourceUrl(blockchainType: blockchainType),
           let syncSource = syncSources.first(where: { $0.rpcSource.url.absoluteString == urlString }), syncSource.isHttp
        {
            return syncSource
        }

        return syncSources.first { $0.isHttp }
    }

    func saveCurrent(syncSource: QvmSyncSource, blockchainType: BlockchainType) {
        blockchainSettingsStorage.save(qvmSyncSourceUrl: syncSource.rpcSource.url.absoluteString, blockchainType: blockchainType)
        syncSourceRelay.accept(blockchainType)
    }

    func saveSyncSource(blockchainType: BlockchainType, url: URL, auth: String?) {
        let record = QvmSyncSourceRecord(
            blockchainTypeUid: blockchainType.uid,
            url: url.absoluteString,
            auth: auth
        )

        try? qvmSyncSourceStorage.save(record: record)

        if let syncSource = customSyncSources(blockchainType: blockchainType).first(where: { $0.rpcSource.url == url }) {
            saveCurrent(syncSource: syncSource, blockchainType: blockchainType)
        }

        syncSourcesUpdatedRelay.accept(blockchainType)
    }

    func delete(syncSource: QvmSyncSource, blockchainType: BlockchainType) {
        let isCurrent = self.syncSource(blockchainType: blockchainType) == syncSource

        try? qvmSyncSourceStorage.delete(blockchainTypeUid: blockchainType.uid, url: syncSource.rpcSource.url.absoluteString)

        if isCurrent {
            syncSourceRelay.accept(blockchainType)
        }

        syncSourcesUpdatedRelay.accept(blockchainType)
    }
}

extension QvmSyncSourceManager {
    var customSources: [QvmSyncSourceRecord] {
        (try? qvmSyncSourceStorage.getAll()) ?? []
    }

    var selectedSources: [SelectedSource] {
        QvmBlockchainManager
            .blockchainTypes
            .map { type in
                SelectedSource(
                    blockchainTypeUid: type.uid,
                    url: syncSource(blockchainType: type).rpcSource.url.absoluteString
                )
            }
    }
}

extension QvmSyncSourceManager {
    func decrypt(sources: [CustomSyncSource], passphrase: String) throws -> [QvmSyncSourceRecord] {
        try sources.map { source in
            let auth = try source.auth
                .flatMap { try $0.decrypt(passphrase: passphrase) }
                .flatMap { String(data: $0, encoding: .utf8) }

            return QvmSyncSourceRecord(
                blockchainTypeUid: source.blockchainTypeUid,
                url: source.url,
                auth: auth
            )
        }
    }

    func encrypt(sources: [QvmSyncSourceRecord], passphrase: String) throws -> [CustomSyncSource] {
        try sources.map { source in
            let crypto = try source.auth
                .flatMap { $0.isEmpty ? nil : $0 }
                .flatMap { $0.data(using: .utf8) }
                .flatMap { try BackupCrypto.encrypt(data: $0, passphrase: passphrase) }

            return CustomSyncSource(
                blockchainTypeUid: source.blockchainTypeUid,
                url: source.url,
                auth: crypto
            )
        }
    }
}

extension QvmSyncSourceManager {
    func restore(selected: [SelectedSource], custom: [QvmSyncSourceRecord]) {
        var blockchainTypes = Set<BlockchainType>()
        for source in custom {
            blockchainTypes.insert(BlockchainType(uid: source.blockchainTypeUid))
            try? qvmSyncSourceStorage.save(record: source)
        }

        for source in selected {
            let blockchainType = BlockchainType(uid: source.blockchainTypeUid)
            if let syncSource = allSyncSources(blockchainType: blockchainType)
                .first(where: { $0.rpcSource.url.absoluteString == source.url })
            {
                saveCurrent(syncSource: syncSource, blockchainType: blockchainType)
            }
        }

        for blockchainType in blockchainTypes {
            syncSourcesUpdatedRelay.accept(blockchainType)
        }
    }
}

extension QvmSyncSourceManager {
    struct SelectedSource: Codable {
        let blockchainTypeUid: String
        let url: String

        enum CodingKeys: String, CodingKey {
            case blockchainTypeUid = "blockchain_type_id"
            case url
        }
    }

    struct CustomSyncSource: Codable {
        let blockchainTypeUid: String
        let url: String
        let auth: BackupCrypto?

        enum CodingKeys: String, CodingKey {
            case blockchainTypeUid = "blockchain_type_id"
            case url
            case auth
        }
    }

    struct SyncSourceBackup: Codable {
        let selected: [SelectedSource]
        let custom: [CustomSyncSource]
    }
}
