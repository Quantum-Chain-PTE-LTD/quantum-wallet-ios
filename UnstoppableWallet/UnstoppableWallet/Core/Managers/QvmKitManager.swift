import Alamofire
import Qip20Kit
import QvmKit
import Foundation
import MarketKit
import ObjectMapper
import TfaKit
import Combine
import RxRelay
import RxSwift

class QvmKitManager {
    let chain: Chain
    private let syncSourceManager: QvmSyncSourceManager
    private let disposeBag = DisposeBag()

    private weak var _qvmKitWrapper: QvmKitWrapper?

    private let qvmKitCreatedRelay = PublishRelay<Void>()
    private let qvmKitUpdatedRelay = PublishRelay<Void>()
    private(set) var currentAccount: Account?

    private let queue = DispatchQueue(label: "\(AppConfig.label).quantum-kit-manager", qos: .userInitiated)

    init(chain: Chain, syncSourceManager: QvmSyncSourceManager) {
        self.chain = chain
        self.syncSourceManager = syncSourceManager

        subscribe(disposeBag, syncSourceManager.syncSourceObservable) { [weak self] blockchainType in
            self?.handleUpdatedSyncSource(blockchainType: blockchainType)
        }
    }

    private func handleUpdatedSyncSource(blockchainType: BlockchainType) {
        queue.sync {
            guard let _qvmKitWrapper else {
                return
            }

            guard _qvmKitWrapper.blockchainType == blockchainType else {
                return
            }

            self._qvmKitWrapper = nil
            qvmKitUpdatedRelay.accept(())
        }
    }

    private func _qvmKitWrapper(account: Account, blockchainType: BlockchainType) throws -> QvmKitWrapper {
        if let _qvmKitWrapper, let currentAccount, currentAccount == account {
            return _qvmKitWrapper
        }

        let syncSource = syncSourceManager.syncSource(blockchainType: blockchainType)

        let address: QvmKit.Address
        var signer: Signer?

        switch account.type {
        case .mnemonic:
            guard let seed = account.type.mnemonicSeed else {
                throw KitWrapperError.mnemonicNoSeed
            }
            address = try Signer.address(seed: seed.prefix(32), chain: chain)
            signer = try Signer.instance(seed: seed.prefix(32), chain: chain)
        case let .qvmAddress(value):
            address = value
        default:
            throw AdapterError.unsupportedAccount
        }

        let qvmKit = try QvmKit.Kit.instance(
            address: address,
            chain: chain,
            rpcSource: syncSource.rpcSource,
            transactionSource: syncSource.transactionSource,
            walletId: account.id,
            minLogLevel: .error
        )

        Qip20Kit.Kit.addDecorators(to: qvmKit)
        Qip20Kit.Kit.addTransactionSyncer(to: qvmKit)

        var tfaKit: TfaKit.Kit?
        let supportedTfaTypes = blockchainType.supportedNftTypes

        if !supportedTfaTypes.isEmpty {
            let kit = try TfaKit.Kit.instance(qvmKit: qvmKit)

            for tfaType in supportedTfaTypes {
                switch tfaType {
                case .eip721:
                    kit.addQip721TransactionSyncer()
                    kit.addQip721Decorators()
                case .eip1155:
                    kit.addQip1155TransactionSyncer()
                    kit.addQip1155Decorators()
                }
            }

            tfaKit = kit
        }

        qvmKit.start()

        let wrapper = QvmKitWrapper(blockchainType: blockchainType, qvmKit: qvmKit, tfaKit: tfaKit, signer: signer)

        _qvmKitWrapper = wrapper
        currentAccount = account

        qvmKitCreatedRelay.accept(())

        return wrapper
    }
}

extension QvmKitManager {
    var qvmKitCreatedObservable: Observable<Void> {
        qvmKitCreatedRelay.asObservable()
    }

    var qvmKitUpdatedObservable: Observable<Void> {
        qvmKitUpdatedRelay.asObservable()
    }

    var qvmKitWrapper: QvmKitWrapper? {
        queue.sync {
            _qvmKitWrapper
        }
    }

