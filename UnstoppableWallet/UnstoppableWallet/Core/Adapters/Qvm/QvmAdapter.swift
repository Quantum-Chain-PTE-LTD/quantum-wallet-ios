import BigInt
import Qip20Kit
import QvmKit
import HsToolKit
import RxSwift

class QvmAdapter: BaseQvmAdapter {
    static let decimals = 18

    init(qvmKitWrapper: QvmKitWrapper) {
        super.init(qvmKitWrapper: qvmKitWrapper, decimals: QvmAdapter.decimals)
    }
}

extension QvmAdapter {
    static func clear(except excludedWalletIds: [String]) throws {
        try QvmKit.Kit.clear(exceptFor: excludedWalletIds)
    }
}

// IAdapter
extension QvmAdapter: IAdapter {
    func start() {
        // started via QvmKitManager
    }

    func stop() {
        // stopped via QvmKitManager
    }

    func refresh() {
        // refreshed via QvmKitManager
    }
}

extension QvmAdapter: IBalanceAdapter {
    var balanceState: AdapterState {
        convertToAdapterState(qvmSyncState: qvmKit.syncState)
    }

    var balanceStateUpdatedObservable: Observable<AdapterState> {
        qvmKit.syncStateObservable.map { [weak self] in
            self?.convertToAdapterState(qvmSyncState: $0) ?? .syncing(progress: nil, remaining: nil, lastBlockDate: nil)
        }
    }

    var balanceData: BalanceData {
        balanceData(balance: qvmKit.accountState?.balance)
    }

    var balanceDataUpdatedObservable: Observable<BalanceData> {
        qvmKit.accountStateObservable.map { [weak self] in
            self?.balanceData(balance: $0.balance) ?? BalanceData(balance: 0)
        }
    }
}

extension QvmAdapter: ISendQuantumAdapter {
    func transactionData(amount: BigUInt, address: QvmKit.Address) -> TransactionData {
        qvmKit.transferTransactionData(to: address, value: amount)
    }
}
