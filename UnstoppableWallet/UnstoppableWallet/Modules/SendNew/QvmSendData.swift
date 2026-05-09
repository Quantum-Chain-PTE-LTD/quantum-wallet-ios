import QvmKit
import Foundation
import MarketKit

class QvmSendData: BaseSendQvmData, ISendData {
    let decoration: QvmDecoration
    let transactionData: TransactionData?
    let transactionError: Error?

    init(decoration: QvmDecoration, transactionData: TransactionData?, transactionError: Error?, gasPrice: GasPrice?, qvmFeeData: QvmFeeData?, nonce: Int?) {
        self.decoration = decoration
        self.transactionData = transactionData
        self.transactionError = transactionError

        super.init(gasPrice: gasPrice, qvmFeeData: qvmFeeData, nonce: nonce)
    }

    var feeData: FeeData? {
        qvmFeeData.map { .qvm(qvmFeeData: $0) }
    }

    var canSend: Bool {
        qvmFeeData != nil && transactionError == nil
    }

    var rateCoins: [Coin] {
        decoration.rateCoins
    }

    var customSendButtonTitle: String? {
        decoration.customSendButtonTitle
    }

    func cautions(baseToken: Token) -> [CautionNew] {
        var cautions = [CautionNew]()

        if let transactionError {
            cautions.append(caution(transactionError: transactionError, feeToken: baseToken))
        }

        return cautions
    }

    func cautions(baseToken: Token, currency _: Currency, rates _: [String: Decimal]) -> [CautionNew] {
        cautions(baseToken: baseToken)
    }

    func sections(baseToken: Token, currency: Currency, rates: [String: Decimal]) -> [SendDataSection] {
        let flow = decoration.flowSection(baseToken: baseToken, currency: currency, rates: rates)
        var fields = decoration.fields(baseToken: baseToken, currency: currency, rates: rates)

        if let nonce {
            fields.append(
                .simpleValue(title: "send.confirmation.nonce".localized, value: String(nonce))
            )
        }

        fields.append(contentsOf: feeFields(feeToken: baseToken, currency: currency, feeTokenRate: rates[baseToken.coin.uid]))

        return [flow, .init(fields, isMain: false)].compactMap { $0 }
    }
}
