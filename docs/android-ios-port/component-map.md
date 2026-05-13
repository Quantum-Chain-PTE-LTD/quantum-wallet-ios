# Android ↔ iOS Component Map

Maps each functional Android area Ricardo Toledo touched to its iOS equivalent.

---

## Feature Area: Quantum Chain core config

### Android
- Files: `MarketKitExtensions.kt`, `App.kt`, `AdapterFactory.kt`, `AdapterManager.kt`, `TransactionAdapterManager.kt`
- Classes: `BlockchainType.QuantumChain`, `QuantumKitManager`, `QuantumAccountManager`
- Entry: `App.appConfigProvider`, chain ID 20803

### iOS
- Files: `Core/Providers/AppConfig.swift`, `Core/Managers/QvmBlockchainManager.swift`, `Core/Managers/QvmSyncSourceManager.swift`, `Core/Managers/QvmKitManager.swift`, `Core/Managers/QvmAccountManager.swift`, `Extensions/BlockchainType.swift`, `Core/Factories/AdapterFactory.swift`
- Classes: `BlockchainType.quantumChain`, `QvmKitManager`, `QvmAccountManager`, `QvmBlockchainManager`
- Entry: `AppConfig` + QvmKit `Chain.quantumChain` (id 20803, in `F:\Quantum\repositories\qvmkit.swift`)

### Notes
- Chain ID mainnet is already 20803 via QvmKit. iOS testnet branch hardcodes 11_155_111 (Sepolia) — this is non-functional (returns empty sync sources) and not present on Android. **Action:** simplify by removing testnet branch.

---

## Feature Area: Spam detection

### Android
- File: `QuantumTransactionEventExtractor.kt` (new, 116 lines), `SpamManager.kt`
- Behavior: handles `OutgoingQip20Decoration` and QRC-20 `TransferEventInstance`, extracts QIP-55 addresses (mirrors `EvmTransactionEventExtractor`)

### iOS
- Files: `Core/SpamManager.swift`, `Core/SpamFilterChain.swift`, `Core/SpamWrapper.swift`
- Behavior: generic; needs a Quantum-specific path mirroring the QIP20 decoration handling

### Notes
- Audit `Modules/Transactions/RecordRelevanceCalculator.swift` and adapter records for `.quantumChain` to ensure QRC20 transactions are correctly classified as non-spam when known.

---

## Feature Area: Token enumeration / restore filtering

### Android
- File: `FullCoinsProvider.kt` (QRC20 token-type filter), `ReceiveAddressScreen.kt`, `RestoreLocalViewModel.kt` (UW_Backup_ → QW_Backup_)

### iOS
- Files: `Core/Providers/CoinProvider.swift` or equivalent (audit needed), `Modules/Receive/*`, `Modules/Restore/RestoreLocal*.swift`

### Notes
- Search for `UW_Backup` to relocate Quantum prefix usages.

---

## Feature Area: Price source routing (Quantum fallback)

### Android
- Files: `pricesource/PriceSourceRouter.kt` (142 LOC), `pricesource/QuantumPriceApi.kt` (76 LOC), `pricesource/TokenPriceMappingConfig.kt`, `pricesource/TokenPriceSourceMappingService.kt`, wired into `MarketKitWrapper.kt`, `LocalStorageManager.kt`
- Behavior: HS-first/Quantum-fallback merge; 24h TTL on mapping config fetch; 30s debounce on price refresh; Retrofit client targeting `quantumChainApiBaseUrl`

### iOS
- Files: `Core/Managers/MarketKitWrapper.swift` (search needed), `Core/Storage/StorageManager.swift`-equivalent
- New files to add: `Core/Providers/PriceSource/PriceSourceRouter.swift`, `QuantumPriceApi.swift`, `TokenPriceMappingConfig.swift`, `TokenPriceSourceMappingService.swift`

