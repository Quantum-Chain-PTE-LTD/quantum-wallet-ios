import BigInt
import Qip20Kit
import QvmKit
import Foundation
import MarketKit
import TfaKit

class QvmTransactionConverter {
    private let coinManager: CoinManager
    private let blockchainType: BlockchainType
    private let userAddress: QvmKit.Address
    private let qvmLabelManager: QvmLabelManager
    private let source: TransactionSource
    private let baseToken: MarketKit.Token

    init(source: TransactionSource, baseToken: MarketKit.Token, coinManager: CoinManager, blockchainType: BlockchainType, userAddress: QvmKit.Address, qvmLabelManager: QvmLabelManager) {
        self.coinManager = coinManager
        self.blockchainType = blockchainType
        self.userAddress = userAddress
        self.qvmLabelManager = qvmLabelManager
        self.source = source
        self.baseToken = baseToken
    }

    private func convertAmount(amount: BigUInt, decimals: Int, sign: FloatingPointSign) -> Decimal {
        guard let significand = Decimal(string: amount.description), significand != 0 else {
            return 0
        }

        return Decimal(sign: sign, exponent: -decimals, significand: significand)
    }

    private func baseAppValue(value: BigUInt, sign: FloatingPointSign) -> AppValue {
        let amount = convertAmount(amount: value, decimals: baseToken.decimals, sign: sign)
        return AppValue(token: baseToken, value: amount)
    }

    private func qip20Value(tokenAddress: QvmKit.Address, value: BigUInt, sign: FloatingPointSign, tokenInfo: Qip20Kit.TokenInfo?) -> AppValue {
        let query = TokenQuery(blockchainType: blockchainType, tokenType: .qrc20(address: tokenAddress.hex))

        if let token = try? coinManager.token(query: query) {
            let value = convertAmount(amount: value, decimals: token.decimals, sign: sign)
            return AppValue(token: token, value: value)
        } else if let tokenInfo {
            let value = convertAmount(amount: value, decimals: tokenInfo.tokenDecimal, sign: sign)
            return AppValue(tokenName: tokenInfo.tokenName, tokenCode: tokenInfo.tokenSymbol, tokenDecimals: tokenInfo.tokenDecimal, value: value)
        }

        return AppValue(value: convertAmount(amount: value, decimals: 0, sign: sign))
    }

    private func transferEvents(incomingQip20Transfers: [TransferEventInstance]) -> [TransferEvent] {
        incomingQip20Transfers.map { transfer in
            TransferEvent(
                address: transfer.from.qip55,
                value: qip20Value(tokenAddress: transfer.contractAddress, value: transfer.value, sign: .plus, tokenInfo: transfer.tokenInfo)
            )
        }
    }

    private func transferEvents(outgoingQip20Transfers: [TransferEventInstance]) -> [TransferEvent] {
        outgoingQip20Transfers.map { transfer in
            TransferEvent(
                address: transfer.to.qip55,
                value: qip20Value(tokenAddress: transfer.contractAddress, value: transfer.value, sign: .minus, tokenInfo: transfer.tokenInfo)
            )
        }
    }

    private func transferEvents(incomingQip721Transfers: [Qip721TransferEventInstance]) -> [TransferEvent] {
        incomingQip721Transfers.map { transfer in
            TransferEvent(
                address: transfer.from.qip55,
                value: AppValue(
                    nftUid: .evm(blockchainType: source.blockchainType, contractAddress: transfer.contractAddress.hex, tokenId: transfer.tokenId.description),
                    tokenName: transfer.tokenInfo?.tokenName,
                    tokenSymbol: transfer.tokenInfo?.tokenSymbol,
                    value: 1
                )
            )
        }
    }

    private func transferEvents(outgoingQip721Transfers: [Qip721TransferEventInstance]) -> [TransferEvent] {
        outgoingQip721Transfers.map { transfer in
            TransferEvent(
                address: transfer.to.qip55,
                value: AppValue(
                    nftUid: .evm(blockchainType: source.blockchainType, contractAddress: transfer.contractAddress.hex, tokenId: transfer.tokenId.description),
                    tokenName: transfer.tokenInfo?.tokenName,
                    tokenSymbol: transfer.tokenInfo?.tokenSymbol,
                    value: -1
                )
            )
        }
    }

