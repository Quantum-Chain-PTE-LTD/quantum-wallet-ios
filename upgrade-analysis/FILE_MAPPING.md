# File Mapping

| Old Quantum file | New target file | Type of change | Porting strategy | Risk |
| --- | --- | --- | --- | --- |
| `QuantumWallet/QuantumWallet/Core/Providers/AppConfig.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Providers/AppConfig.swift` | Same path under renamed app folder | Manually reapply hunks | High |
| `QuantumWallet/QuantumWallet/Extensions/BlockchainType.swift` | `UnstoppableWallet/UnstoppableWallet/Extensions/BlockchainType.swift` | Same path under renamed app folder | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet/Core/App.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Core.swift` | Renamed/new upstream replacement exists | Recreate in new architecture | Critical |
| `QuantumWallet/QuantumWallet/Core/Factories/AdapterFactory.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Factories/AdapterFactory.swift` | Same path under renamed app folder | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet/Core/Managers/AdapterManager.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Managers/AdapterManager.swift` | Same path under renamed app folder | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet/Core/Managers/TransactionAdapterManager.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Managers/TransactionAdapterManager.swift` | Same path under renamed app folder | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet/Models/AccountType.swift` | `UnstoppableWallet/UnstoppableWallet/Models/AccountType.swift` | Same path under renamed app folder | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet/Core/Storage/AccountStorage.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Storage/AccountStorage.swift` | Same path under renamed app folder | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet/Core/Storage/StorageMigrator.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Storage/StorageMigrator.swift` | Same path under renamed app folder | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet.xcodeproj/project.pbxproj` | `UnstoppableWallet/UnstoppableWallet.xcodeproj/project.pbxproj` | Renamed path | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet/Configuration/*.entitlements` | `UnstoppableWallet/UnstoppableWallet/Configuration/*.entitlements` | Same path under renamed app folder | Manually reapply hunks | Critical |
| `QuantumWallet/QuantumWallet/Configuration/*.template.xcconfig` | `UnstoppableWallet/UnstoppableWallet/Configuration/*.template.xcconfig` | Same path under renamed app folder | Manually reapply hunks | High |
| `QuantumWallet/QuantumWallet/Info.plist` | `UnstoppableWallet/UnstoppableWallet/Info.plist` | Same path under renamed app folder | Manually reapply hunks | High |
| `QuantumWallet/Widget/AppWidgetConstants.swift` | `UnstoppableWallet/Widget/AppWidgetConstants.swift` | Same path under renamed app folder | Copy small hunk exactly | Medium |
| `QuantumWallet/Widget/Info.plist` | `UnstoppableWallet/Widget/Info.plist` | Same path under renamed app folder | Manually reapply hunks | Medium |
| `QuantumWallet/IntentExtension/Info.plist` | `UnstoppableWallet/IntentExtension/Info.plist` | Same path under renamed app folder | Manually reapply hunks | Medium |
| `QuantumWallet/QuantumWallet/AppIcon.xcassets` | `UnstoppableWallet/UnstoppableWallet/AppIcon.xcassets` | Asset catalog | Copy exactly after inspection | Low |
| `QuantumWallet/QuantumWallet/AppIconDev.xcassets` | `UnstoppableWallet/UnstoppableWallet/AppIconDev.xcassets` | Asset catalog | Copy exactly after inspection | Low |
| `QuantumWallet/QuantumWallet/AppIconAlternate.xcassets` | `UnstoppableWallet/UnstoppableWallet/AppIconAlternate.xcassets` | Asset catalog | Copy exactly after inspection | Medium |
| `QuantumWallet/QuantumWallet/Assets.xcassets` | `UnstoppableWallet/UnstoppableWallet/Assets.xcassets` | Asset catalog | Manually merge assets | Medium |
| `QuantumWallet/QuantumWallet/Colors.xcassets` | `UnstoppableWallet/UnstoppableWallet/Colors.xcassets` | Asset catalog | Manually merge assets | Medium |
| `QuantumWallet/QuantumWallet/LaunchScreen.xib` | `UnstoppableWallet/UnstoppableWallet/LaunchScreen.xib` | Same path under renamed app folder | Manually reapply hunks | Medium |
| `QuantumWallet/QuantumWallet/BackCompatibility/QvmKit.swift` | `UnstoppableWallet/UnstoppableWallet/BackCompatibility/QvmKit.swift` | New Quantum-only file | Copy exactly, then compile-adapt if needed | High |
| `QuantumWallet/QuantumWallet/BackCompatibility/Qip20Kit.swift` | `UnstoppableWallet/UnstoppableWallet/BackCompatibility/Qip20Kit.swift` | New Quantum-only file | Copy exactly, then compile-adapt if needed | High |
| `QuantumWallet/QuantumWallet/Core/Managers/QvmBlockchainManager.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Managers/QvmBlockchainManager.swift` | New Quantum-only file | Copy then adapt to target services | Critical |
| `QuantumWallet/QuantumWallet/Core/Managers/QvmSyncSourceManager.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Managers/QvmSyncSourceManager.swift` | New Quantum-only file | Copy then adapt to target services | Critical |
| `QuantumWallet/QuantumWallet/Core/Managers/QvmKitManager.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Managers/QvmKitManager.swift` | New Quantum-only file | Copy then adapt to target services | Critical |
| `QuantumWallet/QuantumWallet/Core/Managers/QvmAccountManager.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Managers/QvmAccountManager.swift` | New Quantum-only file | Copy then adapt to target services | Critical |
| `QuantumWallet/QuantumWallet/Core/Managers/QvmLabelManager.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Managers/QvmLabelManager.swift` | New Quantum-only file | Copy then adapt to target label/spam architecture | High |
| `QuantumWallet/QuantumWallet/Core/Factories/QvmAccountManagerFactory.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Factories/QvmAccountManagerFactory.swift` | New Quantum-only file | Copy then adapt | High |
| `QuantumWallet/QuantumWallet/Core/Storage/QvmSyncSourceStorage.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Storage/QvmSyncSourceStorage.swift` | New Quantum-only file | Copy then verify migrations | High |
| `QuantumWallet/QuantumWallet/Core/Storage/QvmLabelStorage.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Storage/QvmLabelStorage.swift` | New Quantum-only file | Copy then verify migrations | High |
| `QuantumWallet/QuantumWallet/Models/Qvm*.swift` | `UnstoppableWallet/UnstoppableWallet/Models/Qvm*.swift` | New Quantum-only files | Copy then adapt naming/API | High |
| `QuantumWallet/QuantumWallet/Models/TransactionRecords/Qvm/*` | `UnstoppableWallet/UnstoppableWallet/Models/TransactionRecords/Qvm/*` | New Quantum-only directory | Copy then adapt | High |
| `QuantumWallet/QuantumWallet/Core/Adapters/Qvm/*` | `UnstoppableWallet/UnstoppableWallet/Core/Adapters/Qvm/*` | New Quantum-only directory | Copy then adapt | Critical |
| `QuantumWallet/QuantumWallet/Core/Address/QvmAddressParserItem.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Address/QvmAddressParserItem.swift` | New Quantum-only file | Copy then adapt | High |
| `QuantumWallet/QuantumWallet/Core/Address/QnsAddressParserItem.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Address/QnsAddressParserItem.swift` | New Quantum-only file | Copy then adapt | High |
| `QuantumWallet/QuantumWallet/Core/Address/Qip20AddressValidator.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Address/ContractValidator/Qip20AddressValidator.swift` | Moved upstream validator structure | Recreate in new architecture | High |
| `QuantumWallet/QuantumWallet/Core/Factories/AddressParserFactory.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Factories/AddressParserFactory.swift` | Same path under renamed app folder | Manually reapply hunks | High |
| `QuantumWallet/QuantumWallet/Core/Address/AddressUriParser.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Address/AddressUriParser.swift` | Same path under renamed app folder | Manually reapply hunks | High |
| `QuantumWallet/QuantumWallet/Core/Address/UdnAddressParserItem.swift` | `UnstoppableWallet/UnstoppableWallet/Core/Address/UdnAddressParserItem.swift` | Same path under renamed app folder | Manually reapply hunks | Medium |
| `QuantumWallet/QuantumWallet/Extensions/Token.swift` | `UnstoppableWallet/UnstoppableWallet/Extensions/Token.swift` | Same path under renamed app folder | Manually reapply hunks | Medium |
| `QuantumWallet/QuantumWallet/Modules/SendNew/Qvm*` | `UnstoppableWallet/UnstoppableWallet/Modules/SendNew/Qvm*` | New Quantum-only files in changed module | Copy then adapt to target send architecture | Critical |
| `QuantumWallet/QuantumWallet/Modules/QvmSendSettings/*` | `UnstoppableWallet/UnstoppableWallet/Modules/QvmSendSettings/*` | New Quantum-only module | Recreate in new architecture | High |
| `QuantumWallet/QuantumWallet/Modules/QvmNetwork/*` | `UnstoppableWallet/UnstoppableWallet/Modules/QvmNetwork/*` | New Quantum-only module | Recreate in new architecture | High |
| `QuantumWallet/QuantumWallet/Modules/Send/Platforms/SendModule.swift` | `UnstoppableWallet/UnstoppableWallet/Modules/Send/Platforms/SendModule.swift` | Same path under renamed app folder | Needs review; hunk-port only if old send still routes QVM | High |
| `QuantumWallet/QuantumWallet/*.lproj/Localizable.strings` | `UnstoppableWallet/UnstoppableWallet/*.lproj/Localizable.strings` | Same localization paths | Manually merge strings | Medium |
| `QuantumWallet/TonConnectAPI/*` | None or target equivalent | New Quantum/local package | Needs review; skip unless target lacks required behavior | Medium |
| `fastlane/Fastfile` | `fastlane/Fastfile` | Same path | Manually reapply hunks | High |
| `fastlane/Matchfile` | `fastlane/Matchfile` | Same path | Needs review | Medium |
