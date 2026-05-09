import QvmKit
import Foundation

class QvmSyncSource {
    let name: String
    let rpcSource: RpcSource
    let transactionSource: QvmKit.TransactionSource

    init(name: String, rpcSource: RpcSource, transactionSource: QvmKit.TransactionSource) {
        self.name = name
        self.rpcSource = rpcSource
        self.transactionSource = transactionSource
    }

    var isHttp: Bool {
        switch rpcSource {
        case .http: return true
        default: return false
        }
    }
}

extension QvmSyncSource: Equatable {
    static func == (lhs: QvmSyncSource, rhs: QvmSyncSource) -> Bool {
        lhs.rpcSource.url == rhs.rpcSource.url
    }
}

extension RpcSource {
    var url: URL {
        switch self {
        case let .http(urls, _): return urls[0]
        case let .webSocket(url, _): return url
        }
    }
}
