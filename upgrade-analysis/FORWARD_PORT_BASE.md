# Forward-Port Base

## Repositories

| Role                  | Prompt name                  | Actual local path                                         | Status              |
| --------------------- | ---------------------------- | --------------------------------------------------------- | ------------------- |
| Old Quantum reference | `quantum-wallet-ios-old`     | `c:\Users\ricar\Documents\Quantum\quantum-wallet-ios`     | Read-only reference |
| New target            | `unstoppable-wallet-ios-new` | `c:\Users\ricar\Documents\Quantum\unstoppable-wallet-ios` | Target for changes  |

## Current Git State

| Repo                  | Branch                                           | Commit                                     | Remote                                                                           | Worktree                   |
| --------------------- | ------------------------------------------------ | ------------------------------------------ | -------------------------------------------------------------------------------- | -------------------------- |
| Old Quantum reference | `master`                                         | `883c162354780cd25f0840b077f184f51f37a991` | `https://quantum-chain-admin@bitbucket.org/quantum-chain/quantum-wallet-ios.git` | Clean                      |
| New target            | `feature/QWIOS-ID01-forward-port-quantum-wallet` | `705d8c431eba659f50cce1c1f32330a04fbe1758` | `https://github.com/Quantum-Chain-PTE-LTD/quantum-wallet-ios.git`                | Clean before analysis docs |

The target branch was created from target `master` before writing these analysis files.

## Shared History / Base Detection

The old Quantum fork has local commit history and remote branches, but it does not have an `upstream` remote configured. The configured remote points to the Quantum fork itself, not to the original Horizontal Systems upstream.

Because no old upstream remote is available locally, no reliable `git merge-base HEAD upstream/master` could be calculated. The Quantum delta in this analysis is therefore based on a mixed approach:

- Git history inspection in the old Quantum fork.
- Direct file comparison between the old Quantum repo and the new target repo.
- Targeted searches for Quantum/QVM identifiers, branding identifiers, bundle IDs, app groups, keychain services, package references, and chain/network integration points.
- Manual review of high-risk integration files.

Confidence level: Medium. The major Quantum-specific changes are visible and well clustered, but a precise original upstream base commit was not detected locally.

## Commands / Tool Observations Used

Commands and equivalent tool observations used during inventory:

```powershell
Set-Location "c:\Users\ricar\Documents\Quantum"
Get-Location
Get-ChildItem -Force | Select-Object Mode,Length,Name
git -C "quantum-wallet-ios" status --short --branch
git -C "quantum-wallet-ios" remote -v
git -C "quantum-wallet-ios" branch -a
git -C "quantum-wallet-ios" log --oneline --decorate --max-count=20
git -C "unstoppable-wallet-ios" status --short --branch
git -C "unstoppable-wallet-ios" remote -v
git -C "unstoppable-wallet-ios" branch -a
git -C "unstoppable-wallet-ios" log --oneline --decorate --max-count=20
```

Targeted searches included:

```text
quantumChain | Qvm | Qip20 | QRC20 | QvmKit | Quantum
Unstoppable | Horizontal | horizontalsystems | quantumcha | com.quantum | bank-wallet
QvmKit | Qip20Kit | quantum-static | quantumQraft | quantumBlockscout
PRODUCT_BUNDLE_IDENTIFIER | PRODUCT_NAME | DEVELOPMENT_TEAM | CODE_SIGN_ENTITLEMENTS
```

## Main App / Project Inventory

| Area                    | Old Quantum reference                               | New target                                        |
| ----------------------- | --------------------------------------------------- | ------------------------------------------------- |
| App folder              | `QuantumWallet/QuantumWallet`                       | `UnstoppableWallet/UnstoppableWallet`             |
| Workspace               | `QuantumWallet/QuantumWallet.xcworkspace`           | `UnstoppableWallet/UnstoppableWallet.xcworkspace` |
| Project                 | `QuantumWallet/QuantumWallet.xcodeproj`             | `UnstoppableWallet/UnstoppableWallet.xcodeproj`   |
| Shared schemes          | `Development`, `Production`                         | `Development`, `Production`                       |
| Widget                  | `QuantumWallet/Widget`                              | `UnstoppableWallet/Widget`                        |
| Intent extension        | `QuantumWallet/IntentExtension`                     | `UnstoppableWallet/IntentExtension`               |
| App config              | `Core/Providers/AppConfig.swift`                    | `Core/Providers/AppConfig.swift`                  |
| Core container          | `Core/App.swift`                                    | `Core/Core.swift`                                 |
| Dependency/project refs | Xcode project + `Gemfile` + `TonConnectAPI` package | Xcode project + `Gemfile`                         |
| Fastlane                | `fastlane/`                                         | `fastlane/`                                       |

## Important Decisions

- The target repo for implementation is `c:\Users\ricar\Documents\Quantum\unstoppable-wallet-ios`.
- The old Quantum repo must remain read-only.
- Preserve Quantum app identity for upgrade compatibility:
  - App bundle IDs: `com.quantum.chain.wallet`, `com.quantum.chain.wallet.dev`.
  - Widget and intent bundle IDs under `com.quantum.chain.wallet.*`.
  - App group: `group.com.quantum.chain.wallet`.
  - iCloud containers under `iCloud.com.quantum.chain.wallet*`.
  - Keychain service: `com.quantum.chain.bank`.
  - Widget kind prefix: `com.quantum.chain`.

## Uncertainty

- The exact original Unstoppable base commit for the old Quantum fork was not detected locally.
- Some old Quantum commits remove upstream features such as WalletConnect and app icon switching; these removals should not be blindly repeated because the target architecture is newer.
- Lower-level QVM kit migration is assumed complete and tested, but target project/package references still need to be restored at app level.
