import QvmKit
import MarketKit
import RxSwift

class QvmAddressParser: IAddressParserItem {
    let blockchainType: BlockchainType

    init(blockchainType: BlockchainType = .quantumChain) {
        self.blockchainType = blockchainType
    }

    func handle(address: String) -> Single<Address> {
        do {
            let address = try QvmKit.Address(userInput: address)
            return Single.just(Address(raw: address.qip55, blockchainType: blockchainType))
        } catch {
            return Single.error(error)
        }
    }

    func isValid(address: String) -> Single<Bool> {
        let address = try? QvmKit.Address(userInput: address)
        return Single.just(address != nil)
    }
}

extension QvmKit.Address {
    init(userInput: String) throws {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("0x") {
            try self.init(hex: trimmed)
        } else if trimmed.hasPrefix("0X") {
            try self.init(hex: "0x" + trimmed.dropFirst(2))
        } else {
            try self.init(hex: "0x" + trimmed)
        }
    }
}
