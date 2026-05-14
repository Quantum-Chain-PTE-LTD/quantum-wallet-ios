import BigInt
import Combine
import Qip20Kit
import QvmKit
import Foundation
import HsExtensions
import HsToolKit
import MarketKit
import OneInchKit
import RxSwift
import UniswapKit

class QvmAccountManager {
    private let blockchainType: BlockchainType
    private let accountManager: AccountManager
    private let walletManager: WalletManager
    private let marketKit: MarketKit.Kit
    private let qvmKitManager: QvmKitManager
    private let restoreStateManager: RestoreStateManager

    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()
    private var tasks = Set<AnyTask>()

    init(blockchainType: BlockchainType, accountManager: AccountManager, walletManager: WalletManager, marketKit: MarketKit.Kit, qvmKitManager: QvmKitManager, restoreStateManager: RestoreStateManager) {
        self.blockchainType = blockchainType
        self.accountManager = accountManager
        self.walletManager = walletManager
        self.marketKit = marketKit
        self.qvmKitManager = qvmKitManager
        self.restoreStateManager = restoreStateManager

        subscribe(ConcurrentDispatchQueueScheduler(qos: .userInitiated), disposeBag, qvmKitManager.qvmKitCreatedObservable) { [weak self] in self?.handleQvmKitCreated() }
    }

    private func handleQvmKitCreated() {
        cancellables = Set([])
        tasks = Set([])

        subscribeToTransactions()
    }

