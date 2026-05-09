# Quantum Delta

This document lists the Quantum-specific changes discovered in the old Quantum reference repo and classifies how they should be ported to the updated target repo.

## Branding

| Change | Evidence / files | Classification | Notes |
| --- | --- | --- | --- |
| App label changed to `com.quantum.chain.wallet` | `Core/Providers/AppConfig.swift` | Must port exactly | Preserve for app identity and backup namespace. |
| Backup salt changed to `quantum` | `Core/Providers/AppConfig.swift` | Must port exactly | Required for backup compatibility. |
| Company/support links changed to Quantum Chain | `Core/Providers/AppConfig.swift` | Must port but adapt to new upstream architecture | Keep target-only links where product still needs them. |
| App display names changed to `Quantum Wallet` / `Quantum Wallet Dev` | `project.pbxproj`, schemes | Must port exactly | Preserve product identity. |
| Bundle IDs changed to `com.quantum.chain.wallet*` | `project.pbxproj` | Must port exactly | User confirmed preserve old Quantum identity. |
| App groups and iCloud containers changed to Quantum IDs | `Configuration/*.entitlements`, `Info.plist` | Must port exactly | High upgrade and signing risk. |
| Keychain service changed to `com.quantum.chain.bank` | `Core/App.swift` | Must port exactly | Critical for existing users. |
| URL scheme and applinks include `quantumcha.in` | `Info.plist`, entitlements | Must port exactly | Keep target's broader crypto schemes too. |
| Widget kind IDs use `com.quantum.chain.*Widget` | `Widget/AppWidgetConstants.swift` | Must port exactly | Required for widget identity continuity. |
| App icons, launch images, logo, colors customized | asset catalogs, project settings, localization commits | Must port exactly for assets; manually merge colors | Copy inspected assets/configs; avoid overwriting unrelated target assets. |
| Localized user-facing strings changed from Unstoppable to Quantum | `*.lproj/Localizable.strings` | Must port but adapt to new upstream strings | Merge, do not replace localization files wholesale. |

## Chain Support

| Change | Evidence / files | Classification | Notes |
| --- | --- | --- | --- |
| Added `.quantumChain` to supported chains | `Extensions/BlockchainType.swift` | Must port but adapt to new upstream architecture | Target also has Monero/Zano/Stellar and must keep them. |
| Quantum native coin `Q` and QRC20 token support | `BlockchainType.swift`, `Token.swift`, QIP20 files | Must port exactly | QRC20 maps through `.eip20` token type in old app. |
| Quantum icon URL uses Quantum S3 bucket | `BlockchainType.imageUrl` | Must port exactly | Only for `.quantumChain`; keep CDN default for other chains. |
| Quantum fee scale uses `gqwei` | `BlockchainType.feePriceScale` | Must port exactly | QVM fee UI depends on this. |
| Quantum chain order places Quantum first | `BlockchainType.order` | Must port exactly unless product decides otherwise | UI prominence requirement. |
| QVM testnet chain ID `11155111`, coin type `1`, QIP1559 enabled | `QvmBlockchainManager.swift` | Must port but verify | Looks analogous to Sepolia-style testnet; validate kit expectations. |
| Qraft RPC default source | `QvmSyncSourceManager.swift` | Must port exactly | Default Quantum RPC source. |
| Quantum Blockscout transaction source | `QvmSyncSourceManager.swift` | Must port exactly | Explorer/transaction history source. |
| QNS address parser | `QnsAddressParserItem.swift`, `AddressParserFactory.swift` | Must port but adapt | Target parser API has `ParserFilter` and `Core.shared`. |
| QIP20 contract validator | `Qip20AddressValidator.swift` | Must port but adapt | Add alongside target EIP20/TRC20 validators. |

## Wallet Behavior

