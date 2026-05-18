import Kingfisher
import MessageUI
import SwiftUI

struct MainSettingsView: View {
    @StateObject var viewModel = MainSettingsViewModel()
    @Environment(\.openURL) var openURL

    @State private var manageWalletsPresented = false

    var body: some View {
        let _ = Self._printChanges()
        ScrollableThemeView {
            VStack(spacing: .margin12) {
                VStack(spacing: 0) {
                    ListSection {
                        manageWallets()
                        blockchainSettings()
                        security()
                        privacy()
                    }

                    Spacer().frame(height: .margin32)

                    ListSection {
                        contacts()
                    }

                    Spacer().frame(height: .margin32)

                    ListSection {
                        appSettings()
                        backupManager()
                    }

                    Spacer().frame(height: .margin32)

                    ListSection {
                        rateUs()
                        tellFriend()
                    }

                    Spacer().frame(height: .margin24)

                    VStack(spacing: 0) {
                        ListSectionHeader(text: "settings.social_networks.label".localized)

                        ListSection {
                            telegram()
                            twitter()
                        }
                    }

                    // Spacer().frame(height: .margin32)

                    // ListSection {
                    //     donate()
                    // }

                    Spacer().frame(height: .margin32)

                    footer()

                    if viewModel.showTestSwitchers {
                        Spacer().frame(height: .margin32)
                        testSwitchersSection()
                    }
                }
                .padding(.padding16)
            }
            .padding(EdgeInsets(top: .margin12, leading: 0, bottom: .margin32, trailing: 0))
        }
        .onAppear { print("[NAV-DEBUG] MainSettingsView .onAppear") }
        .onDisappear { print("[NAV-DEBUG] MainSettingsView .onDisappear") }
    }

    @ViewBuilder private func manageWallets() -> some View {
        NavigationRow(spacing: .margin8, destination: {
            ManageAccountsView()
                .onAppear { print("[NAV-DEBUG] ManageAccountsView .onAppear") }
                .onDisappear { print("[NAV-DEBUG] ManageAccountsView .onDisappear") }
        }) {
            HStack(spacing: .margin16) {
                ThemeImage("wallet", size: .iconSize24)
                Text("settings.manage_accounts".localized).textBody()
            }

            Spacer()

            if viewModel.manageWalletsAlert {
                Image.warningIcon
            }

            Image.disclosureIcon
        }
    }