### Notes
- iOS uses Combine/async-await typically. Use `URLSession.dataTask` with async/await over Retrofit. Cache via `UserDefaults` + in-memory dict; debounce via Combine `debounce(for:scheduler:)` or `Timer`.

---

## Feature Area: Hide market data for Quantum tokens

### Android
- File: `MarketKitExtensions.kt` — `BlockchainType.hasMarketData`, `Token.hasMarketData`; nav guards in `TokenBalanceScreen.kt`, `BalanceItems.kt`, `AmountCell.kt`

### iOS
- Files: `Extensions/BlockchainType.swift`, balance row tap handlers (likely `Modules/Balance/BalanceViewController.swift` and `BalanceCell.swift`), transaction record cells (`Modules/Transactions/Cells/*`), amount cells, chart buttons

### Notes
- Add Swift extension `BlockchainType.hasMarketData: Bool` returning `false` for `.quantumChain`; same for `Token`. Guard `present(coinPage)` / `coinViewController` navigation behind this.

---

## Feature Area: Terms list

### Android
- File: `TermsModule.kt` — 5 enum cases: Backup, PrivateKeys, DisablingPin, JailBraking, Bugs

### iOS
- Files: `Modules/Terms/TermsManager.swift`, `Modules/Terms/TermsViewController.swift`, localized strings `terms.*`

### Notes
- Restore canonical 5-item enum.

---

## Feature Area: Theme

### Android
- Files: `ThemeService.kt`, `Color.kt`, `Theme.kt` — yellow `#FFB700` → blue `#0084FF`, dark-only

### iOS
- Files: `UserInterface/ThemeManager.swift`, `UserInterface/AppTheme.swift`, asset catalog colors (`Assets.xcassets/Colors/`), `Modules/Settings/Appearance/AppearanceView.swift`

### Notes
- Force `ThemeManager.shared.themeMode = .dark`; hide theme selector. Replace `jacob`/accent color asset.

---

## Feature Area: Welcome / splash

### Android
- File: `IntroActivity.kt` — replaced multi-page pager with 2-second splash

### iOS
- File: `Modules/Welcome/WelcomeScreenViewController.swift` — 3-slide carousel

### Notes
- Replace pager with `Timer`-based 2s auto-advance to onboarding.

---

## Feature Area: Swap removal

### Android
- Files: `MainViewModel.kt`, `SwapSyncService.kt`, `NetworkManager.kt` — hide tab, switch hosts

### iOS
- Files: `Modules/Main/MainTabsController.swift`-equivalent, `Modules/Swap/*`

### Notes
- Tab bar item removal + nav guards.

---

## Feature Area: Settings simplification

### Android
- Files: `AppearanceFragment.kt` (-201), `MainSettingsScreen.kt`

### iOS
- Files: `Modules/Settings/MainSettings/MainSettingsView*.swift`, `Modules/Settings/Appearance/*`

### Notes
- Remove theme selector, icon chooser, Support/About/FAQ/Guides menu entries.

---

## Feature Area: WalletConnect removal

### Android
- Removed `walletconnect/` directory entirely (~50 files)

### iOS
- Files to remove: `Modules/WalletConnect/*`, `Core/WalletConnectManager.swift`, `Core/WalletConnectV2*`
- Manifest: remove WC scheme handlers in `Info.plist`, remove WC localized strings

### Notes
- Removing WC affects send/sign flows in EVM modules. Audit `AdapterFactory`, `SendTransactionService` for WC-only branches.

---

## Feature Area: Subscriptions / premium removal

### Android
- Removed 4 subscription modules + `PaidActionSettingsManager`; 22+ `paidAction()` call sites unwrapped

### iOS
- Files to remove: `Modules/Premium/*`, `Modules/Subscription/*`, `Core/Managers/SubscriptionManager.swift`, `Core/Managers/PurchaseManager.swift`, premium cell components, premium localized strings

### Notes
- Drop StoreKit dependency from Xcode project if no remaining usage.