    func qvmKitWrapper(account: Account, blockchainType: BlockchainType) throws -> QvmKitWrapper {
        try queue.sync {
            try _qvmKitWrapper(account: account, blockchainType: blockchainType)
        }
    }
}

private var cancellablesKey = "qvmKitWrapper.allowed.cancellables"
private var allowedRelayKey = "qvmKitWrapper.allowed.relay"

class QvmKitWrapper {
    let blockchainType: BlockchainType
    let qvmKit: QvmKit.Kit
    let tfaKit: TfaKit.Kit?
    let signer: Signer?

    init(blockchainType: BlockchainType, qvmKit: QvmKit.Kit, tfaKit: TfaKit.Kit?, signer: Signer?) {
        self.blockchainType = blockchainType
        self.qvmKit = qvmKit
        self.tfaKit = tfaKit
        self.signer = signer
    }
    
    var allowed: Bool {
        allowedRelay.value
    }

    var allowedObservable: Observable<Bool> {
        allowedRelay.asObservable()
    }

    private var allowedRelay: BehaviorRelay<Bool> {
        if let relay = objc_getAssociatedObject(self, &allowedRelayKey) as? BehaviorRelay<Bool> {
            return relay
        }

        let relay = BehaviorRelay<Bool>(value: false)
        objc_setAssociatedObject(self, &allowedRelayKey, relay, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        qvmKit.allowedPublisher
            .receive(on: DispatchQueue.main)
            .sink { allowed in
                relay.accept(allowed)
            }
            .store(in: &cancellables)

        return relay
    }

    private var cancellables: Set<AnyCancellable> {
        get {
            objc_getAssociatedObject(self, &cancellablesKey) as? Set<AnyCancellable> ?? []
        }
        set {
            objc_setAssociatedObject(self, &cancellablesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func sendSingle(transactionData: TransactionData, gasPrice: GasPrice, gasLimit: Int, nonce: Int? = nil) -> Single<FullTransaction> {
        Single<FullTransaction>.create { [weak self] observer in
            let task = Task {
                do {
                    guard let self else {
                        throw AppError.weakReference
                    }

                    let fullTransaction = try await self.send(
                        transactionData: transactionData,
                        gasPrice: gasPrice,
                        gasLimit: gasLimit,
                        nonce: nonce
                    )
                    observer(.success(fullTransaction))
                } catch {
                    observer(.error(error))
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    func send(transactionData: TransactionData, gasPrice: GasPrice, gasLimit: Int, nonce: Int? = nil) async throws -> FullTransaction {
        guard let signer else {
            throw SignerError.signerNotSupported
        }

        guard try await canSendTransaction() else {
            throw AppError.quantum(reason: .notAllowed)
        }

        let rawTransaction = try await qvmKit.fetchRawTransaction(transactionData: transactionData, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce)
        let signature = try signer.signature(rawTransaction: rawTransaction)
        let publicKey = try signer.publicKey()
        return try await qvmKit.send(rawTransaction: rawTransaction, signature: signature, publicKey: publicKey)
    }

    private func canSendTransaction() async throws -> Bool {
        let headers = AppConfig.quantumChainApiKey.flatMap { HTTPHeaders([HTTPHeader(name: "apikey", value: $0)]) }
        let baseUrl = AppConfig.quantumAuthApiBaseUrl.hasSuffix("/") ? String(AppConfig.quantumAuthApiBaseUrl.dropLast()) : AppConfig.quantumAuthApiBaseUrl
        let parameters: Parameters = [
            "address": qvmKit.receiveAddress.qip55,
        ]
        let response: AuthResponse = try await Core.shared.networkManager.fetch(
            url: "\(baseUrl)/authentication-quantum-wallet",
            parameters: parameters,
            headers: headers
        )
        return response.allowed
    }
}

private struct AuthResponse: ImmutableMappable {
    let allowed: Bool

    init(map: Map) throws {
        allowed = try map.value("allowed") ?? false
    }
}

extension QvmKitManager {
    enum KitWrapperError: Error {
        case mnemonicNoSeed
    }
}

extension QvmKitWrapper {
    enum SignerError: Error {
        case signerNotSupported
    }
}
