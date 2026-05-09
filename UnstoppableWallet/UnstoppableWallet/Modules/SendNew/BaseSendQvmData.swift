import QvmKit
import Foundation
import MarketKit

class BaseSendQvmData {
    let gasPrice: GasPrice?
    let qvmFeeData: QvmFeeData?
    let nonce: Int?

    init(gasPrice: GasPrice?, qvmFeeData: QvmFeeData?, nonce: Int?) {
        self.gasPrice = gasPrice
        self.qvmFeeData = qvmFeeData
        self.nonce = nonce
    }

    func feeFields(feeToken: Token, currency: Currency, feeTokenRate: Decimal?) -> [SendField] {
        let amountData = qvmFeeData.flatMap { $0.totalAmountData(gasPrice: gasPrice, feeToken: feeToken, currency: currency, feeTokenRate: feeTokenRate) }

        return [
            .fee(
                title: ComponentInformedTitle("fee_settings.network_fee".localized, info: .fee),
                amountData: amountData
            ),
        ]
    }

    func caution(transactionError: Error, feeToken: Token) -> CautionNew {
        let title: String
        let text: String

        if case let AppError.quantum(reason) = transactionError.convertedError {
            switch reason {
            case .insufficientBalanceWithFee:
                title = "fee_settings.errors.insufficient_balance".localized
                text = "quantum_transaction.error.insufficient_balance_with_fee".localized(feeToken.coin.code)
            case let .executionReverted(message):
                title = "fee_settings.errors.unexpected_error".localized
                text = message
            case .lowerThanBaseGasLimit:
                title = "fee_settings.errors.low_max_fee".localized
                text = "fee_settings.errors.low_max_fee.info".localized
            case .nonceAlreadyInBlock:
                title = "fee_settings.errors.nonce_already_in_block".localized
                text = "quantum_transaction.error.nonce_already_in_block".localized
            case .replacementTransactionUnderpriced:
                title = "fee_settings.errors.replacement_transaction_underpriced".localized
                text = "quantum_transaction.error.replacement_transaction_underpriced".localized
            case .transactionUnderpriced:
                title = "fee_settings.errors.transaction_underpriced".localized
                text = "quantum_transaction.error.transaction_underpriced".localized
            case .tipsHigherThanMaxFee:
                title = "fee_settings.errors.tips_higher_than_max_fee".localized
                text = "quantum_transaction.error.tips_higher_than_max_fee".localized
            case .notAllowed:
                title = "quantum_transaction.error.title".localized
                text = "quantum_transaction.error.not_allowed".localized
            }
        } else {
            title = "quantum_transaction.error.title".localized
            text = transactionError.convertedError.smartDescription
        }

        return CautionNew(title: title, text: text, type: .error)
    }
}
