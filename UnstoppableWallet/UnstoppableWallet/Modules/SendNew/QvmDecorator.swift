import Qip20Kit
import QvmKit
import MarketKit

struct QvmDecorator {
    private let coinManager = Core.shared.coinManager
    private let qvmLabelManager = Core.shared.qvmLabelManager

    func decorate(baseToken: Token, transactionData: TransactionData, transactionDecoration: TransactionDecoration?) -> QvmDecoration {
        var type: QvmDecoration.`Type`?
        var customSendButtonTitle: String?

        switch transactionDecoration {
        case let decoration as OutgoingDecoration:
            type = .outgoingQvm(
                to: decoration.to,
                value: baseToken.decimalValue(value: decoration.value)
            )

        case let decoration as OutgoingQip20Decoration:
            if let token = try? coinManager.token(query: .init(blockchainType: baseToken.blockchainType, tokenType: .qrc20(address: decoration.contractAddress.hex))) {
                type = .outgoingQip20(
                    to: decoration.to,
                    value: token.decimalValue(value: decoration.value),
                    token: token
                )
            }

        case let decoration as ApproveQip20Decoration:
            if let token = try? coinManager.token(query: .init(blockchainType: baseToken.blockchainType, tokenType: .qrc20(address: decoration.contractAddress.hex))) {
                type = .approveQip20(
                    spender: decoration.spender,
                    value: token.decimalValue(value: decoration.value),
                    token: token
                )

                let isRevoke = decoration.value == 0

                customSendButtonTitle = isRevoke ? "send.confirmation.slide_to_revoke".localized : "send.confirmation.slide_to_approve".localized
            }

        default:
            ()
        }

        return QvmDecoration(
            type: type ?? .unknown(
                to: transactionData.to,
                value: baseToken.decimalValue(value: transactionData.value),
                input: transactionData.input,
                method: qvmLabelManager.methodLabel(input: transactionData.input)
            ),
            customSendButtonTitle: customSendButtonTitle
        )
    }
}
