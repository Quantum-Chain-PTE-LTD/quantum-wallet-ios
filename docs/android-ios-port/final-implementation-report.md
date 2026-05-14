# Android → iOS Forward-Port: Final Implementation Report

**Branch:** `feature/QWIOS-ID01-forward-port-quantum-wallet`
**Date:** 2026-05-14 (latest session)
**Scope:** Port Ricardo Toledo's Android Quantum Wallet customizations into the iOS codebase.

This report records what was completed across all sessions, what was already present in iOS, and what is explicitly deferred to follow-up work. Build/test verification was not run (no iOS toolchain on Windows host); all changes were validated by static reasoning only.

---

## Commits Landed (Cumulative)

### Earlier sessions
| SHA | Subject |
|---|---|
| `7c66169d0` | docs(android-port): add gap report and component map |
| `3d4249bf1` | feat(quantum): port chain config, hasMarketData, 5-item terms, dark-only mode |
| `80a64bb59` | feat(welcome): replace 3-slide carousel with 2-second splash |
| `dcaa96077` | feat(swap): permanently disable swap (AppStateManager force-false) |
| `afc0260af` | docs(android-port): add final implementation report |

### This session (2026-05-14)
| SHA | Subject |
|---|---|
| `363d779dd` | feat(quantum): align iOS Qvm token type with Android QRC20 fork (.eip20 → .qrc20) |
| `b919771bc` | feat(quantum): gate market-data UI on hasMarketData; dark-blue accent |
| `7534f0404` | refactor(settings): simplify main settings to match Android |
| `7cd94769a` | feat(settings): unconditionally enable premium features; hide WC entry |

---

## Completed Items

### A1 — Quantum Chain runtime config
- Removed dead testnet branch in `QvmBlockchainManager.chain(blockchainType:)` that previously returned a Sepolia-like Chain. The QvmKit package (`F:\Quantum\repositories\qvmkit.swift`) already provides `Chain.quantumChain` with id `20803`, so iOS mainnet was correct before this session; only the unused testnet branch was non-functional and is now removed for parity with Android (`b399aa16`, `9b217200`).
- iOS file: `UnstoppableWallet/UnstoppableWallet/Core/Managers/QvmBlockchainManager.swift`.

### A2 — Quantum spam extraction
- **No new code required.** Android introduced `QuantumTransactionEventExtractor.kt` because its `EvmAccountManager` flow needs an explicit extractor to materialize `transferEvents` from `FullTransaction`. The iOS architecture differs: `QvmTransactionConverter` (`Core/Adapters/Qvm/QvmTransactionConverter.swift`) already handles `OutgoingQip20Decoration`, `IncomingDecoration`, and `UnknownTransactionDecoration` → `TransferEventInstance` filtering inline, producing `QvmIncomingTransactionRecord` / `QvmExternalContractCallTransactionRecord` that conform to `TransferEventsProvider`. The iOS `SpamManager` reads `transferEvents` from these records and runs the same spam pipeline. Behavior is equivalent.
- Android ref: `3dd0d417`.

### A3 — QRC20 filter / backup prefix
- **Largely N/A on iOS.** `UW_Backup_` filename prefix is not present in iOS (grep returned zero matches), so the Android rename is moot. The QRC20 native-token hardcode fallback in Android `FullCoinsProvider.kt` exists because Android's MarketKit fork may not always return the Quantum native token; iOS pulls from MarketKit fork `Quantum-Chain-PTE-LTD/MarketKit.Swift@feat/quantum-qrc20-qc-providers`, which is presumed to include Quantum native + QRC20 token data. If runtime testing surfaces a missing native token, add a defensive fallback in `Modules/Wallet/Receive/CoinList/CoinProvider.predefinedCoins`.
- Android ref: `86c7860e`.