    @ViewBuilder private func blockchainSettings() -> some View {
        NavigationRow(destination: {
            BlockchainSettingsModule.view()
                .onAppear { print("[NAV-DEBUG] BlockchainSettings destination .onAppear") }
                .onDisappear { print("[NAV-DEBUG] BlockchainSettings destination .onDisappear") }
                .onFirstAppear {
                    print("[NAV-DEBUG] BlockchainSettings .onFirstAppear")
                    stat(page: .settings, event: .open(page: .blockchainSettings))
                }
        }) {
            ThemeImage("box", size: .iconSize24)
            Text("settings.blockchain_settings".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func security() -> some View {
        NavigationRow(spacing: .margin8, destination: {
            SecuritySettingsView()
                .onAppear { print("[NAV-DEBUG] SecuritySettingsView .onAppear") }
                .onDisappear { print("[NAV-DEBUG] SecuritySettingsView .onDisappear") }
                .onFirstAppear {
                    print("[NAV-DEBUG] SecuritySettingsView .onFirstAppear")
                    stat(page: .settings, event: .open(page: .security))
                }
        }) {
            HStack(spacing: .margin16) {
                ThemeImage("shield", size: .iconSize24)
                Text("settings.security".localized).textBody()
            }

            Spacer()

            if viewModel.securityAlert {
                Image.warningIcon
            }

            Image.disclosureIcon
        }
    }

    @ViewBuilder private func privacy() -> some View {
        NavigationRow(destination: {
            PrivacyPolicyView(config: .privacy)
                .onAppear { print("[NAV-DEBUG] PrivacyPolicyView .onAppear") }
                .onDisappear { print("[NAV-DEBUG] PrivacyPolicyView .onDisappear") }
                .onFirstAppear {
                    print("[NAV-DEBUG] PrivacyPolicyView .onFirstAppear")
                    stat(page: .settings, event: .open(page: .privacy))
                }
        }) {
            ThemeImage("lock", size: .iconSize24)
            Text("settings.privacy".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func tonConnect() -> some View {
        NavigationRow(destination: {
            TonConnectListView()
        }) {
            HStack(spacing: .margin16) {
                Image("ton_connect_24").themeIcon()
                Text("TON Connect").textBody()
            }
            Spacer()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func appSettings() -> some View {
        NavigationRow(destination: {
            AppearanceView()
                .onAppear { print("[NAV-DEBUG] AppearanceView .onAppear") }
                .onDisappear { print("[NAV-DEBUG] AppearanceView .onDisappear") }
                .onFirstAppear {
                    print("[NAV-DEBUG] AppearanceView .onFirstAppear")
                    stat(page: .settings, event: .open(page: .appearance))
                }
        }) {
            ThemeImage("manage", size: .iconSize24)
            Text("settings.appearance".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func contacts() -> some View {
        ClickableRow(spacing: .margin8) {
            Coordinator.shared.present { _ in
                ContactBookView(mode: .edit, presented: true)
                    .ignoresSafeArea()
                    .onFirstAppear {
                        stat(page: .settings, event: .open(page: .contacts))
                    }
            }
        } content: {
            HStack(spacing: .margin16) {
                ThemeImage("user", size: .iconSize24)
                Text("contacts.title".localized).textBody()
            }

            Spacer()

            if viewModel.iCloudUnavailable {
                Image.warningIcon
            }

            Image.disclosureIcon
        }
    }

    @ViewBuilder private func backupManager() -> some View {
        NavigationRow(destination: {
            BackupManagerView()
                .onAppear { print("[NAV-DEBUG] BackupManagerView .onAppear") }
                .onDisappear { print("[NAV-DEBUG] BackupManagerView .onDisappear") }
                .onFirstAppear {
                    print("[NAV-DEBUG] BackupManagerView .onFirstAppear")
                    stat(page: .settings, event: .open(page: .backupManager))
                }
        }) {
            ThemeImage("cloud", size: .iconSize24)
            Text("settings.backup_manager".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func aboutApp() -> some View {
        NavigationRow(spacing: .margin8, destination: {
            AboutModule.view()
                .onFirstAppear {
                    stat(page: .settings, event: .open(page: .aboutApp))
                }
        }) {
            HStack(spacing: .margin16) {
                ThemeImage("information", size: .iconSize24)
                Text("settings.about_app.title".localized).textBody()
            }

            Spacer()

            if viewModel.aboutAlert {
                Image.warningIcon
            }

            Image.disclosureIcon
        }
    }

    @ViewBuilder private func rateUs() -> some View {
        ClickableRow(action: {
            viewModel.rateApp()
            stat(page: .settings, event: .open(page: .rateUs))
        }) {
            ThemeImage("star", size: .iconSize24)
            Text("settings.rate_us".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func tellFriend() -> some View {
        ClickableRow(action: {
            Coordinator.shared.present { _ in
                ActivityView(activityItems: ["settings_tell_friends.text".localized + "\n" + AppConfig.appWebPageLink])
            }
            stat(page: .settings, event: .open(page: .tellFriends))
        }) {
            ThemeImage("arrow_out", size: .iconSize24)
            Text("settings.tell_friends".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func faq() -> some View {
        NavigationRow(destination: {
            FaqView()
                .navigationTitle("faq.title".localized)
                .ignoresSafeArea()
                .onFirstAppear {
                    stat(page: .settings, event: .open(page: .faq))
                }
        }) {
            ThemeImage("message", size: .iconSize24)
            Text("settings.faq".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func academy() -> some View {
        NavigationRow(destination: {
            EducationView().onFirstAppear {
                stat(page: .settings, event: .open(page: .education))
            }
        }) {
            ThemeImage("book", size: .iconSize24)
            Text("education.title".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func telegram() -> some View {
        ClickableRow(action: {
            let appUrl = URL(string: "tg://resolve?domain=\(AppConfig.appTelegramAccount)")!
            let webUrl = URL(string: "https://t.me/\(AppConfig.appTelegramAccount)")!

            if UIApplication.shared.canOpenURL(appUrl) {
                openURL(appUrl)
            } else {
                Coordinator.shared.present(url: webUrl)
            }

            stat(page: .settings, event: .open(page: .externalTelegram))
        }) {
            ThemeImage("telegram_logo", size: .iconSize24)
            Text("Telegram").themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func twitter() -> some View {
        ClickableRow(action: {
            let account = AppConfig.appTwitterAccount

            if let appUrl = URL(string: "twitter://user?screen_name=\(account)"), UIApplication.shared.canOpenURL(appUrl) {
                UIApplication.shared.open(appUrl)
            } else {
                Coordinator.shared.present(url: "https://twitter.com/\(account)")
            }

            stat(page: .settings, event: .open(page: .externalTwitter))
        }) {
            ThemeImage("x_logo", size: .iconSize24)
            Text("Twitter").themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func donate() -> some View {
        ClickableRow(action: {
            Coordinator.shared.present { isPresented in
                DonateTokenListView(isPresented: isPresented)
            }
            stat(page: .settings, event: .open(page: .donate))
        }) {
            Image("heart_24").themeIcon()
            Text("settings.donate.title".localized).themeBody()
            Image.disclosureIcon
        }
    }

    @ViewBuilder private func footer() -> some View {
        VStack(spacing: .margin32) {
            VStack(spacing: 0) {
                Text("\(AppConfig.appName.uppercased()) \(viewModel.appVersion)")
                    .textCaption()
                    .padding(.bottom, .margin8)

                HorizontalDivider()

                Text("settings.info_subtitle".localized)
                    .textMicro()
                    .padding(.top, .margin4)
            }
            .fixedSize(horizontal: true, vertical: false)

            Image("Q Logo Image")
                .onTapGesture {
                    Coordinator.shared.present(url: AppConfig.companyWebPageLink)
                    stat(page: .settings, event: .open(page: .externalCompanyWebsite))
                }
        }
    }

    @ViewBuilder private func testSwitchersSection() -> some View {
        ListSection {
            ListRow {
                Toggle(isOn: $viewModel.forceEnableSwap) {
                    Text("Force Enable Swap").themeBody()
                }
                .toggleStyle(SwitchToggleStyle(tint: .themeYellow))
            }

            ListRow {
                Toggle(isOn: $viewModel.testNetEnabled) {
                    Text("TestNet Enabled").themeBody()
                }
                .toggleStyle(SwitchToggleStyle(tint: .themeYellow))
            }

            ListRow {
                Toggle(isOn: $viewModel.mayaStagenetEnabled) {
                    Text("Maya Stagenet Enabled").themeBody()
                }
                .toggleStyle(SwitchToggleStyle(tint: .themeYellow))
            }

            row(
                title: "AML checking result".localized,
                subtitle: "Oerride checking result from serer".localized,
                value: viewModel.debuggingAmlResult?.rawValue ?? "clear",
                action: {
                    Coordinator.shared.present(type: .alert) { isPresented in
                        OptionAlertView(
                            title: "AML Result".localized,
                            viewItems: [.init(text: "clear".localized, selected: viewModel.debuggingAmlResult == nil)] +
                                MultiSwapViewModel.AmlRiskResult.allCases.map {
                                    AlertViewItem(text: $0.rawValue, selected: viewModel.debuggingAmlResult == $0)
                                },
                            onSelect: { index in
                                switch index {
                                case 0: viewModel.debuggingAmlResult = nil
                                default: viewModel.debuggingAmlResult = MultiSwapViewModel.AmlRiskResult.allCases[index - 1]
                                }
                            },
                            isPresented: isPresented
                        )
                    }
                }
            )
        }
    }

    @ViewBuilder private func row(title: String, subtitle: String, value: String, action: (() -> Void)?) -> some View {
        let enabled = action != nil
        Cell(
            middle: {
                MultiText(title: title, subtitle: subtitle)
            },
            right: {
                ThemeText(
                    value,
                    style: .subheadSB,
                    colorStyle: enabled ? .primary : .secondary
                )
                .arrow(
                    style: .dropdown,
                    colorStyle: enabled ? .primary : .secondary
                )
            },
            action: action
        )
    }
}
