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
| ac81e72b | 2026-04-18 | adapter factory wiring | Wiring | ✅ | `AdapterFactory` routes `.quantumChain` |
| 519e020e | 2026-04-18 | exhaustive when branches | Routing | 🟡 | Audit needed: address validators, balance UI, swap info, send routing, watch address |
| 3dd0d4170 | 2026-04-18 | spam detection (QuantumTransactionEventExtractor) | Spam | 🟡 | `SpamManager` exists, but no Quantum-specific extractor for `OutgoingQip20Decoration` |
| b399aa16 | 2026-04-19 | icon infra, donation address, fee scale | Config | 🟡 | Donation address present; fee scale + icon manifest need verification |
| 741ef572 | 2026-04-19 | add-token + restore flows | UI | 🟡 | Restore present; native-token hardcoded fallback when MarketKit omits needs audit |
| ed508a23 | 2026-04-19 | send flow + transaction handling | Send | ✅ | `SendNew/Qvm*.swift` present per commit `4e257b036` |
| faf9c9c6 | 2026-04-27 | hide market data for Quantum tokens | UI | ❌ | No `hasMarketData` per-chain logic on iOS |
| 96e4f19d | 2026-04-27 | Quantum price source routing infra | Price | ❌ | No `PriceSourceRouter`, `QuantumPriceApi`, `TokenPriceMappingConfig` |
| eef9474b | 2026-04-27 | wire price source router into MarketKitWrapper | Price | ❌ | MarketKit wrapper has no router integration |
| faf9c9c6 (subset) | 2026-04-27 | restore 5-item terms list | Terms | ❌ | `TermsManager` generic; canonical 5-item list missing |
| 86c7860e | 2026-05-13 | FullCoinsProvider QRC20 filter + backup prefix | Tokens / Backup | 🟡 | Backup filename still `UW_Backup_*` likely; QRC20 filter logic needs port |
| 90c385c1, b67e81e6 | 2026-04-15 | remove WalletConnect | Removal | 🔁 | `Modules/WalletConnect/` present on iOS |
| a636a96a, a0664ff7 | 2026-04-14/15 | remove subscriptions/premium | Removal | 🔁 | `SubscriptionManager`, `PurchaseManager`, premium cells present |
| b6954986 | 2026-04-19 | hide swap entry; quantum.money → quantum.wallet | Removal | 🔁 | Swap tab present; host audit needed |
| 2698f57e | 2026-04-19 | IntroActivity → 2s splash | UI | 🔁 | iOS Welcome carousel still has 3 slides |
| 79dd2877 | 2026-04-19 | simplify settings | UI | 🔁 | Settings still has theme selector, icon chooser, Support/About/FAQ/Guides |
| c13a915e | 2026-04-19 | dark-only mode + blue accent | Theme | 🔁 | iOS theme switching present; yellow accent `#FFB700` likely still in assets |
| f023c793 | 2026-04-19 | remove alternate launcher icons | Resources | ⛔ | iOS uses different icon system |
| Many | 2026-03 → 2026-04 | rebrand strings/packages | Branding | ✅ | Already landed on iOS |

## Pending work (this PR addresses)

The remaining work to reach parity is grouped as:

- **Group A — runtime correctness:** A1 chain config simplification, A2 spam extractor, A3 QRC20 filter + backup prefix.
- **Group B — new features:** B4 price source router, B5 `hasMarketData` per-chain.
- **Group C — UI parity:** C6 5-item terms, C7 dark-only + accent, C8 splash, C9 swap hide, C10 settings simplification.
- **Group D — removals:** D11 WalletConnect, D12 subscriptions/premium.

Statuses will be updated after each commit lands.
