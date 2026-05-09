import QvmKit
import Foundation
import MarketKit

class QvmSendHandler {
    let baseToken: Token
    private let transactionData: TransactionData
    private let qvmKitWrapper: QvmKitWrapper
    private let decorator = QvmDecorator()
    private let qvmFeeEstimator = QvmFeeEstimator()

    init(baseToken: Token, transactionData: TransactionData, qvmKitWrapper: QvmKitWrapper) {
        self.baseToken = baseToken
        self.transactionData = transactionData
        self.qvmKitWrapper = qvmKitWrapper
    }
}

extension QvmSendHandler: ISendHandler {
    var expirationDuration: Int? {
        10
    }

    func sendData(transactionSettings: TransactionSettings?) async throws -> ISendData {
        if !qvmKitWrapper.allowed {
            throw AppError.quantum(reason: .notAllowed)
        }

        let gasPriceData = transactionSettings?.qvmGasPriceData
        var qvmFeeData: QvmFeeData?
        var transactionError: Error?
        var transactionData = transactionData

        if let gasPriceData {
            let qvmBalance = qvmKitWrapper.qvmKit.accountState?.balance ?? 0

            do {
                if transactionData.input.isEmpty, transactionData.value == qvmBalance {
                    let stubTransactionData = TransactionData(to: transactionData.to, value: 1, input: transactionData.input)
                    let stubFeeData = try await qvmFeeEstimator.estimateFee(qvmKitWrapper: qvmKitWrapper, transactionData: stubTransactionData, gasPriceData: gasPriceData)
                    let totalFee = stubFeeData.totalFee(gasPrice: gasPriceData.userDefined)

                    qvmFeeData = stubFeeData
                    let value = transactionData.value > totalFee ? transactionData.value - totalFee : 0
                    transactionData = TransactionData(to: transactionData.to, value: value, input: transactionData.input)

                    if transactionData.value == 0 {
                        throw AppError.quantum(reason: .insufficientBalanceWithFee)
                    }
                } else {
                    let _qvmFeeData = try await qvmFeeEstimator.estimateFee(qvmKitWrapper: qvmKitWrapper, transactionData: transactionData, gasPriceData: gasPriceData)
                    let totalFee = _qvmFeeData.totalFee(gasPrice: gasPriceData.userDefined)

                    qvmFeeData = _qvmFeeData

                    if qvmBalance < totalFee {
                        throw AppError.quantum(reason: .insufficientBalanceWithFee)
                    }
                }
            } catch {
                transactionError = error
            }
        }

        let transactionDecoration = qvmKitWrapper.qvmKit.decorate(transactionData: transactionData)
        let decoration = decorator.decorate(baseToken: baseToken, transactionData: transactionData, transactionDecoration: transactionDecoration)

        return QvmSendData(
            decoration: decoration,
            transactionData: transactionData,
            transactionError: transactionError,
            gasPrice: gasPriceData?.userDefined,
            qvmFeeData: qvmFeeData,
            nonce: transactionSettings?.nonce
        )
    }

    func send(data: ISendData) async throws {
        guard let data = data as? QvmSendData else {
            throw SendError.invalidData
        }

        guard let transactionData = data.transactionData else {
            throw SendError.noTransactionData
        }

        guard let gasPrice = data.gasPrice else {
            throw SendError.noGasPrice
        }

        guard let gasLimit = data.qvmFeeData?.surchargedGasLimit else {
            throw SendError.noGasLimit
        }

        _ = try await qvmKitWrapper.send(
            transactionData: transactionData,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            nonce: data.nonce
        )
    }
}

extension QvmSendHandler {
    enum SendError: Error {
        case invalidData
        case noGasPrice
        case noGasLimit
        case noTransactionData
    }
}

extension QvmSendHandler {
    static func instance(blockchainType: BlockchainType, transactionData: TransactionData) -> QvmSendHandler? {
        guard let baseToken = try? Core.shared.coinManager.token(query: .init(blockchainType: blockchainType, tokenType: .native)) else {
            return nil
        }

        guard let qvmKitWrapper = try? Core.shared.qvmBlockchainManager.qvmKitManager(blockchainType: blockchainType).qvmKitWrapper else {
            return nil
        }

        return QvmSendHandler(
            baseToken: baseToken,
            transactionData: transactionData,
            qvmKitWrapper: qvmKitWrapper
        )
    }
}