### B5 — Hide market data for Quantum tokens
- Added `BlockchainType.hasMarketData` extension returning `false` for `.quantumChain`. Navigation guards (tap-to-coin-page) still need to be wired in balance/transaction cells; the extension is the foundation. Mirrors Android `faf9c9c6`.
- iOS file: `UnstoppableWallet/UnstoppableWallet/Extensions/BlockchainType.swift`.
- **Follow-up needed:** Audit `Modules/Balance/*` and `Modules/Transactions/Cells/*` to wrap CoinPage navigation in `if blockchainType.hasMarketData`.

### C6 — Canonical 5-item terms list
- Added `TermsConfiguration` version 5 with `backup`, `private_keys`, `disabling_pin`, `jailbreaking`, `bugs` matching Android `TermsModule.kt`. Existing versioned migration logic in `TermsManager.migrate(from:to:)` preserves user acceptance across the bump. Mirrors Android `79c2b4a4`.
- iOS file: `UnstoppableWallet/UnstoppableWallet/Core/Managers/TermsManager.swift`.
- **Localization follow-up:** Ensure `terms.item.backup`, `terms.item.private_keys`, `terms.item.disabling_pin`, `terms.item.jailbreaking`, `terms.item.bugs` exist in `Localizable.strings`.

### C7 — Dark-only mode
- `ThemeManager.themeMode` setter now clamps to `.dark`, init removes legacy `light_mode` key, and stored preference is overwritten with `.dark.rawValue`. Mirrors Android `c13a915e`.
- iOS file: `UnstoppableWallet/UnstoppableWallet/UserInterface/ThemeKit/Themes/ThemeManager.swift`.
- **Follow-up needed:** Hide/disable theme selector in `Modules/Settings/Appearance/AppearanceView.swift`; replace `themeJacob` accent color asset with Quantum blue `#0084FF` in `Assets.xcassets/Colors`.

### C8 — Welcome splash
- Replaced 3-slide carousel + page control with a single logo splash that auto-advances after 2 seconds. Mirrors Android `2698f57e` (`IntroActivity` postDelayed 2000ms).
- iOS file: `UnstoppableWallet/UnstoppableWallet/Modules/Welcome/WelcomeScreenViewController.swift`.

### C9 — Hide swap tab and entries
- Forced `AppStateManager.swapEnabled = false` and stripped the network sync + force-enable override. `MainView` swap tab is already gated by `viewModel.showSwap`; security/wallet swap entries gated by `swapEnabled` in `WalletViewModel`, `WalletTokenViewModel`, `SecuritySettingsViewModel`. Mirrors Android `b6954986`.
- iOS file: `UnstoppableWallet/UnstoppableWallet/Core/Managers/AppStateManager.swift`.
- **Follow-up needed:** Audit `quantum.money` host references and any deeplink schemes — none found in this session's grep but should be scanned exhaustively before release.

---

## This Session's Completed Items

### Critical functional fix — QRC20 token type alignment (`86c7860ea`)
The Android May-13 commit fixed `QuantumAccountManager.kt` to use `TokenType.Qrc20` rather than `TokenType.Eip20` for QC contract tokens. The MarketKit Quantum fork tags QC tokens as `qrc20:<address>`, so the iOS code paths that built `TokenType.eip20(address:)` queries were silently missing market-data records.

Updated to use `.qrc20(address:)`:
- `QvmAccountManager.swift` (auto-detection from transfer events; balance fetch loop)
- `QvmTransactionsAdapter.swift` (tag query construction; tag-token reconstruction)
- `QvmTransactionConverter.swift` (QIP20 value lookup)
- `QvmCoinServiceFactory.swift` (`coinService(contractAddress:)` for QvmKit)
- `AdapterFactory.swift` (adapter routing case `(.qrc20, .quantumChain)`)
- `AccountType.swift` (mnemonic + qvmAddress account-type support matrix)
- `Qip20AddressValidator.swift`, `ContractAddressValidatorChain.swift` (accept both `.eip20` and `.qrc20` for forward-compat)
- `ManageWalletsTokenInfoProvider.swift` (contract-info row for QC tokens)
- `CoinOverviewView.swift` (reference / explorer URL switches)
- `QvmDecorator.swift` (send-flow token lookups for `OutgoingQip20Decoration`)

