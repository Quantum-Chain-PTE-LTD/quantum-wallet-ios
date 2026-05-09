import QvmKit
import MarketKit

class QvmContractCreationTransactionRecord: QvmTransactionRecord {
    init(source: TransactionSource, transaction: Transaction, baseToken: Token) {
        super.init(source: source, transaction: transaction, baseToken: baseToken, ownTransaction: true)
    }
}
