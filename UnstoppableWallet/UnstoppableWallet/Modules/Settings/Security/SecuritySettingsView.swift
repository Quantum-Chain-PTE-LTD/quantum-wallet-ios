import SwiftUI

struct SecuritySettingsView: View {
    @StateObject var viewModel = SecuritySettingsViewModel()

    var body: some View {
        ScrollableThemeView {
            VStack(spacing: .margin32) {
                ListSection {
                    if viewModel.isPasscodeSet {
                        Cell(
                            middle: {
                                MultiText(title: "settings_security.edit_passcode".localized)
                            },
                            right: {
                                Image.disclosureIcon
                            },
                            action: {
                                Coordinator.shared.presentAfterUnlock(biometryAllowed: false) { isPresented in
                                    ThemeNavigationStack { EditPasscodeModule.editPasscodeView(showParentSheet: isPresented) }
                                }
                            }
                        )
                        Cell(
                            middle: {
                                MultiText(title: ComponentText(text: "settings_security.disable_passcode".localized, colorStyle: .red))
                            },
                            action: {
                                Coordinator.shared.performAfterUnlock(biometryAllowed: false) {
                                    viewModel.removePasscode()
                                }
                            }
                        )
                    } else {
                        Cell(
                            middle: {
                                MultiText(title: "settings_security.enable_passcode".localized)
                            },
                            right: {
                                Image.warningIcon
                            },
                            action: {
                                presentCreatePasscode(reason: .regular)
                            }
                        )
                    }
                }

                if let biometryType = viewModel.biometryType {
                    ListSection {
                        Cell(
                            middle: {
                                MultiText(title: biometryType.title)
                            },
                            right: {
                                ThemeText(viewModel.biometryEnabledType.title, style: .subheadSB).arrow(style: .dropdown)
                            },
                            action: {
                                Coordinator.shared.present(type: .alert) { isPresented in
                                    OptionAlertView(
                                        title: biometryType.title,
                                        viewItems: BiometryManager.BiometryEnabledType.allCases.map {
                                            .init(text: $0.title, selected: $0 == viewModel.biometryEnabledType)
                                        },
                                        onSelect: { index in
                                            viewModel.biometryEnabledType = BiometryManager.BiometryEnabledType.allCases[index]
                                        },
                                        isPresented: isPresented
                                    )
                                }
                            }
                        )
                        .onChange(of: viewModel.biometryEnabledType) { type in
                            if !viewModel.isPasscodeSet, type.isEnabled {
                                presentCreatePasscode(reason: .biometry(enabledType: type, type: biometryType))
                            }
                        }
                    }
                }

                ListSection {
                    if viewModel.isPasscodeSet {
                        Cell(
                            middle: {
                                MultiText(title: "settings_security.auto_lock".localized, subtitle: "settings_security.auto_lock.description".localized)
                            },
                            right: {
                                ThemeText(viewModel.autoLockPeriod.title, style: .subheadSB).arrow(style: .dropdown)
                            },
                            action: {
                                Coordinator.shared.present(type: .alert) { isPresented in
                                    OptionAlertView(
                                        title: "settings_security.auto_lock".localized,
                                        viewItems: AutoLockPeriod.allCases.map { .init(text: $0.title, selected: viewModel.autoLockPeriod == $0) },
                                        onSelect: { index in
                                            viewModel.autoLockPeriod = AutoLockPeriod.allCases[index]
                                        },
                                        isPresented: isPresented
                                    )
                                }
                            }
                        )
                    }
                    toggledRow(title: "settings_security.balance_auto_hide".localized, subtitle: "settings_security.balance_auto_hide.description".localized, isOn: $viewModel.balanceAutoHide)

                    toggledRow(title: "transaction_filter.hide_suspicious_txs".localized, subtitle: "transaction_filter.hide_suspicious_txs.description".localized, isOn: $viewModel.spamFilterEnabled)
                }

                securityToolsSection()
            }
            .padding(EdgeInsets(top: .margin12, leading: .margin16, bottom: .margin32, trailing: .margin16))
        }
        .navigationTitle("settings_security.title".localized)
    }