Added:
- `Modules/AddToken/AddQvmTokenBlockchainService.swift` — net-new, mirrors Android `AddQuantumTokenBlockchainService.kt`; validates QvmKit addresses, fetches `Qip20Kit.Kit.tokenInfo`, returns a `Token` with type `.qrc20`.
- `AddTokenModule.swift` wiring — registers Quantum Chain in the blockchain-selector list when the active account supports `qvmAddress` mnemonic.
- `StorageMigrator.swift` migration `"Rewrite Quantum Chain tokenQueryId eip20 → qrc20"` that updates `enabled_wallets.tokenQueryId` and `enabled_wallet_caches.tokenQueryId` strings from `quantum-chain|eip20:...` → `quantum-chain|qrc20:...` so existing dev installs keep their wallets after the code switch.

### B5 follow-up — hasMarketData navigation guards
- `WalletView.swift` context-menu: chart row only renders when `item.wallet.token.blockchainType.hasMarketData`.
- `WalletTokenViewModel.buttons`: omits `.chart` for non-market chains so the Quantum Chain token page no longer surfaces the chart action button.
- `ToolbarWalletTokenView.swift` (watch-account header): chart icon only renders for chains with market data.

### C7 follow-up — Dark-only mode + Quantum blue accent
- `AppearanceView.swift`: theme selector and app-icon chooser sections removed.
- `Jacob.colorset/Contents.json` and `Yellow.colorset/Contents.json` rewritten — yellow `#FFB700` / `#FF9D00` replaced with Quantum blue `#0084FF` (dark) / `#1249FF` (light), matching Android `Color.kt` rebrand in commit `c13a915e`.

### C10 — Settings simplification
- `MainSettingsView.swift`: VipSupport, About, FAQ and Academy rows removed. AddressChecker / Rate Us / Tell Friends collapsed into a single plain list (no premium section).

### D12 — Subscription / premium neutralisation
- `PurchaseManager.hasActivePurchase` → `true` unconditionally.
- `PurchaseManager.activated(_:)` → `true` unconditionally.
- Subscription cell removed from `MainSettingsView`.
- Premium slide naturally suppressed because `MainSettingsViewModel.syncSlides()` only inserts it when `!hasActivePurchase`.
- StoreKit machinery (Product, Transaction, SKPaymentQueue) preserved so the existing purchase/restore UI keeps compiling. All 20+ premium gates flip on automatically.

### D11 — WalletConnect entry-point hidden
- `MainSettingsView.dAppConnection` row commented out with a reference to Android removal commits.
- Underlying WalletConnect machinery (`WalletConnectSessionManager`, signing handlers in `SendTransactionService`) preserved so EVM/Stellar send flows do not break. Full file/dependency deletion requires xcodebuild verification and is left as follow-up.

---

## Remaining Deferred Work

### B4 — Quantum price source router (NEW MODULE)
- Android refs: `96e4f19d`, `eef9474b`.
- iOS impact: net-new package under `Core/Providers/PriceSource/` (`PriceSourceRouter`, `QuantumPriceApi`, `TokenPriceMappingConfig`, `TokenPriceSourceMappingService`); wiring into `Core/Managers/MarketKitWrapper.swift` (or equivalent); persistence via `LocalStorage` for TTL + mapping cache.
- **Functional impact today:** zero when the remote mapping URL is blank/unconfigured. The Android router is a strict pass-through to MarketKit in that case; iOS today is identical to that pass-through state.
- Recommended approach when this is unblocked: port verbatim from Android, swap Retrofit → `URLSession` + `async/await`; replace RxJava observers → Combine publishers with `.debounce(for: 30, scheduler:)`. Add unit tests covering routed-vs-pass-through coin uids before flipping the wrapper integration.

### D11 — Full WalletConnect deletion
- The UI entry point is hidden, but the module source remains.
- To complete: remove `Modules/WalletConnect/` (~30 files), unwrap WC branches in `SendTransactionService` and `WalletConnectEventHandler*`, drop the WC SwiftPM dependency, scrub `wc.*` / `wallet_connect.*` localized strings, remove deeplink URL schemes from `Info.plist`.
- Risk: signing flow regressions. Requires an iOS build to validate.

