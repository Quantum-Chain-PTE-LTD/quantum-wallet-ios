import Combine
import Foundation
import MarketKit
import RxSwift

class MainSettingsViewModel: ObservableObject {
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    private let backupManager = Core.shared.backupManager
    private let cloudBackupManager = Core.shared.cloudBackupManager
    private let accountRestoreWarningManager = Core.shared.accountRestoreWarningManager
    private let accountManager = Core.shared.accountManager
    private let contactManager = Core.shared.contactManager
    private let passcodeManager = Core.shared.passcodeManager
    private let termsManager = Core.shared.termsManager
    private let systemInfoManager = Core.shared.systemInfoManager
    private let rateAppManager = Core.shared.rateAppManager
    private let localStorage = Core.shared.localStorage
    private let testNetManager = Core.shared.testNetManager
    private let appStateManager = AppStateManager.instance

    @Published var manageWalletsAlert: Bool = false {
        didSet { print("[VM-DEBUG] manageWalletsAlert -> \(manageWalletsAlert) (was \(oldValue))") }
    }

    @Published var securityAlert: Bool = false {
        didSet { print("[VM-DEBUG] securityAlert -> \(securityAlert) (was \(oldValue))") }
    }

    @Published var aboutAlert: Bool = false {
        didSet { print("[VM-DEBUG] aboutAlert -> \(aboutAlert) (was \(oldValue))") }
    }

    @Published var iCloudUnavailable: Bool = false {
        didSet { print("[VM-DEBUG] iCloudUnavailable -> \(iCloudUnavailable) (was \(oldValue))") }
    }

    @Published var debu: String?

    let showTestSwitchers: Bool

    @Published var forceEnableSwap: Bool {
        didSet {
            localStorage.forceEnableSwap = forceEnableSwap
            appStateManager.sync()
        }
    }

    @Published var testNetEnabled: Bool {
        didSet {
            testNetManager.set(testNetEnabled: testNetEnabled)
        }
    }

    @Published var mayaStagenetEnabled: Bool {
        didSet {
            testNetManager.set(mayaStagenetEnabled: mayaStagenetEnabled)
        }
    }

    @Published var debuggingAmlResult: MultiSwapViewModel.AmlRiskResult? {
        didSet {
            localStorage.debuggingAmlCheckResult = debuggingAmlResult
        }
    }

    init() {
        showTestSwitchers = Bundle.main.object(forInfoDictionaryKey: "ShowTestNetSwitcher") as? String == "true"
        forceEnableSwap = localStorage.forceEnableSwap
        testNetEnabled = testNetManager.testNetEnabled
        mayaStagenetEnabled = testNetManager.mayaStagenetEnabled
        debuggingAmlResult = localStorage.debuggingAmlCheckResult

        subscribe(MainScheduler.instance, disposeBag, backupManager.allBackedUpObservable) { [weak self] _ in self?.syncManageWalletsAlert() }
        subscribe(MainScheduler.instance, disposeBag, contactManager.iCloudErrorObservable) { [weak self] error in
            if error != nil, self?.contactManager.remoteSync ?? false {
                self?.iCloudUnavailable = true
            } else {
                self?.iCloudUnavailable = false
            }
        }

        subscribe(&cancellables, accountRestoreWarningManager.hasNonStandardPublisher) { [weak self] _ in self?.syncManageWalletsAlert() }
        subscribe(&cancellables, passcodeManager.$isPasscodeSet) { [weak self] _ in self?.syncSecurityAlert() }
        subscribe(&cancellables, termsManager.$state) { [weak self] _ in self?.syncAboutAlert() }

        syncManageWalletsAlert()
        syncSecurityAlert()
        syncAboutAlert()
    }

    private func syncManageWalletsAlert() {
        manageWalletsAlert = !backupManager.allBackedUp || accountRestoreWarningManager.hasNonStandard
    }

    private func syncSecurityAlert() {
        securityAlert = !passcodeManager.isPasscodeSet
    }

    private func syncAboutAlert() {
        aboutAlert = !termsManager.state.allAccepted
    }
}

extension MainSettingsViewModel {
    var appVersion: String {
        systemInfoManager.appVersion.description
    }

    func rateApp() {
        rateAppManager.forceShow()
    }
}

extension MainSettingsViewModel {
    enum WalletConnectState {
        case noAccount
        case backedUp
        case nonSupportedAccountType(accountType: AccountType)
        case unBackedUpAccount(account: Account)
    }
}
