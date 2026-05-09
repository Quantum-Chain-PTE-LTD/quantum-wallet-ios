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
            let address = try QvmKit.Address(hex: address)
            return Single.just(Address(raw: address.hex, blockchainType: blockchainType))
        } catch {
            return Single.error(error)
        }
    }

    func isValid(address: String) -> Single<Bool> {
        let address = try? QvmKit.Address(hex: address)
        return Single.just(address != nil)
    }
}