    private func transferEvents(incomingQip1155Transfers: [Qip1155TransferEventInstance]) -> [TransferEvent] {
        incomingQip1155Transfers.map { transfer in
            TransferEvent(
                address: transfer.from.qip55,
                value: AppValue(
                    nftUid: .evm(blockchainType: source.blockchainType, contractAddress: transfer.contractAddress.hex, tokenId: transfer.tokenId.description),
                    tokenName: transfer.tokenInfo?.tokenName,
                    tokenSymbol: transfer.tokenInfo?.tokenSymbol,
                    value: convertAmount(amount: transfer.value, decimals: 0, sign: .plus)
                )
            )
        }
    }

    private func transferEvents(outgoingQip1155Transfers: [Qip1155TransferEventInstance]) -> [TransferEvent] {
        outgoingQip1155Transfers.map { transfer in
            TransferEvent(
                address: transfer.to.qip55,
                value: AppValue(
                    nftUid: .evm(blockchainType: source.blockchainType, contractAddress: transfer.contractAddress.hex, tokenId: transfer.tokenId.description),
                    tokenName: transfer.tokenInfo?.tokenName,
                    tokenSymbol: transfer.tokenInfo?.tokenSymbol,
                    value: convertAmount(amount: transfer.value, decimals: 0, sign: .minus)
                )
            )
        }
    }

    private func transferEvents(internalTransactions: [InternalTransaction]) -> [TransferEvent] {
        internalTransactions.map { internalTransaction in
            TransferEvent(
                address: internalTransaction.from.qip55,
                value: baseAppValue(value: internalTransaction.value, sign: .plus)
            )
        }
    }

    private func transferEvents(contractAddress: QvmKit.Address, value: BigUInt) -> [TransferEvent] {
        guard value != 0 else {
            return []
        }

        let event = TransferEvent(
            address: contractAddress.qip55,
            value: baseAppValue(value: value, sign: .minus)
        )

        return [event]
    }
}

