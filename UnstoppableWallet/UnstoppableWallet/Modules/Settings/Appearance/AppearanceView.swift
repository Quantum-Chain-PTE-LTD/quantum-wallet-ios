import Kingfisher
import SwiftUI

struct AppearanceView: View {
    @StateObject var viewModel = AppearanceViewModel()

    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollableThemeView {
            VStack(spacing: .margin24) {
                // Quantum Wallet enforces dark-only mode (Android parity, commit c13a915e);
                // the theme selector is intentionally hidden.

                ListSection {
                    Cell(
                        middle: {
                            ThemeText("settings.language".localized, style: .headline2)
                        },
                        right: {
                            HStack(spacing: .margin8) {
                                if let language = LanguageManager.shared.currentLanguageDisplayName {
                                    ThemeText(language, style: .subheadSB, colorStyle: .secondary)
                                }

                                Image.disclosureIcon
                            }
                        },
                        action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                openURL(url)
                            }
                        }
                    )

                    NavigationLink(destination: {
                        BaseCurrencySettingsModule.view()
                            .onFirstAppear {
                                stat(page: .appearance, event: .open(page: .baseCurrency))
                            }
                    }) {
                        Cell(
                            middle: {
                                ThemeText("settings.base_currency".localized, style: .headline2)
                            },
                            right: {
                                ThemeText(viewModel.baseCurrencyCode, style: .subheadSB, colorStyle: .secondary).arrow(style: .disclosure)
                            }
                        )
                    }
                    .buttonStyle(CellButtonStyle())
                }

                VStack(spacing: 0) {
                    ListSectionHeader(text: "appearance.markets_tab".localized)
                    ListSection {
                        Cell(
                            middle: {
                                MultiText(title: "appearance.hide_markets".localized, subtitle: "appearance.hide_markets.description".localized)
                            },
                            right: {
                                ThemeToggle(isOn: $viewModel.hideMarkets.animation(), style: .yellow)
                            }
                        )

                        Cell(
                            middle: {
                                MultiText(title: "appearance.price_change".localized, subtitle: "appearance.price_change.description".localized)
                            },
                            right: {
                                ThemeText(title(priceChangeMode: viewModel.priceChangeMode), style: .subheadSB).arrow(style: .dropdown)
                            },
                            action: {
                                Coordinator.shared.present(type: .alert) { isPresented in
                                    OptionAlertView(
                                        title: "appearance.price_change".localized,
                                        viewItems: PriceChangeMode.allCases.map { .init(text: title(priceChangeMode: $0), selected: viewModel.priceChangeMode == $0) },
                                        onSelect: { index in
                                            viewModel.priceChangeMode = PriceChangeMode.allCases[index]
                                        },
                                        isPresented: isPresented
                                    )
                                }
                            }
                        )
                    }
                }

                if !viewModel.hideMarkets {
                    ListSection {
                        Cell(
                            middle: {
                                MultiText(title: "appearance.launch_screen".localized, subtitle: "appearance.launch_screen.description".localized)
                            },
                            right: {
                                ThemeText(viewModel.launchScreen.title, style: .subheadSB).arrow(style: .dropdown)
                            },
                            action: {
                                Coordinator.shared.present(type: .alert) { isPresented in
                                    OptionAlertView(
                                        title: "appearance.launch_screen".localized,
                                        viewItems: LaunchScreen.allCases.map { .init(text: $0.title, selected: viewModel.launchScreen == $0) },
                                        onSelect: { index in
                                            viewModel.launchScreen = LaunchScreen.allCases[index]
                                        },
                                        isPresented: isPresented
                                    )
                                }
                            }
                        )
                    }
                }

                VStack(spacing: 0) {
                    ListSectionHeader(text: "appearance.balance_tab".localized)

                    ListSection {
                        Cell(
                            middle: {
                                MultiText(title: "appearance.hide_buttons".localized, subtitle: "appearance.hide_buttons.description".localized)
                            },
                            right: {
                                ThemeToggle(isOn: $viewModel.hideBalanceButtons.animation(), style: .yellow)
                            }
                        )
                        Cell(
                            middle: {
                                MultiText(title: "appearance.amount_rounding".localized, subtitle: "appearance.amount_rounding.description".localized)
                            },
                            right: {
                                ThemeToggle(isOn: $viewModel.useAmountRounding.animation(), style: .yellow)
                            }
                        )
                        Cell(
                            middle: {
                                MultiText(title: "appearance.balance_value".localized, subtitle: "appearance.balance_value.description".localized)
                            },
                            right: {
                                ThemeText(title(balancePrimaryValue: viewModel.balancePrimaryValue), style: .subheadSB).arrow(style: .dropdown)
                            },
                            action: {
                                Coordinator.shared.present(type: .alert) { isPresented in
                                    OptionAlertView(
                                        title: "appearance.balance_value".localized,
                                        viewItems: BalancePrimaryValue.allCases.map { .init(text: title(balancePrimaryValue: $0), selected: viewModel.balancePrimaryValue == $0) },
                                        onSelect: { index in
                                            viewModel.balancePrimaryValue = BalancePrimaryValue.allCases[index]
                                        },
                                        isPresented: isPresented
                                    )
                                }
                            }
                        )
                    }
                }

                VStack(spacing: 0) {
                    ListSectionHeader(text: "appearance.send_screen".localized)
                    ListSection {
                        Cell(
                            middle: {
                                MultiText(title: "appearance.recently_sent".localized, subtitle: "appearance.recently_sent.description".localized)
                            },
                            right: {
                                ThemeToggle(isOn: $viewModel.showRecentlySent.animation(), style: .yellow)
                            }
                        )
                    }
                }

                // Quantum Wallet ships a single launcher icon (Android parity, commit f023c793).
            }
            .padding(EdgeInsets(top: .margin12, leading: .margin16, bottom: .margin32, trailing: .margin16))
        }
        .navigationTitle("appearance.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    func title(themeMode: ThemeMode) -> String {
        switch themeMode {
        case .system: return "appearance.theme.system".localized
        case .dark: return "appearance.theme.dark".localized
        case .light: return "appearance.theme.light".localized
        }
    }

    func title(balancePrimaryValue: BalancePrimaryValue) -> String {
        switch balancePrimaryValue {
        case .coin: return "appearance.balance_value.coin_fiat".localized
        case .currency: return "appearance.balance_value.fiat_coin".localized
        }
    }

    func title(priceChangeMode: PriceChangeMode) -> String {
        switch priceChangeMode {
        case .hour24: return "appearance.price_change.24h".localized
        case .day1: return "appearance.price_change.1d".localized
        }
    }
}
