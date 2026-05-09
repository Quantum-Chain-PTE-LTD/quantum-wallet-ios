import QvmKit
import Foundation
import HsToolKit
import MarketKit

class Qip20AddressValidator {
    private let qvmSyncSourceManager: QvmSyncSourceManager

    init() {
        qvmSyncSourceManager = Core.shared.qvmSyncSourceManager
    }

    static func method(address: Address, contractAddress: QvmKit.Address) -> ContractMethod? {
        guard let qvmAddress = try? QvmKit.Address(hex: address.raw) else {
            return nil
        }

        if Qip20AddressValidator.IsBlacklistedMethodUSDT.contractAddresses.contains(contractAddress.qip55) {
            return IsBlacklistedMethodUSDT(address: qvmAddress)
        }

        if Qip20AddressValidator.IsBlacklistedMethodUSDC.contractAddresses.contains(contractAddress.qip55) {
            return IsBlacklistedMethodUSDC(address: qvmAddress)
        }

        if Qip20AddressValidator.IsFrozenMethodPYUSD.contractAddresses.contains(contractAddress.qip55) {
            return IsFrozenMethodPYUSD(address: qvmAddress)
        }

        return nil
    }

    static func supports(token: Token) -> Bool {
        guard case let .eip20(addressString) = token.type,
              let contractAddress = try? QvmKit.Address(hex: addressString)
        else {
            return false
        }

        return method(address: Address(raw: ""), contractAddress: contractAddress) != nil
    }
}

extension Qip20AddressValidator: IAddressSecurityChecker {
    func check(address: Address, token: Token) async throws -> Bool {
        guard case let .eip20(addressString) = token.type,
              let contractAddress = try? QvmKit.Address(hex: addressString),
              let syncSource = qvmSyncSourceManager.defaultSyncSources(blockchainType: token.blockchainType).first,
              let method = Self.method(address: address, contractAddress: contractAddress)
        else {
            return false
        }

        let networkManager = NetworkManager(logger: Core.shared.logger)
        let responseData = try await QvmKit.Kit.call(
            networkManager: networkManager,
            rpcSource: syncSource.rpcSource,
            contractAddress: contractAddress,
            data: method.encodedABI(),
            defaultBlockParameter: .latest
        )

        return responseData.contains(0x01)
    }
}

extension Qip20AddressValidator {
    class IsBlacklistedMethodUSDT: ContractMethod {
        static let contractAddresses = [
            "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        ]

        private let address: QvmKit.Address

        init(address: QvmKit.Address) {
            self.address = address
        }

        override var methodSignature: String {
            "isBlackListed(address)"
        }

        override var arguments: [Any] {
            [address]
        }
    }

    class IsBlacklistedMethodUSDC: ContractMethod {
        static let contractAddresses = [
            "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        ]

        private let address: QvmKit.Address

        init(address: QvmKit.Address) {
            self.address = address
        }

        override var methodSignature: String {
            "isBlacklisted(address)"
        }

        override var arguments: [Any] {
            [address]
        }
    }

    class IsFrozenMethodPYUSD: ContractMethod {
        static let contractAddresses = [
            "0x6c3ea9036406852006290770BEdFcAbA0e23A0e8",
        ]

        private let address: QvmKit.Address

        init(address: QvmKit.Address) {
            self.address = address
        }

        override var methodSignature: String {
            "isFrozen(address)"
        }

        override var arguments: [Any] {
            [address]
        }
    }
}