| Change | Evidence / files | Classification | Notes |
| --- | --- | --- | --- |
| Added `qvmAddress` account type | `Models/AccountType.swift` | Must port but adapt | Merge with target `Identifiable`, TRON private key, Stellar, Monero watch account cases. |
| Added QVM address derivation from mnemonic | `AccountType.qvmAddress(chain:)` | Must port exactly | Required for Quantum account creation/restoration. |
| Added QVM account manager/factory | `QvmAccountManager.swift`, `QvmAccountManagerFactory.swift` | Must port but adapt | Integrate into target `Core.swift`. |
| Added QVM/QIP20 adapters | `Core/Adapters/Qvm/*` | Must port but adapt | Adapt to target adapter interfaces and spam wrapper. |
| Added QVM transaction adapter/converter/records | `QvmTransactionsAdapter.swift`, `Models/TransactionRecords/Qvm/*` | Must port but adapt | Preserve target Stellar/Monero/Zano transaction adapters. |
| Added QVM send/new-send handlers and fee settings | `Modules/SendNew/Qvm*`, `Modules/QvmSendSettings/*` | Must port but adapt | Target send architecture has evolved. Hunk-level migration required. |
| Legacy send route supports `ISendQuantumAdapter` | `Modules/Send/Platforms/SendModule.swift` | Needs human review | Target old send route no longer routes EVM there; QVM may belong in `SendNew`. |
| Added Quantum-specific send allowed-state check | old history includes `feat(qvm): enforce allowed state before sending QVM transactions` | Must port but adapt | Security/UX behavior must be preserved. |
| Receive/address display supports Quantum/QNS | address parser files, token extensions | Must port but adapt | Integrate with target contacts/recent address services. |

## Configuration

| Change | Evidence / files | Classification | Notes |
| --- | --- | --- | --- |
| App config label, salt, company, support, links | `AppConfig.swift` | Must port but adapt | Target has more config fields; preserve newer fields. |
| Quantum keychain and legacy migration services | `Core/App.swift`, `StorageMigrator.swift` | Must port exactly | Critical user data risk. |
| Entitlements for Quantum app group/iCloud | `Configuration/*.entitlements` | Must port exactly | Merge target webcredentials/associated domains if needed. |
| `Info.plist` URL scheme `quantumcha.in` | `Info.plist` | Must port exactly | Keep target crypto deeplinks. |
| QVM custom sync sources backup/restore | `QvmSyncSourceManager.swift`, storage | Must port but adapt | Add to target backup provider without dropping Monero/Zano nodes. |
| Feature removals in old Quantum | history shows WalletConnect/onboarding/app icon removals | Possibly obsolete | Target features should be preserved unless product explicitly disables them. |

## Dependencies

| Change | Evidence / files | Classification | Notes |
| --- | --- | --- | --- |
| Added `QvmKit` package/product references | `project.pbxproj`, `BackCompatibility/QvmKit.swift` | Must port but adapt | Add package refs without downgrading target dependencies. |
| Added `Qip20Kit` package/product references | `project.pbxproj`, `BackCompatibility/Qip20Kit.swift` | Must port but adapt | Required for QRC20. |
| Added `TonConnectAPI` local package in old repo | `QuantumWallet/TonConnectAPI` | Needs human review | Target already has newer app architecture. Do not copy blindly. |
| Removed or changed upstream WalletConnect in old Quantum | old history | Do not port by default | Target WalletConnect should be preserved unless product asks to remove it. |

## Build / Release

| Change | Evidence / files | Classification | Notes |
| --- | --- | --- | --- |
| Product names changed to Quantum | `project.pbxproj`, schemes | Must port exactly | Preserve app identity. |
| Bundle IDs changed to Quantum IDs | `project.pbxproj`, Fastlane | Must port exactly | Preserve upgrade path. |
| Development team differs in old Quantum | `project.pbxproj` | Needs human review | Signing must match current Apple account. |
| Quantum entitlements differ from target | `Configuration/*.entitlements` | Must port exactly with review | High risk for iCloud/app groups. |
| Fastlane still contains some stale Horizontal/Unstoppable values | `fastlane/Fastfile`, `Matchfile` | Must port but adapt | Hunk-level update only. |
| Xcode project contains QVM/QIP20 file and package refs | `project.pbxproj` | Must port but adapt | Do not replace target project file wholesale. |

## UI / Product

| Change | Evidence / files | Classification | Notes |
| --- | --- | --- | --- |
| Quantum welcome/settings logo and footer changes | old history and assets | Must port but adapt | Preserve target UI improvements. |
| Quantum Chain icons and market view customization | old history, `BlockchainType.swift` | Must port but adapt | Ensure target market/list UI sees Quantum metadata. |
| Onboarding carousel removed in old Quantum | old history | Needs human review | Preserve target onboarding unless product wants old removal. |
| Dynamic app icon switching removed in old Quantum | old history | Needs human review | Target has `AppIconManager`; do not remove by default. |
| Premium/support strings mention Quantum Wallet | localizations | Must port but adapt | Merge with target new strings. |
