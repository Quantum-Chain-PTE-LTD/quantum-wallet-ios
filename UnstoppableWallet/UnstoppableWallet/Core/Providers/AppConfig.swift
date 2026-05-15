import Foundation
import MarketKit
import UIKit

enum AppConfig {
    static let label = "com.quantum.chain.wallet"
    static let backupSalt = "quantum"

    static let companyName = "Quantum Chain"
    static let reportEmail = "contact@quantumcha.in"
    static let companyWebPageLink = "https://www.quantumcha.in"
    static let appWebPageLink = "https://www.quantumcha.in"
    static let analyticsLink = "https://www.quantumcha.in"
    static let privacyPolicyLink = "https://www.quantumcha.in/privacy-policy"
    static let appleTermsOfServiceLink = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula"
    static let nymVpnLink = "https://nymtechnologies.pxf.io/N9vnr1"
    static let appGitHubAccount = "Quantum-Chain-PTE-LTD"
    static let appGitHubRepository = "quantum-wallet-ios"
    static let appTwitterAccount = "qntmchain"
    static let appTelegramAccount = "+XF1OapBYfu1iMzg0"
    static let appTelegramSupportSlug = "XF1OapBYfu1iMzg0"
    static let appTokenTelegramAccount = "BeUnstoppable_bot"
    static let mempoolSpaceUrl = "https://mempool.space"
    static let guidesIndexUrl = URL(string: "https://raw.githubusercontent.com/horizontalsystems/blockchain-crypto-guides/v1.2/index.json")!
    static let faqIndexUrl = URL(string: "https://raw.githubusercontent.com/horizontalsystems/unstoppable-wallet-website/master/src/faq.json")!
    static let eduIndexUrl = URL(string: "https://raw.githubusercontent.com/horizontalsystems/Unstoppable-Wallet-Website/refs/tags/v1.4/src/edu.json")!
    static let donationAddresses: [BlockchainType: String] = [
        .quantumChain: "0xc8C51c75d0177385BD00710b3B0584724dD3f111",
        .bitcoin: "bc1qxq0ctg3fs6av34j6a0kkyqevrh3d2gkllqmmr9",
        .bitcoinCash: "bitcoincash:qzanu93476zlqgmwgqpyrfwk0p9f74k4nuq20v378j\n",
        .ecash: "ecash:qzlus6latftw8kw57fvy7vpgle5zp4x8hufej0n03p\n",
        .litecoin: "ltc1q3hnl3qga5ndd3gjvn8p5jmmm8ucntsgmwn2qw4\n",
        .dash: "XvXRo4hE39CPMJwq3Xxii9jSBVFmmVbjxQ",
        .zcash: "zs1xd2cy2t6s63e9k2tp00p5gudf65p7erqxaqyxf4rwrcrtj2klrxmqdzjudf6p4frsmuavph5pxw",
        .ethereum: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .binanceSmartChain: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .polygon: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .avalanche: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .optimism: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .base: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .zkSync: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .arbitrumOne: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .gnosis: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .fantom: "0xB30251931DFc7B16624E6D34930F76fDb5536Dd7",
        .ton: "UQCTUO1DBqiU1dwsJRmzuoX_Cd6nK-e3EFUpp05FW7SSwq6K",
        .tron: "TYYRAomNGQGE2B1uLhKREbCmVe4wDW3mKy",
        .solana: "GTqNrvXp9R3ur1Jt8BZw9DUUJFLUY5oXrLBXirDfBkCG",
    ]

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    static var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

    static var appId: String? {
        UIDevice.current.identifierForVendor?.uuidString
    }

    static var appName: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
    }

    static var marketApiUrl: String {
        (Bundle.main.object(forInfoDictionaryKey: "MarketApiUrl") as? String) ?? ""
    }

    static var quantumChainApiBaseUrl: String {
        (Bundle.main.object(forInfoDictionaryKey: "QuantumChainApiBaseUrl") as? String) ?? ""
    }

    static var swapApiUrl: String {
        (Bundle.main.object(forInfoDictionaryKey: "SwapApiUrl") as? String) ?? ""
    }

    static var etherscanKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "EtherscanApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var arbiscanKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "ArbiscanApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var gnosisscanKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "GnosisscanApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var ftmscanKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "FtmscanApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var optimismEtherscanKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "OptimismEtherscanApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var basescanKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "BasescanApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var eraZkSyncKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "EraZkSyncApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var bscscanKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "BscscanApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var polygonscanKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "PolygonscanApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var snowtraceKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "SnowtraceApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var twitterBearerToken: String? {
        (Bundle.main.object(forInfoDictionaryKey: "TwitterBearerToken") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var hsProviderApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "HsProviderApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var quantumChainApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "QuantumChainApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var tronGridApiKeys: [String] {
        ((Bundle.main.object(forInfoDictionaryKey: "TronGridApiKeys") as? String) ?? "").components(separatedBy: ",")
    }

    static var walletConnectV2ProjectKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "WallectConnectV2ProjectKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var unstoppableDomainsApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "UnstoppableDomainsApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var oneInchApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "OneInchApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var oneInchCommissionAddress: String? {
        (Bundle.main.object(forInfoDictionaryKey: "OneInchCommissionAddress") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var oneInchCommission: Decimal? {
        (Bundle.main.object(forInfoDictionaryKey: "OneInchCommission") as? String).flatMap {
            $0.isEmpty ? nil : Decimal(string: $0, locale: Locale(identifier: "en_US_POSIX"))
        }
    }

    static var thorchainAffiliate: String? {
        (Bundle.main.object(forInfoDictionaryKey: "ThorchainAffiliate") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var thorchainAffiliateBps: Int? {
        (Bundle.main.object(forInfoDictionaryKey: "ThorchainAffiliateBps") as? String).flatMap { $0.isEmpty ? nil : Int($0) }
    }

    static var mayaAffiliate: String? {
        (Bundle.main.object(forInfoDictionaryKey: "MayaAffiliate") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var mayaAffiliateBps: Int? {
        (Bundle.main.object(forInfoDictionaryKey: "MayaAffiliateBps") as? String).flatMap { $0.isEmpty ? nil : Int($0) }
    }

    static var uswapApiKey: String? {
        (Bundle.main.object(forInfoDictionaryKey: "USwapApiKey") as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    static var referralAppServerUrl: String {
        (Bundle.main.object(forInfoDictionaryKey: "ReferralAppServerUrl") as? String) ?? ""
    }

    static var defaultWords: String {
        Bundle.main.object(forInfoDictionaryKey: "DefaultWords") as? String ?? ""
    }

    static var defaultPassphrase: String {
        Bundle.main.object(forInfoDictionaryKey: "DefaultPassphrase") as? String ?? ""
    }

    static var defaultWatchAddress: String? {
        Bundle.main.object(forInfoDictionaryKey: "DefaultWatchAddress") as? String
    }

    static var sharedCloudContainer: String? {
        Bundle.main.object(forInfoDictionaryKey: "SharedCloudContainerId") as? String
    }

    static var privateCloudContainer: String? {
        Bundle.main.object(forInfoDictionaryKey: "PrivateCloudContainerId") as? String
    }

    static var openSeaApiKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "OpenSeaApiKey") as? String) ?? ""
    }

}
