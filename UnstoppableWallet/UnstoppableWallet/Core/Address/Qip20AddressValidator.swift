import QvmKit
import Foundation
import HsToolKit
import MarketKit

class Qip20AddressValidator {
    private let qvmSyncSourceManager: QvmSyncSourceManager
    private let networkManager: NetworkManager

    init(qvmSyncSourceManager: QvmSyncSourceManager, networkManager: NetworkManager) {
        self.qvmSyncSourceManager = qvmSyncSourceManager
        self.networkManager = networkManager
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
        let addressString: String
        switch token.type {
        case let .qrc20(address):
            addressString = address
        case let .eip20(address):
            addressString = address
        default:
            return false
        }

        guard let contractAddress = try? QvmKit.Address(hex: addressString) else {
            return false
        }

        return method(address: Address(raw: ""), contractAddress: contractAddress) != nil
    }
}

extension Qip20AddressValidator: IContractAddressValidator {
    func canCheck(blockchainType: BlockchainType) -> Bool {
        QvmBlockchainManager.blockchainTypes.contains(blockchainType)
    }

    func supports(token: Token) -> Bool {
        Self.supports(token: token)
    }

    func isClear(address: Address, coinUid: String, blockchainType: BlockchainType, contractAddress: String) async throws -> Bool {
        guard let qvmAddress = try? QvmKit.Address(hex: address.raw) else {
            throw ContractAddressValidatorChain.CheckError.invalidAddress
        }

        guard let qvmContractAddress = try? QvmKit.Address(hex: contractAddress) else {
            throw ContractAddressValidatorChain.CheckError.invalidContractAddress
        }

        guard let syncSource = qvmSyncSourceManager.defaultSyncSources(blockchainType: blockchainType).first else {
            throw ContractAddressValidatorChain.CheckError.noSyncSource
        }

        guard let method = Self.method(address: Address(raw: address.raw), contractAddress: qvmContractAddress) else {
            throw ContractAddressValidatorChain.CheckError.noMethod
        }

        let responseData = try await QvmKit.Kit.call(
            networkManager: networkManager,
            rpcSource: syncSource.rpcSource,
            contractAddress: qvmContractAddress,
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
