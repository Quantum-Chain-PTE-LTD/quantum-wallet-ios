import EvmKit
import QvmKit

enum InitialTransactionSettings {
    case evm(gasPrice: EvmKit.GasPrice?, nonce: Int?)
    case qvm(gasPrice: QvmKit.GasPrice?, nonce: Int?)
}