    private func presentCreatePasscode(reason: CreatePasscodeModule.CreatePasscodeReason) {
        Coordinator.shared.present { isPresented in
            ThemeNavigationStack {
                CreatePasscodeModule.createPasscodeView(
                    reason: reason,
                    showParentSheet: isPresented,
                    onCreate: {
                        switch reason {
                        case let .biometry(enabledType, _):
                            viewModel.set(biometryEnabledType: enabledType)
                        case .duress:
                            presentCreateDuressPasscode()
                        default: ()
                        }
                    },
                    onCancel: {
                        switch reason {
                        case .biometry: viewModel.biometryEnabledType = .off
                        default: ()
                        }
                    }
                )
            }
            .interactiveDismiss(canDismissSheet: false)
        }
    }

    private func presentCreateDuressPasscode() {
        Coordinator.shared.present { isPresented in
            ThemeNavigationStack { DuressModeModule.view(showParentSheet: isPresented) }
        }
    }

    @ViewBuilder
    private func securityToolsSection() -> some View {
        VStack(spacing: 0) {
            SectionHeader(image: Image.defenseIcon, text: "settings.security".localized, horizontalInsets: .margin16)

            ListSection {
                Cell(
                    middle: {
                        MultiText(title: "settings_security.secure_send".localized, subtitle: "settings_security.secure_send.description".localized)
                    },
                    right: {
                        HStack(spacing: .margin12) {
                            ThemeToggle(isOn: .constant(viewModel.secureSendEnabled))
                            Image.disclosureIcon
                        }
                    },
                    action: {
                        presentSecureSendSheet()
                    }
                )

                robberyRow()
            }
            .themeListStyle(.bordered)
        }
    }

    private func presentSecureSendSheet() {
        Coordinator.shared.present(type: .bottomSheet) { isPresented in
            SecureSendBottomSheetView(isPresented: isPresented)
        }
    }

    @ViewBuilder
    private func toggledRow(title: CustomStringConvertible, subtitle: CustomStringConvertible, isOn: Binding<Bool>) -> some View {
        Cell(
            middle: {
                MultiText(title: title, subtitle: subtitle)
            },
            right: {
                ThemeToggle(isOn: isOn)
            }
        )
    }

    @ViewBuilder
    private func toggledRow(title: CustomStringConvertible, subtitle: CustomStringConvertible, isOn: Bool) -> some View {
        Cell(
            middle: {
                MultiText(title: title, subtitle: subtitle)
            },
            right: {
                ThemeToggle(isOn: .constant(isOn))
            }
        )
    }

    @ViewBuilder
    private func robberyRow() -> some View {
        Cell(
            middle: {
                MultiText(title: "settings_security.robbery_protection".localized, subtitle: "settings_security.robbery_protection.description".localized)
            },
            right: {
                if viewModel.isDuressPasscodeSet {
                    HStack(spacing: .margin12) {
                        Button {
                            Coordinator.shared.presentAfterUnlock { isPresented in
                                ThemeNavigationStack { EditPasscodeModule.editDuressPasscodeView(showParentSheet: isPresented) }
                            }
                        } label: {
                            Image("pen")
                        }
                        .buttonStyle(SecondaryCircleButtonStyle())

                        Button {
                            Coordinator.shared.performAfterUnlock {
                                viewModel.removeDuressPasscode()
                            }
                        } label: {
                            Image("trash")
                        }
                        .buttonStyle(SecondaryCircleButtonStyle())
                    }
                } else {
                    Button {
                        if viewModel.isPasscodeSet {
                            Coordinator.shared.performAfterUnlock {
                                presentCreateDuressPasscode()
                            }
                        } else {
                            presentCreatePasscode(reason: .duress)
                        }
                    } label: {
                        Text("button.add".localized)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        )
    }
}
