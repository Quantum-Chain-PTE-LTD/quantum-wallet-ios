import Foundation
import MarketKit

class AddQvmSyncSourceService {
    let blockchainType: BlockchainType
    private let qvmSyncSourceManager: QvmSyncSourceManager

    private var urlString: String = ""
    private var basicAuth: String = ""

    init(blockchainType: BlockchainType, qvmSyncSourceManager: QvmSyncSourceManager) {
        self.blockchainType = blockchainType
        self.qvmSyncSourceManager = qvmSyncSourceManager
    }
}

extension AddQvmSyncSourceService {
    func set(urlString: String) {
        self.urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func set(basicAuth: String) {
        self.basicAuth = basicAuth.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func save() throws {
        guard let url = URL(string: urlString), let scheme = url.scheme, url.host != nil else {
            throw UrlError.invalid
        }

        guard ["https", "wss"].contains(scheme) else {
            throw UrlError.invalid
        }

        let existingSources = qvmSyncSourceManager.allSyncSources(blockchainType: blockchainType)

        guard !existingSources.contains(where: { $0.rpcSource.url == url }) else {
            throw UrlError.alreadyExists
        }

        let auth = basicAuth.isEmpty ? nil : basicAuth

        qvmSyncSourceManager.saveSyncSource(blockchainType: blockchainType, url: url, auth: auth)
    }
}

extension AddQvmSyncSourceService {
    enum UrlError: Error {
        case invalid
        case alreadyExists
    }
}