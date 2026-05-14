import Foundation
import HsToolKit
import MarketKit
import Qip20Kit
import QvmKit

class AddQvmTokenBlockchainService {
    private let blockchain: Blockchain
    private let networkManager: NetworkManager
    private let rpcSource: RpcSource

    init?(blockchain: Blockchain, networkManager: NetworkManager, qvmSyncSourceManager: QvmSyncSourceManager) {
        self.blockchain = blockchain
        self.networkManager = networkManager

        guard let rpcSource = qvmSyncSourceManager.defaultSyncSources(blockchainType: blockchain.type).first?.rpcSource else {
            return nil
        }

        self.rpcSource = rpcSource
    }
}

extension AddQvmTokenBlockchainService: IAddTokenBlockchainService {
    var placeholder: String {
        "add_token.input_placeholder.contract_address".localized
    }

    func validate(reference: String) throws {
        do {
            _ = try QvmKit.Address(hex: reference)
        } catch {
            throw TokenError.invalidAddress
        }
    }

    func tokenQuery(reference: String) -> TokenQuery {
        TokenQuery(blockchainType: blockchain.type, tokenType: .qrc20(address: reference.lowercased()))
    }

    func token(reference: String) async throws -> Token {
        guard let address = try? QvmKit.Address(hex: reference) else {
            throw TokenError.invalidAddress
        }

        let tokenQuery = tokenQuery(reference: reference)

        do {
            let tokenInfo = try await Qip20Kit.Kit.tokenInfo(networkManager: networkManager, rpcSource: rpcSource, contractAddress: address)
            return Token(
                coin: Coin(uid: tokenQuery.customCoinUid, name: tokenInfo.tokenName, code: tokenInfo.tokenSymbol),
                blockchain: blockchain,
                type: tokenQuery.tokenType,
                decimals: tokenInfo.tokenDecimal
            )
        } catch {
            throw TokenError.notFound(blockchainName: blockchain.name)
        }
    }
}

extension AddQvmTokenBlockchainService {
    enum TokenError: LocalizedError {
        case invalidAddress
        case notFound(blockchainName: String)

        var errorDescription: String? {
            switch self {
            case .invalidAddress: return "add_token.invalid_contract_address".localized
            case let .notFound(blockchainName): return "add_token.contract_address_not_found".localized(blockchainName)
            }
        }
    }
}