// TODO: Add TFAKit integration into NFTs
extension QvmTransactionConverter {
    func transactionRecord(fromTransaction fullTransaction: FullTransaction) -> QvmTransactionRecord {
        let transaction = fullTransaction.transaction

        print("[QvmTransactionConverter] hash=\(transaction.hash.hs.hexString.prefix(10)) decorationType=\(String(describing: type(of: fullTransaction.decoration)))")

        switch fullTransaction.decoration {
        case is ContractCreationDecoration:
            return QvmContractCreationTransactionRecord(
                source: source,
                transaction: transaction,
                baseToken: baseToken
            )

        case let decoration as IncomingDecoration:
            return QvmIncomingTransactionRecord(
                source: source,
                transaction: transaction,
                baseToken: baseToken,
                from: decoration.from.qip55,
                value: baseAppValue(value: decoration.value, sign: .plus)
            )

        case let decoration as OutgoingDecoration:
            return QvmOutgoingTransactionRecord(
                source: source,
                transaction: transaction,
                baseToken: baseToken,
                to: decoration.to.qip55,
                value: baseAppValue(value: decoration.value, sign: .minus),
                sentToSelf: decoration.sentToSelf
            )

        case let decoration as OutgoingQip20Decoration:
            return QvmOutgoingTransactionRecord(
                source: source,
                transaction: transaction,
                baseToken: baseToken,
                to: decoration.to.qip55,
                value: qip20Value(tokenAddress: decoration.contractAddress, value: decoration.value, sign: .minus, tokenInfo: decoration.tokenInfo),
                sentToSelf: decoration.sentToSelf
            )

        case let decoration as ApproveQip20Decoration:
            return QvmApproveTransactionRecord(
                source: source,
                transaction: transaction,
                baseToken: baseToken,
                spender: decoration.spender.qip55,
                value: qip20Value(tokenAddress: decoration.contractAddress, value: decoration.value, sign: .plus, tokenInfo: nil)
            )

        case let decoration as Qip721SafeTransferFromDecoration:
            return QvmOutgoingTransactionRecord(
                source: source,
                transaction: transaction,
                baseToken: baseToken,
                to: decoration.to.qip55,
                value: AppValue(
                    nftUid: .evm(blockchainType: source.blockchainType, contractAddress: decoration.contractAddress.hex, tokenId: decoration.tokenId.description),
                    tokenName: decoration.tokenInfo?.tokenName,
                    tokenSymbol: decoration.tokenInfo?.tokenSymbol,
                    value: convertAmount(amount: 1, decimals: 0, sign: .minus)
                ),
                sentToSelf: decoration.sentToSelf
            )

        case let decoration as Qip1155SafeTransferFromDecoration:
            return QvmOutgoingTransactionRecord(
                source: source,
                transaction: transaction,
                baseToken: baseToken,
                to: decoration.to.qip55,
                value: AppValue(
                    nftUid: .evm(blockchainType: source.blockchainType, contractAddress: decoration.contractAddress.hex, tokenId: decoration.tokenId.description),
                    tokenName: decoration.tokenInfo?.tokenName,
                    tokenSymbol: decoration.tokenInfo?.tokenSymbol,
                    value: convertAmount(amount: decoration.value, decimals: 0, sign: .minus)
                ),
                sentToSelf: decoration.sentToSelf
            )

        case let decoration as UnknownTransactionDecoration:
            let internalTransactions = decoration.internalTransactions.filter { $0.to == userAddress }

            let qip20Transfers = decoration.eventInstances.compactMap { $0 as? TransferEventInstance }
            let incomingQip20Transfers = qip20Transfers.filter { $0.to == userAddress && $0.from != userAddress }
            let outgoingQip20Transfers = qip20Transfers.filter { $0.from == userAddress }

            let qip721Transfers = decoration.eventInstances.compactMap { $0 as? Qip721TransferEventInstance }
            let incomingQip721Transfers = qip721Transfers.filter { $0.to == userAddress && $0.from != userAddress }
            let outgoingQip721Transfers = qip721Transfers.filter { $0.from == userAddress }

            let qip1155Transfers = decoration.eventInstances.compactMap { $0 as? Qip1155TransferEventInstance }
            let incomingQip1155Transfers = qip1155Transfers.filter { $0.to == userAddress && $0.from != userAddress }
            let outgoingQip1155Transfers = qip1155Transfers.filter { $0.from == userAddress }

            if transaction.from == userAddress, let contractAddress = transaction.to, let value = transaction.value {
                return QvmContractCallTransactionRecord(
                    source: source,
                    transaction: transaction,
                    baseToken: baseToken,
                    contractAddress: contractAddress.qip55,
                    method: transaction.input.flatMap { qvmLabelManager.methodLabel(input: $0) },
                    incomingEvents: transferEvents(internalTransactions: internalTransactions) + transferEvents(incomingQip20Transfers: incomingQip20Transfers) +
                        transferEvents(incomingQip721Transfers: incomingQip721Transfers) + transferEvents(incomingQip1155Transfers: incomingQip1155Transfers),
                    outgoingEvents: transferEvents(contractAddress: contractAddress, value: value) + transferEvents(outgoingQip20Transfers: outgoingQip20Transfers) +
                        transferEvents(outgoingQip721Transfers: outgoingQip721Transfers) + transferEvents(outgoingQip1155Transfers: outgoingQip1155Transfers)
                )
            } else if transaction.from != userAddress, transaction.to != userAddress {
                return QvmExternalContractCallTransactionRecord(
                    source: source,
                    transaction: transaction,
                    baseToken: baseToken,
                    incomingEvents: transferEvents(internalTransactions: internalTransactions) + transferEvents(incomingQip20Transfers: incomingQip20Transfers) +
                        transferEvents(incomingQip721Transfers: incomingQip721Transfers) + transferEvents(incomingQip1155Transfers: incomingQip1155Transfers),
                    outgoingEvents: transferEvents(outgoingQip20Transfers: outgoingQip20Transfers) +
                        transferEvents(outgoingQip721Transfers: outgoingQip721Transfers) + transferEvents(outgoingQip1155Transfers: outgoingQip1155Transfers),
                    spam: false
                )
            }

        default: ()
        }

        return QvmTransactionRecord(
            source: source,
            transaction: transaction,
            baseToken: baseToken,
            ownTransaction: transaction.from == userAddress
        )
    }
}
