import MarketKit

protocol IAddressSecurityChecker {
    func isClear(address: Address, token: Token) async throws -> Bool
}

enum AddressSecurityCheckerFactory {
    static func addressSecurityChecker(type: AddressSecurityIssueType) -> IAddressSecurityChecker {
        switch type {
        case .phishing: return SpamAddressDetector()
        case .blacklisted: return Core.shared.contractAddressValidator
        }
    }
}
