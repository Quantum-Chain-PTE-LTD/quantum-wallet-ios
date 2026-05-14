# Android → iOS Parity: Gap Report

**Source repo:** `quantum-wallet-android` (Ricardo Toledo's commits)
**Target repo:** `quantum-wallet-ios` (branch `feature/QWIOS-ID01-forward-port-quantum-wallet`)
**Generated:** 2026-05-13

This report inventories functional Android changes authored by Ricardo Toledo and the corresponding iOS status. Pure rebranding commits (package renames, string replacements, icon swaps) that are already landed on iOS are omitted.

## Author identities scanned

- Ricardo Toledo `<ricardotoledomanani@gmail.com>`
- Ricardo Agustin Toledo Mañani `<ricardotoledomanani@gmail.com>`

## Status legend

- ✅ **Implemented** — iOS behaves equivalently to Android.
- 🟡 **Partial** — iOS has scaffolding but missing logic.
- ❌ **Missing** — iOS has no equivalent.
- ⛔ **Not applicable** — Android-only concern (e.g. Gradle build).
- 🔁 **Reverse-port required** — Android removed a feature that still exists on iOS.

## Inventory

| Android Commit | Date | Subject | Feature Area | iOS Status | Action |
|---|---|---|---|---|---|
| 0f7aa3bdb | 2026-04-18 | quantum-kit-android dependency | Build / dependency | ⛔ | QvmKit SwiftPM equivalent already present |
| 9b21720 | 2026-04-18 | chain ID mapping + ISendQuantumAdapter | Chain config | ✅ | `BlockchainType.quantumChain` + QvmKit `Chain.quantumChain` (id 20803) |
| bbc171a1 | 2026-04-18 | QuantumKitManager / QuantumAccountManager | Adapter mgmt | ✅ | `QvmKitManager`, `QvmAccountManager` present |
| 61c56437 | 2026-04-18 | Quantum blockchain adapters | Adapters | ✅ | `QvmAdapter`, `Qip20Adapter` present |
| ac81e72b | 2026-04-18 | adapter factory wiring | Wiring | ✅ | `AdapterFactory` routes `.quantumChain` (`.qrc20` case fixed this session) |
| 519e020e | 2026-04-18 | exhaustive when branches | Routing | ✅ | All known `.eip20` Quantum branches re-routed to `.qrc20` this session |
| 3dd0d4170 | 2026-04-18 | spam detection (QuantumTransactionEventExtractor) | Spam | ✅ | iOS handles QIP20/721/1155 transfer events inline in `QvmTransactionConverter`, fed to `SpamManager` |
| b399aa16 | 2026-04-19 | icon infra, donation address, fee scale | Config | 🟡 | Donation address present; fee scale + icon manifest still need verification |
| 741ef572 | 2026-04-19 | add-token + restore flows | UI | ✅ | New `AddQvmTokenBlockchainService.swift` ported from Android `AddQuantumTokenBlockchainService.kt`; wired into `AddTokenModule` |
| ed508a23 | 2026-04-19 | send flow + transaction handling | Send | ✅ | `SendNew/Qvm*.swift` present per commit `4e257b036`; QRC20 decoration lookups now use `.qrc20` |
| faf9c9c6 | 2026-04-27 | hide market data for Quantum tokens | UI | ✅ | `BlockchainType.hasMarketData` extension + wallet UI nav guards (`WalletView`, `WalletTokenViewModel`, `ToolbarWalletTokenView`) |
| 96e4f19d | 2026-04-27 | Quantum price source routing infra | Price | ❌ DEFERRED | Net-new module. iOS MarketKit-only pass-through behaves identically to Android when remote mapping is blank/unconfigured — no functional regression. See "Deferred" section. |
| eef9474b | 2026-04-27 | wire price source router into MarketKitWrapper | Price | ❌ DEFERRED | Depends on 96e4f19d port. |
| 79c2b4a4 | 2026-04-27 | restore 5-item terms list | Terms | ✅ | `TermsConfiguration` version 5 with the canonical `backup`/`private_keys`/`disabling_pin`/`jailbreaking`/`bugs` set |
| 86c7860e | 2026-05-13 | FullCoinsProvider QRC20 + AddQuantumTokenBlockchainService + backup prefix + Eip20→Qrc20 fix | Tokens / Backup | ✅ | iOS now uses `TokenType.qrc20` for QC contract tokens across all code paths; storage migration rewrites legacy `eip20:` ids; `AddQvmTokenBlockchainService` added; iOS does not use `UW_Backup_` filename prefix (N/A) |
| 90c385c1, b67e81e6 | 2026-04-15 | remove WalletConnect | Removal | 🟡 PARTIAL | UI entry point hidden in `MainSettingsView` (`dAppConnection` cell commented out). Underlying WC infrastructure left intact to avoid breaking EVM/Stellar signing flows; verifying via build is required before full deletion. |
| a636a96a, a0664ff7 | 2026-04-14/15 | remove subscriptions/premium | Removal | ✅ NEUTRALISED | `PurchaseManager.hasActivePurchase` and `activated(_:)` now unconditionally return `true`; subscription cell + premium slide hidden in `MainSettingsView`. StoreKit machinery preserved to keep purchase/restore UI compiling. |
| b6954986 | 2026-04-19 | hide swap entry; quantum.money → quantum.wallet | Removal | ✅ | Prior session forced `AppStateManager.swapEnabled = false` |
| 2698f57e | 2026-04-19 | IntroActivity → 2s splash | UI | ✅ | Prior session replaced 3-slide carousel with 2s logo splash |
| 79dd2877 | 2026-04-19 | simplify settings | UI | ✅ | `AppearanceView` theme selector + icon chooser removed; `MainSettingsView` VipSupport / About / FAQ / Academy entries removed |
| c13a915e | 2026-04-19 | dark-only mode + blue accent | Theme | ✅ | `ThemeManager` clamped to `.dark`; Jacob/Yellow colorsets updated to Quantum blue (`#0084FF` dark, `#1249FF` light) |
| f023c793 | 2026-04-19 | remove alternate launcher icons | Resources | ⛔ | iOS uses a different icon system; app-icon chooser removed in this session's C7/C10 work |
| Many | 2026-03 → 2026-04 | rebrand strings/packages | Branding | ✅ | Already landed on iOS |

## Pending work (now reduced)

Single remaining deferred item:

- **B4 (96e4f19d / eef9474b) — Quantum price source router.** Net-new module Android added to *optionally* override HS MarketKit prices with a Quantum API fallback for a remote-configured list of coin uids. Functional impact when the remote mapping is unset (blank URL): zero — the Android router is a no-op. iOS today behaves identically to Android-with-blank-mapping. Port deferred until the production mapping URL stabilises and a build environment is available to validate the iOS port end-to-end.