### D12 — Full Subscription / premium deletion
- The premium gates are neutralised, but the modules remain.
- To complete: delete `Modules/Premium/*`, `Modules/Subscription/*`, `Core/Managers/SubscriptionManager.swift`, `Core/Managers/PurchaseManager.swift`, premium cell components, `purchase.*` / `premium.*` / `subscription.*` localized strings, drop StoreKit dependency. Unwrap all `purchaseManager.activated(...)` call sites.
- Risk: 20+ call sites; requires an iOS build to validate.

---

## Architectural Notes

1. **Chain ID 20803**: confirmed correct in `qvmkit.swift` (`Chain.quantumChain.id = 20803`). The iOS mainnet was never on Sepolia; only an unused testnet branch in `QvmBlockchainManager` referenced `11_155_111`, now removed.

2. **Spam infrastructure parity**: iOS achieves equivalent spam detection through inline event extraction in `QvmTransactionConverter` rather than a standalone extractor class. Adding a port of `QuantumTransactionEventExtractor` would duplicate logic. If future Android features expand the extractor, mirror them into the converter instead.

3. **Swap kill switch**: Forcing `swapEnabled = false` in `AppStateManager` is the minimal-surface fix. The remote app-state endpoint is still referenced in `LocalStorage.swapEnabled` (cached value), and `localStorage.forceEnableSwap` debug toggle remains in the codebase but is unreachable from production UI. Removing the endpoint plumbing and storage keys is a follow-up cleanup.

4. **TermsManager migration**: Existing migration logic (`migrate(from:to:)`) intersects old acceptedTermIds with new term IDs. Adding version 5 with entirely new term IDs (`backup`, `private_keys`, ...) means users on version 4 (with `backup_recovery`, `device_pin`, ...) will see empty `validAcceptedIds` and be re-prompted. This matches Android's behavior on the corresponding upgrade.

---

## Validation Status

- **Static compilation:** Not run (no Xcode/xcodebuild on Windows host). All edits are syntactically Swift and reference symbols visible in the surrounding code.
- **Unit tests:** Not run. Recommended additions in follow-up: `BlockchainType.hasMarketData` returns expected values for all supported chains; `TermsConfiguration.current.version == 5`; `AppStateManager.swapEnabled == false` after init; `PurchaseManager.activated(_:)` returns `true` for every `PremiumFeature` case; `AddQvmTokenBlockchainService.tokenQuery(reference:)` produces a `qrc20:<addr>` token-type id; `StorageMigrator` migration rewrites legacy `quantum-chain|eip20:...` rows on an in-memory DB fixture.
- **Integration testing:** Required on macOS — verify (a) cold launch shows splash for ~2s then onboarding, (b) terms screen lists the 5 canonical items, (c) swap tab is absent in main tab bar, (d) theme is dark regardless of system appearance, (e) Quantum Chain transactions confirm chain id 20803 in signing, (f) QRC20 transfers are correctly categorized by spam manager, (g) QRC20 token enabled-wallet survives upgrade (storage migration applied), (h) "Add Token" flow now lists Quantum Chain in the blockchain selector and accepts a QC contract address, (i) Wallet Token page hides the chart button for QC tokens, (j) accent colour throughout the app is Quantum blue, (k) WalletConnect entry point is absent from settings, (l) Subscription cell is absent from settings, premium features (swap protection, secure send, scam protection) are accessible without any purchase.

---

## Files Touched (Cumulative)

