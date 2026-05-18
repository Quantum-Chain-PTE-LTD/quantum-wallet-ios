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
            _ = try QvmKit.Address(userInput: reference)
        } catch {
            throw TokenError.invalidAddress
        }
    }

    func tokenQuery(reference: String) -> TokenQuery {
        let address = (try? QvmKit.Address(userInput: reference).hex) ?? reference
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return TokenQuery(blockchainType: blockchain.type, tokenType: .qrc20(address: address))
    }

    func token(reference: String) async throws -> Token {
        guard let address = try? QvmKit.Address(userInput: reference) else {
            throw TokenError.invalidAddress
        }

        let tokenQuery = tokenQuery(reference: address.hex)

        do {
            let tokenInfo = try await Qip20Kit.Kit.tokenInfo(networkManager: networkManager, rpcSource: rpcSource, contractAddress: address)
            return Token(
                coin: Coin(uid: tokenQuery.customCoinUid, name: tokenInfo.name, code: tokenInfo.symbol),
                blockchain: blockchain,
                type: tokenQuery.tokenType,
                decimals: tokenInfo.decimals
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
