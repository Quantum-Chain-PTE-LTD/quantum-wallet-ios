import BigInt
import Qip20Kit
import QvmKit
import Foundation
import HsToolKit
import MarketKit
import RxSwift

class Qip20Adapter: BaseQvmAdapter {
    private static let approveConfirmationsThreshold: Int? = nil
    let qip20Kit: Qip20Kit.Kit
    private let contractAddress: QvmKit.Address
    private let transactionConverter: QvmTransactionConverter

    init(qvmKitWrapper: QvmKitWrapper, contractAddress: String, wallet: Wallet, baseToken: Token, coinManager: CoinManager, qvmLabelManager: QvmLabelManager) throws {
        let address = try QvmKit.Address(hex: contractAddress)
        qip20Kit = try Qip20Kit.Kit.instance(qvmKit: qvmKitWrapper.qvmKit, contractAddress: address)
        self.contractAddress = address

        transactionConverter = QvmTransactionConverter(
            source: wallet.transactionSource, baseToken: baseToken, coinManager: coinManager, blockchainType: qvmKitWrapper.blockchainType,
            userAddress: qvmKitWrapper.qvmKit.address, qvmLabelManager: qvmLabelManager
        )

        super.init(qvmKitWrapper: qvmKitWrapper, decimals: wallet.decimals)
    }
}

// IAdapter

extension Qip20Adapter: IAdapter {
    func start() {
        qip20Kit.start()
    }

    func stop() {
        qip20Kit.stop()
    }

    func refresh() {}
}

extension Qip20Adapter: IBalanceAdapter {
    var balanceState: AdapterState {
        convertToAdapterState(qvmSyncState: qip20Kit.syncState)
    }

    var balanceStateUpdatedObservable: Observable<AdapterState> {
        qip20Kit.syncStateObservable.map { [weak self] in
            self?.convertToAdapterState(qvmSyncState: $0) ?? .syncing(progress: nil, remaining: nil, lastBlockDate: nil)
        }
    }

    var balanceData: BalanceData {
        balanceData(balance: qip20Kit.balance)
    }

    var balanceDataUpdatedObservable: Observable<BalanceData> {
        qip20Kit.balanceObservable.map { [weak self] in
            self?.balanceData(balance: $0) ?? BalanceData(balance: 0)
        }
    }
}

extension Qip20Adapter: ISendQuantumAdapter {
    func transactionData(amount: BigUInt, address: QvmKit.Address) -> TransactionData {
        qip20Kit.transferTransactionData(to: address, value: amount)
    }
}

extension Qip20Adapter: IQrc20Adapter {
    var pendingTransactions: [TransactionRecord] {
        qip20Kit.pendingTransactions().map { transactionConverter.transactionRecord(fromTransaction: $0) }
    }

    func allowance(spenderAddress: QvmKit.Address, defaultBlockParameter: DefaultBlockParameter) async throws -> Decimal {
        let allowanceString = try await qip20Kit.allowance(spenderAddress: spenderAddress, defaultBlockParameter: defaultBlockParameter)

        guard let significand = Decimal(string: allowanceString) else {
            return 0
        }

        return Decimal(sign: .plus, exponent: -decimals, significand: significand)
    }
}

extension Qip20Adapter: IAllowanceAdapter {
    func allowance(spenderAddress: Address, defaultBlockParameter: BlockParameter) async throws -> Decimal {
        let address = try QvmKit.Address(hex: spenderAddress.raw)
        return try await allowance(spenderAddress: address, defaultBlockParameter: .init(defaultBlockParameter))
    }
}

extension Qip20Adapter: IApproveQvmDataProvider {
    func approveSendData(token: Token, spenderAddress: Address, amount: BigUInt) throws -> SendData {
        let address = try QvmKit.Address(hex: spenderAddress.raw)
        let transactionData = qip20Kit.approveTransactionData(spenderAddress: address, amount: amount)

        return .qvm(blockchainType: token.blockchainType, transactionData: transactionData)
    }
}

extension Qip20Adapter: IApproveDataProvider {}

extension QvmKit.DefaultBlockParameter {
    init(_ blockParameter: BlockParameter) {
        switch blockParameter {
        case .pending: self = .pending
        case .latest: self = .latest
        case .earliest: self = .earliest
        case let .blockNumber(value): self = .blockNumber(value: value)
        }
    }
}