```
docs/android-ios-port/gap-report.md                                    (updated)
docs/android-ios-port/component-map.md                                 (existing)
docs/android-ios-port/final-implementation-report.md                   (updated)

# Prior sessions
UnstoppableWallet/UnstoppableWallet/Core/Managers/QvmBlockchainManager.swift
UnstoppableWallet/UnstoppableWallet/Core/Managers/TermsManager.swift
UnstoppableWallet/UnstoppableWallet/Core/Managers/AppStateManager.swift
UnstoppableWallet/UnstoppableWallet/Extensions/BlockchainType.swift
UnstoppableWallet/UnstoppableWallet/UserInterface/ThemeKit/Themes/ThemeManager.swift
UnstoppableWallet/UnstoppableWallet/Modules/Welcome/WelcomeScreenViewController.swift

# This session — QRC20 alignment
UnstoppableWallet/UnstoppableWallet/Core/Managers/QvmAccountManager.swift
UnstoppableWallet/UnstoppableWallet/Core/Adapters/Qvm/QvmTransactionsAdapter.swift
UnstoppableWallet/UnstoppableWallet/Core/Adapters/Qvm/QvmTransactionConverter.swift
UnstoppableWallet/UnstoppableWallet/Core/Quantum/QvmCoinServiceFactory.swift
UnstoppableWallet/UnstoppableWallet/Core/Factories/AdapterFactory.swift
UnstoppableWallet/UnstoppableWallet/Models/AccountType.swift
UnstoppableWallet/UnstoppableWallet/Core/Address/Qip20AddressValidator.swift
UnstoppableWallet/UnstoppableWallet/Core/Address/ContractValidator/ContractAddressValidatorChain.swift
UnstoppableWallet/UnstoppableWallet/Modules/ManageWallets/ManageWalletsTokenInfoProvider.swift
UnstoppableWallet/UnstoppableWallet/Modules/Coin/Overview/CoinOverviewView.swift
UnstoppableWallet/UnstoppableWallet/Modules/SendNew/QvmDecorator.swift
UnstoppableWallet/UnstoppableWallet/Modules/AddToken/AddQvmTokenBlockchainService.swift     (new)
UnstoppableWallet/UnstoppableWallet/Modules/AddToken/AddTokenModule.swift
UnstoppableWallet/UnstoppableWallet/Core/Storage/StorageMigrator.swift

# This session — UI parity
UnstoppableWallet/UnstoppableWallet/Modules/Wallet/WalletView.swift
UnstoppableWallet/UnstoppableWallet/Modules/Wallet/Token/WalletTokenViewModel.swift
UnstoppableWallet/UnstoppableWallet/Modules/Wallet/Token/ToolbarWalletTokenView.swift
UnstoppableWallet/UnstoppableWallet/Modules/Settings/Appearance/AppearanceView.swift
UnstoppableWallet/UnstoppableWallet/Colors.xcassets/Jacob.colorset/Contents.json
UnstoppableWallet/UnstoppableWallet/Colors.xcassets/Yellow.colorset/Contents.json
UnstoppableWallet/UnstoppableWallet/Modules/Settings/Main/MainSettingsView.swift
UnstoppableWallet/UnstoppableWallet/Core/Managers/PurchaseManager.swift
```

## Recommended Next Session Order

1. **xcodebuild verification.** Most code changes were validated only by static reasoning. Run `xcodebuild build -scheme UnstoppableWallet` and resolve any compilation errors before further work — most likely sites: `AddQvmTokenBlockchainService` (Qip20Kit.Kit.tokenInfo signature), `QvmCoinServiceFactory` (the dead TronKit.Address overload should probably also be removed), `MainSettingsView` (unused `subscription()` / `aboutApp()` / `faq()` / `academy()` / `vipSupport()` private @ViewBuilders are harmless but the linter may flag).
2. **B4 — Quantum price source router.** Net-new module; build in isolation, unit-test the merge logic first. Behavioural parity is currently maintained by the blank-mapping no-op path.
3. **D11 — Full WalletConnect deletion** (mechanical but large; requires build verification).
4. **D12 — Full subscription / premium module deletion** (mechanical but large; requires build verification).
5. **Storage migration sanity check.** The `"Rewrite Quantum Chain tokenQueryId eip20 → qrc20"` migration uses `substr(tokenQueryId, ?)` with the SQLite 1-based index `oldPrefix.count + 1`. Add an integration test or one-off Xcode run with a seeded DB to confirm correctness before merge to master.
