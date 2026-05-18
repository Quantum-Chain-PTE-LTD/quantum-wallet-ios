import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var badgeViewModel = MainBadgeViewModel()
    @StateObject var walletViewModel = WalletViewModel()
    @StateObject var transactionsViewModel = TransactionsViewModel()

    @State private var path = NavigationPath()

    @State private var backupAccount: Account?

    var body: some View {
        let _ = Self._printChanges()
        TabView(selection: $viewModel.selectedTab) {
            if viewModel.showMarket {
                ThemeNavigationStack {
                    MarketView()
                        .navigationTitle("market.title".localized)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button(action: openMarketSearch) { Image("search") }
                            }
                        }
                }
                .tabItem { Label("", image: "market_filled") }
                .tag(MainViewModel.Tab.markets)
                .tint(.themeLeah)
            }

            ThemeNavigationStack(path: $path) {
                WalletView(viewModel: walletViewModel, path: $path)
                    .navigationDestination(for: Wallet.self) { wallet in
                        WalletTokenModule.view(wallet: wallet)
                    }
                    .navigationTitle(walletViewModel.account?.name ?? "balance.title".localized)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            if walletViewModel.account != nil {
                                Button(action: openManageAccounts) { Image("wallet_change") }
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            if walletViewModel.account != nil, walletViewModel.totalItem.state == .syncing {
                                syncingProgressView
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            if walletViewModel.account != nil, walletViewModel.buttonHidden {
                                Button(action: openScanQr) { Image("scan") }
                            }
                        }
                    }
            }
            .tabItem { Label("", image: "wallet_filled") }
            .tag(MainViewModel.Tab.wallet)
            .tint(.themeLeah)

            if viewModel.showSwap {
                ThemeNavigationStack {
                    MultiSwapView()
                        .navigationTitle("swap.title".localized)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button(action: openSwapHistory) { Image("clock") }
                            }
                        }
                }
                .tabItem { Label("", image: "swap_filled") }
                .tag(MainViewModel.Tab.swap)
                .tint(.themeLeah)
            }

            ThemeNavigationStack {
                MainSettingsView()
                    .navigationTitle("settings.title".localized)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Label("", image: "settings_filled") }
            .tag(MainViewModel.Tab.settings)
            .badge(badgeViewModel.badge.map { _ in "1" })
            .tint(.themeLeah)
        }
        .tint(.themeJacob)
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
