import MarketKit

private let fishingBlockchainSupports = EvmBlockchainManager.blockchainTypes + [.stellar, .tron]

enum AddressSecurityIssueType: CaseIterable, Identifiable {
    case phishing
    case blacklisted

    var id: Self {
        self
    }

    var defaultValue: Bool {
        switch self {
        case .phishing: return true
        case .blacklisted: return false
        }
    }

    var storageKey: String {
        switch self {
        case .phishing: return "phishing-check"
        case .blacklisted: return "blacklist-check"
        }
    }

    var checkTitle: String {
        switch self {
        case .phishing: return "send.address.phishing_check".localized
        case .blacklisted: return "send.address.blacklist_check".localized
        }
    }

    var checkSubtitle: String {
        switch self {
        case .phishing: return "send.address.phishing_check.subtitle".localized
        case .blacklisted: return "send.address.blacklist_check.subtitle".localized
        }
    }

    var description: InfoDescription {
        switch self {
        case .phishing: return .init(title: "send.address.phishing_check".localized, description: "send.address.phishing.description".localized)
        case .blacklisted: return .init(title: "send.address.blacklist_check".localized, description: "send.address.blacklist.description".localized)
        }
    }

    var caution: CautionNew {
        switch self {
        case .phishing: return CautionNew(title: "send.address.phishing.caution.title".localized, text: "send.address.phishing.caution.description".localized, type: .error)
        case .blacklisted: return CautionNew(title: "send.address.blacklist.caution.title".localized, text: "send.address.blacklist.caution.description".localized, type: .error)
        }
    }

    func supports(token: Token) -> Bool {
        switch self {
        case .phishing: return fishingBlockchainSupports.contains(token.blockchainType)
        case .blacklisted: return Core.shared.contractAddressValidator.supports(token: token)
        }
    }

    static func issueTypes(token: Token) -> [Self] {
        allCases.filter { $0.supports(token: token) }
    }
}

struct ResolvedAddress: Hashable {
    let address: String
    let issueTypes: [AddressSecurityIssueType]
}
