import BigInt
import Qip20Kit
import QvmKit
import Foundation
import HsToolKit
import MarketKit
import RxSwift

class QvmTransactionsAdapter: BaseQvmAdapter {
    static let decimal = 18

    private let qvmTransactionSource: QvmKit.TransactionSource
    private let transactionConverter: QvmTransactionConverter
    private let spamManager: SpamManager?

    init(qvmKitWrapper: QvmKitWrapper, source: TransactionSource, baseToken: MarketKit.Token, qvmTransactionSource: QvmKit.TransactionSource, coinManager: CoinManager, spamWrapper: SpamWrapper, qvmLabelManager: QvmLabelManager) {
        self.qvmTransactionSource = qvmTransactionSource
        spamManager = spamWrapper.spamManager(source: source)
        transactionConverter = QvmTransactionConverter(source: source, baseToken: baseToken, coinManager: coinManager, blockchainType: qvmKitWrapper.blockchainType, userAddress: qvmKitWrapper.qvmKit.address, qvmLabelManager: qvmLabelManager)

        super.init(qvmKitWrapper: qvmKitWrapper, decimals: QvmAdapter.decimals)

        initializeSpamManager()
    }

    private func initializeSpamManager() {
        spamManager?.initialize(adapter: self)
    }

    private func tagQuery(token: MarketKit.Token?, filter: TransactionTypeFilter, address: String?) -> TransactionTagQuery {
        var type: TransactionTag.TagType?
        var `protocol`: TransactionTag.TagProtocol?
        var contractAddress: QvmKit.Address?

        if let token {
            switch token.type {
            case .native:
                `protocol` = .native
            case let .qrc20(address):
                if let address = try? QvmKit.Address(hex: address) {
                    `protocol` = .qip20
                    contractAddress = address
                }
            default: ()
            }
        }

        switch filter {
        case .all: ()
        case .incoming: type = .incoming
        case .outgoing: type = .outgoing
        case .swap: type = .swap
        case .approve: type = .approve
        }

        return TransactionTagQuery(type: type, protocol: `protocol`, contractAddress: contractAddress, address: address)
    }
}

extension QvmTransactionsAdapter: ITransactionsAdapter {
    var syncing: Bool {
        qvmKit.transactionsSyncState.syncing
    }

    var syncingObservable: Observable<Void> {
        qvmKit.transactionsSyncStateObservable.map { _ in () }
    }

    var explorerTitle: String {
        qvmTransactionSource.name
    }

    var additionalTokenQueries: [TokenQuery] {
        qvmKit.tagTokens().compactMap { tagToken in
            var tokenType: TokenType?

            switch tagToken.protocol {
            case .native:
                tokenType = .native
            case .qip20:
                if let contractAddress = tagToken.contractAddress {
                    tokenType = .qrc20(address: contractAddress.hex)
                }
            default:
                ()
            }

            guard let tokenType else {
                return nil
            }

            return TokenQuery(blockchainType: qvmKitWrapper.blockchainType, tokenType: tokenType)
        }
    }

    func explorerUrl(transactionHash: String) -> String? {
        qvmTransactionSource.transactionUrl(hash: transactionHash)
    }

    private func handleTransactions(_ transactions: [FullTransaction]) -> [TransactionRecord] {
        let records = transactions.map { transactionConverter.transactionRecord(fromTransaction: $0) }
        spamManager?.update(records: records)
        return records
    }

    func transactionsObservable(token: MarketKit.Token?, filter: TransactionTypeFilter, address: String?) -> Observable<[TransactionRecord]> {
        qvmKit.transactionsObservable(tagQueries: [tagQuery(token: token, filter: filter, address: address?.lowercased())]).map { [weak self] in
            self?.handleTransactions($0) ?? []
        }
    }

    func transactionsSingle(paginationData: String?, token: MarketKit.Token?, filter: TransactionTypeFilter, address: String?, limit: Int) -> Single<[TransactionRecord]> {
        let hash = paginationData?.hs.hexData

        return qvmKit.transactionsSingle(tagQueries: [tagQuery(token: token, filter: filter, address: address?.lowercased())], fromHash: hash, limit: limit)
            .map { [weak self] transactions -> [TransactionRecord] in
                guard !transactions.isEmpty else {
                    return []
                }

                return self?.handleTransactions(transactions) ?? []
            }
    }

    func allTransactionsAfter(paginationData: String?) -> Single<[TransactionRecord]> {
        let hash = paginationData?.hs.hexData
        let transactions = qvmKit.allTransactionsAfter(transactionHash: hash)
        let records = transactions.compactMap { transactionConverter.transactionRecord(fromTransaction: $0) }

        return Single.just(records)
    }

    func rawTransaction(hash _: String) -> String? {
        nil
    }
}