    private func subscribeToTransactions() {
        guard let qvmKitWrapper = qvmKitManager.qvmKitWrapper else {
            return
        }

        qvmKitWrapper.qvmKit.allTransactionsPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] fullTransactions, initial in
                self?.handle(fullTransactions: fullTransactions, initial: initial)
            }
            .store(in: &cancellables)
    }

    private func handle(fullTransactions: [FullTransaction], initial: Bool) {
        guard let account = accountManager.activeAccount else {
            return
        }

        if initial, account.origin == .restored, !account.watchAccount, !restoreStateManager.shouldRestore(account: account, blockchainType: blockchainType) {
            return
        }

        guard let qvmKitWrapper = qvmKitManager.qvmKitWrapper else {
            return
        }

        let address = qvmKitWrapper.qvmKit.address

        var foundTokens = Set<FoundToken>()
        var suspiciousTokenTypes = Set<TokenType>()

        for fullTransaction in fullTransactions {
            switch fullTransaction.decoration {
            case is IncomingDecoration:
                foundTokens.insert(FoundToken(tokenType: .native))

            case let decoration as UnknownTransactionDecoration:
                if decoration.internalTransactions.contains(where: { $0.to == address }) {
                    foundTokens.insert(FoundToken(tokenType: .native))
                }

                for eventInstance in decoration.eventInstances {
                    guard let transferEventInstance = eventInstance as? TransferEventInstance else {
                        continue
                    }

                    if transferEventInstance.to == address {
                        let tokenType: TokenType = .qrc20(address: transferEventInstance.contractAddress.hex)
                        if let fromAddress = decoration.fromAddress, fromAddress == address {
                            foundTokens.insert(FoundToken(tokenType: tokenType, tokenInfo: transferEventInstance.tokenInfo))
                        } else {
                            suspiciousTokenTypes.insert(tokenType)
                        }
                    }
                }

            default: ()
            }
        }

        handle(foundTokens: Array(foundTokens), suspiciousTokenTypes: Array(suspiciousTokenTypes.subtracting(foundTokens.map(\.tokenType))), account: account, qvmKit: qvmKitWrapper.qvmKit)
    }

    private func handle(foundTokens: [FoundToken], suspiciousTokenTypes: [TokenType], account: Account, qvmKit: QvmKit.Kit) {
        guard !foundTokens.isEmpty || !suspiciousTokenTypes.isEmpty else {
            return
        }

        do {
            let queries = (foundTokens.map(\.tokenType) + suspiciousTokenTypes).map { TokenQuery(blockchainType: blockchainType, tokenType: $0) }
            let tokens = try queries.chunks(500).map { try marketKit.tokens(queries: $0) }.flatMap { $0 }

            var tokenInfos = [TokenInfo]()

            for foundToken in foundTokens {
                if let token = tokens.first(where: { $0.type == foundToken.tokenType }) {
                    let tokenInfo = TokenInfo(
                        type: foundToken.tokenType,
                        coinName: token.coin.name,
                        coinCode: token.coin.code,
                        tokenDecimals: token.decimals
                    )

                    tokenInfos.append(tokenInfo)
                } else if let tokenInfo = foundToken.tokenInfo {
                    let tokenInfo = TokenInfo(
                        type: foundToken.tokenType,
                        coinName: tokenInfo.tokenName,
                        coinCode: tokenInfo.tokenSymbol,
                        tokenDecimals: tokenInfo.tokenDecimal
                    )

                    tokenInfos.append(tokenInfo)
                }
            }

            for tokenType in suspiciousTokenTypes {
                if let token = tokens.first(where: { $0.type == tokenType }) {
                    let tokenInfo = TokenInfo(
                        type: tokenType,
                        coinName: token.coin.name,
                        coinCode: token.coin.code,
                        tokenDecimals: token.decimals
                    )

                    tokenInfos.append(tokenInfo)
                }
            }

            handle(tokenInfos: tokenInfos, account: account, qvmKit: qvmKit)
        } catch {
            // do nothing
        }
    }

    private func handle(tokenInfos: [TokenInfo], account: Account, qvmKit: QvmKit.Kit) {
        let existingWallets = walletManager.activeWallets
        let existingTokenTypeIds = existingWallets.map(\.token.type.id)
        let newTokenInfos = tokenInfos.filter { !existingTokenTypeIds.contains($0.type.id) }

        guard !newTokenInfos.isEmpty else {
            return
        }

        let userAddress = qvmKit.address
        let dataProvider: DataProvider = DataProvider(qvmKit: qvmKit)

        let task = Task(priority: .userInitiated) { [weak self] in
            let tokenInfos: [(tokenInfo: TokenInfo, balance: BigUInt)] = await withTaskGroup(of: (TokenInfo, BigUInt).self) { group in
                for tokenInfo in tokenInfos {
                    guard case let .qrc20(address) = tokenInfo.type, let contractAddress = try? QvmKit.Address(hex: address) else {
                        continue
                    }

                    group.addTask {
                        let balance = await (try? dataProvider.fetchBalance(contractAddress: contractAddress, address: userAddress)) ?? 0
                        return (tokenInfo, balance)
                    }
                }

                var results = [(TokenInfo, BigUInt)]()
                for await result in group {
                    results.append(result)
                }

                return results
            }

            let nonZeroBalanceTokens = tokenInfos.filter { $0.balance > 0 }.map(\.tokenInfo)

            self?.handle(processedTokenInfos: nonZeroBalanceTokens, account: account)
        }

        task.store(in: &tasks)
    }

    private func handle(processedTokenInfos infos: [TokenInfo], account: Account) {
        guard !infos.isEmpty else {
            return
        }

        let enabledWallets = infos.map { info in
            EnabledWallet(
                tokenQueryId: TokenQuery(blockchainType: blockchainType, tokenType: info.type).id,
                accountId: account.id,
                coinName: info.coinName,
                coinCode: info.coinCode,
                tokenDecimals: info.tokenDecimals
            )
        }

        walletManager.save(enabledWallets: enabledWallets)
    }
}

extension QvmAccountManager {
    struct TokenInfo {
        let type: TokenType
        let coinName: String
        let coinCode: String
        let tokenDecimals: Int
    }

    struct FoundToken: Hashable {
        let tokenType: MarketKit.TokenType
        let tokenInfo: Qip20Kit.TokenInfo?

        init(tokenType: MarketKit.TokenType, tokenInfo: Qip20Kit.TokenInfo? = nil) {
            self.tokenType = tokenType
            self.tokenInfo = tokenInfo
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(tokenType)
        }

        static func == (lhs: FoundToken, rhs: FoundToken) -> Bool {
            lhs.tokenType == rhs.tokenType
        }
    }
}
