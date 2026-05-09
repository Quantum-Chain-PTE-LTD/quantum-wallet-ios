import BigInt
import QvmKit
import Foundation
import HsToolKit
import RxSwift

class BaseQvmAdapter {
    static let confirmationsThreshold = 12

    let qvmKitWrapper: QvmKitWrapper
    let decimals: Int

    init(qvmKitWrapper: QvmKitWrapper, decimals: Int) {
        self.qvmKitWrapper = qvmKitWrapper
        self.decimals = decimals
    }

    var qvmKit: QvmKit.Kit {
        qvmKitWrapper.qvmKit
    }

    func balanceDecimal(kitBalance: BigUInt?, decimals: Int) -> Decimal {
        guard let kitBalance else {
            return 0
        }

        guard let significand = Decimal(string: kitBalance.description) else {
            return 0
        }

        return Decimal(sign: .plus, exponent: -decimals, significand: significand)
    }

    func convertToAdapterState(qvmSyncState: QvmKit.SyncState) -> AdapterState {
        switch qvmSyncState {
        case .synced: return .synced
        case let .notSynced(error): return .notSynced(error: error.convertedError.localizedDescription)
        case .syncing: return .syncing(progress: nil, remaining: nil, lastBlockDate: nil)
        }
    }

    var isMainNet: Bool {
        qvmKitWrapper.qvmKit.chain.isMainNet
    }

    func balanceData(balance: BigUInt?) -> BalanceData {
        BalanceData(balance: balanceDecimal(kitBalance: balance, decimals: decimals))
    }
}

// IAdapter
extension BaseQvmAdapter {
    var statusInfo: [(String, Any)] {
        qvmKit.statusInfo()
    }

    var debugInfo: String {
        qvmKit.debugInfo
    }
}

// ITransactionsAdapter
extension BaseQvmAdapter {
    var lastBlockInfo: LastBlockInfo? {
        qvmKit.lastBlockHeight.map { LastBlockInfo(height: $0, timestamp: nil) }
    }

    var lastBlockUpdatedObservable: Observable<Void> {
        qvmKit.lastBlockHeightObservable.map { _ in () }
    }
}

extension BaseQvmAdapter: IDepositAdapter {
    var receiveAddress: DepositAddress {
        DepositAddress(qvmKit.receiveAddress.qip55)
    }
}
