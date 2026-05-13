import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var badgeViewModel = MainBadgeViewModel()
    @StateObject var walletViewModel = WalletViewModel()
    @StateObject var transactionsViewModel = TransactionsViewModel()

    @State private var path = NavigationPath()

    @State private var backupAccount: Account?

    var body: some View {
        ThemeNavigationStack(path: $path) {
            TabView(selection: $viewModel.selectedTab) {
                if viewModel.showMarket {
                    MarketView()
                        .tabItem { Label("", image: "market_filled") }
                        .tag(MainViewModel.Tab.markets)
                        .tint(.themeLeah)
                }

                WalletView(viewModel: walletViewModel, path: $path)
                    .tabItem { Label("", image: "wallet_filled") }
                    .tag(MainViewModel.Tab.wallet)
                    .tint(.themeLeah)

                if viewModel.showSwap {
                    MultiSwapView()
                        .tabItem { Label("", image: "swap_filled") }
                        .tag(MainViewModel.Tab.swap)
                        .tint(.themeLeah)
                }

                MainSettingsView()
                    .tabItem { Label("", image: "settings_filled") }
                    .tag(MainViewModel.Tab.settings)
                    .badge(badgeViewModel.badge.map { _ in "1" })
                    .tint(.themeLeah)
            }
            .tint(.themeJacob)
            .navigationDestination(for: Wallet.self) { wallet in
                WalletTokenModule.view(wallet: wallet)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    primaryToolbarView
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingProgressToolbarView
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingActionToolbarView
                }
            }
        }
    }

    private var primaryToolbarView: AnyView {
        switch viewModel.selectedTab {
        case .markets:
            return AnyView(Button(action: openMarketSearch) {
                Image("search")
            })
        case .wallet:
            guard walletViewModel.account != nil else {
                return AnyView(EmptyView())
            }

            return AnyView(Button(action: openManageAccounts) {
                Image("wallet_change")
            })
        case .swap:
            return AnyView(Button(action: openSwapHistory) {
                Image("clock")
            })
        case .transactions:
            return AnyView(Button(action: openTransactionFilter) {
                Image("manage_2_24")
                    .modifier(ToolbarBadgeModifier(visible: transactionsViewModel.transactionFilter.hasChanges))
            })
        case .settings:
            return AnyView(EmptyView())
        }
    }

    private var leadingProgressToolbarView: AnyView {
        switch viewModel.selectedTab {
        case .wallet where walletViewModel.account != nil && walletViewModel.totalItem.state == .syncing:
            return AnyView(syncingProgressView)
        case .transactions where transactionsViewModel.syncing:
            return AnyView(syncingProgressView)
        default:
            return AnyView(EmptyView())
        }
    }

    private var leadingActionToolbarView: AnyView {
        if viewModel.selectedTab == .wallet, walletViewModel.account != nil, walletViewModel.buttonHidden {
            return AnyView(Button(action: openScanQr) {
                Image("scan")
            })
        }

        return AnyView(EmptyView())
    }

    private var syncingProgressView: some View {
        ProgressView(value: 0.55)
            .progressViewStyle(DeterminiteSpinnerStyle())
            .frame(size: 24)
            .spinning()
    }

    private func openMarketSearch() {
        Coordinator.shared.present { isPresented in
            MarketSearchView(isPresented: isPresented)
        }
        stat(page: .markets, event: .open(page: .marketSearch))
    }

    private func openManageAccounts() {
        Coordinator.shared.present { isPresented in
            ThemeNavigationStack { ManageAccountsView(isPresented: isPresented) }
        }
        stat(page: .balance, event: .open(page: .manageWallets))
    }

    private func openScanQr() {
        Coordinator.shared.present { isPresented in
            ScanQrViewNew(reportAfterDismiss: true, isPresented: isPresented) { text in
                walletViewModel.process(scanned: text)
            }
            .ignoresSafeArea()
        }
        stat(page: .balance, event: .open(page: .scanQrCode))
    }

    private func openSwapHistory() {
        Coordinator.shared.present { isPresented in
            SwapHistoryView(isPresented: isPresented)
        }
    }

    private func openTransactionFilter() {
        Coordinator.shared.present { isPresented in
            TransactionFilterView(transactionsViewModel: transactionsViewModel, isPresented: isPresented)
        }
        stat(page: .transactions, event: .open(page: .transactionFilter))
    }

    var title: String {
        switch viewModel.selectedTab {
        case .markets:
            return "market.title".localized
        case .wallet:
            return walletViewModel.account?.name ?? "balance.title".localized
        case .swap:
            return "swap.title".localized
        case .transactions:
            return "transactions.title".localized
        case .settings:
            return "settings.title".localized
        }
    }
}

extension MainView {
    struct BadgeView: View {
        private let emptyBadgeSize: CGFloat = 10
        @State private var textHeight: CGFloat = 0

        let badge: String

        var body: some View {
            if badge.isEmpty {
                Circle()
                    .foregroundStyle(Color.themeRed)
                    .frame(width: emptyBadgeSize, height: emptyBadgeSize)
            } else {
                Text(badge)
                    .font(.themeMicro)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 2)
                    .frame(minWidth: textHeight)
                    .background(
                        GeometryReader { geometry in
                            Color.themeRed
                                .onAppear {
                                    textHeight = geometry.size.height
                                }
                        }
                    )
                    .clipShape(Capsule())
            }
        }
    }
}

struct AccountsLostView: View {
    let records: [AccountRecord]
    @Binding var isPresented: Bool

    var body: some View {
        BottomSheetView(
            items: [
                .title(icon: ThemeImage.warning, title: "lost_accounts.warning_title".localized),
                .text(text: "lost_accounts.warning_message".localized(records.map { "- \($0.name)" }.joined(separator: "\n"))),
                .buttonGroup(.init(buttons: [
                    .init(style: .yellow, title: "button.i_understand".localized) {
                        isPresented = false
                    },
                ])),
            ]
        )
    }
}

struct ToolbarBadgeModifier: ViewModifier {
    let visible: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if visible {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 3, y: -3)
                }
            }
    }
}
