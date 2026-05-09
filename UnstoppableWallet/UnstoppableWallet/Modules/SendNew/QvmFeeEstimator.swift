import BigInt
import QvmKit
import MarketKit

struct QvmFeeEstimator {
    private static let surchargePercent: Double = 10

    func estimateFee(qvmKitWrapper: QvmKitWrapper, transactionData: TransactionData, gasPriceData: QvmGasPriceData, predefinedGasLimit: Int? = nil) async throws -> QvmFeeData {
        let qvmKit = qvmKitWrapper.qvmKit
        let gasLimit: Int
        let gasPrice = gasPriceData.userDefined

        if let predefinedGasLimit {
            gasLimit = predefinedGasLimit
        } else {
            do {
                gasLimit = try await qvmKit.fetchEstimateGas(transactionData: transactionData, gasPrice: gasPrice)
            } catch {
                gasLimit = try await qvmKit.fetchEstimateGas(transactionData: transactionData)
            }
        }

        let txAmount = transactionData.value
        let feeAmount = BigUInt(gasLimit * gasPrice.max)
        var totalAmount = txAmount + feeAmount

        let qvmBalance = qvmKit.accountState?.balance ?? 0

        let surchargedGasLimit: Int

        if !transactionData.input.isEmpty, qvmBalance > totalAmount {
            let remainingBalance = qvmBalance - totalAmount

            var additionalGasLimit = Int(Double(gasLimit) / 100.0 * Self.surchargePercent)

            if remainingBalance < BigUInt(additionalGasLimit * gasPrice.max) {
                additionalGasLimit = Int((remainingBalance / BigUInt(gasPrice.max)).description) ?? 0
            }

            surchargedGasLimit = gasLimit + additionalGasLimit
        } else {
            surchargedGasLimit = gasLimit
        }

        return .init(gasLimit: gasLimit, surchargedGasLimit: surchargedGasLimit)
    }
}
