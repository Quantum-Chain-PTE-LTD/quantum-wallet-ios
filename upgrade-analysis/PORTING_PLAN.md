# Porting Plan

This is a forward-port task, not a merge task. Copy assets and isolated Quantum-only files when safe, but port Swift, project, storage, and configuration logic hunk by hunk.

## Phase 1 - Analysis Commit

Commit only:

```text
upgrade-analysis/*
```

Commit message:

```text
chore(wallet-ios): analyze Quantum Wallet forward-port
```

Notes:

- The analysis commit should be the first commit on the feature branch.
- No app source files should be changed before this commit.

## Phase 2 - Branch Setup

Branch:

```bash
feature/QWIOS-ID01-forward-port-quantum-wallet
```

Operational note: the branch was created before writing these analysis files so the first commit is isolated on the feature branch instead of `master`.

## Phase 3 - Branding Port

Port safe branding changes first:

- App name: `Quantum Wallet` / `Quantum Wallet D`.
- Display name and product name.
- Bundle IDs for app, widget, and intent extension under `com.quantum.chain.wallet*`.
- Keychain service `com.quantum.chain.bank`.
- App group `group.com.quantum.chain.wallet`.
- iCloud containers under `iCloud.com.quantum.chain.wallet*`.
- URL scheme and applinks for `quantumcha.in`.
- Icons, launch screen, colors, logos, and widget kind IDs.
- User-facing strings from Unstoppable/Horizontal to Quantum where product-facing.

Preserve target-only additions unless they conflict with Quantum identity.

Suggested commit:

```text
refactor(wallet-ios): apply Quantum Wallet branding
```

## Phase 4 - Config Port

Port configuration:

- Quantum API URLs and support links.
- Quantum RPC URLs.
- Quantum explorer transaction source links.
- Feature flags and privacy/analytics settings.
- Fastlane identifiers and release metadata.

Preserve target configuration additions:

- `SwapApiUrl`.
- `MerkleApiPath`.
- Thorchain/Maya/uSwap keys.
- Multiple Tron Grid keys.
- Expanded crypto URL schemes.
- WalletConnect V2 project key.

Suggested commit:

```text
chore(wallet-ios): apply Quantum Wallet configuration
```

## Phase 5 - Dependency Port

Port dependency references carefully:

- Add `QvmKit` package/product references.
- Add `Qip20Kit` package/product references.
- Add required back-compat shims if still needed.
- Add project file references and build phase entries for Quantum-only files manually.

Do not downgrade the target dependency graph. Do not copy the old project file wholesale.

Suggested commit:

```text
chore(wallet-ios): restore Quantum Wallet dependencies
```

## Phase 6 - Chain Support Port

Port Quantum Chain app-level support:

- `.quantumChain` in supported blockchains.
- Native `Q` metadata and QRC20 token support.
- QVM chain ID and testnet configuration.
- Qraft RPC source.
- Quantum Blockscout transaction source.
- QVM/QIP20 adapters.
- QVM transaction records and converters.
- QVM sync source storage.
- QVM label storage and manager.
- QNS parser and QIP20 contract validator.
- Fee/gas display with `gqwei`.
- Send/receive availability.

Preserve target Monero, Zano, Stellar, Tron, Ton, WalletConnect, spam scanning, and swap architecture.

Suggested commit:

```text
feat(wallet-ios): restore Quantum Chain support
```

## Phase 7 - Wallet Flow Port

Port app behavior changes:

- Create wallet flow for Quantum Chain accounts.
- Import/restore support for QVM watch/account data.
- Account initialization and QVM address derivation.
- Receive screen and QR/address display.
- Q/QRC20 send flow.
- QVM fee settings and transaction confirmation.
- QVM transaction history.

Use the target architecture as the base. Adapt old Quantum logic into target patterns instead of restoring stale modules wholesale.

Suggested commit:

```text
feat(wallet-ios): restore Quantum Wallet flows
```

## Phase 8 - Build Fixes

Fix compile errors after all major porting work. For each compile error, identify whether it is caused by:

- New upstream API.
- Old Quantum code using removed APIs.
- Missing dependency.
- Renamed type.
- Changed architecture.
- Incorrect file copy or target membership.

Suggested commit:

```text
fix(wallet-ios): resolve forward-port build issues
```

## Phase 9 - Migration Safety

Review storage and migrations. Ensure existing Quantum Wallet users can upgrade without losing:

- Wallets.
- Accounts.
- Addresses.
- Q and QRC20 tokens.
- Transaction history.
- Settings.
- Passcode/biometry access.
- Cloud backups.
- Widget shared data.

Preserve target migrations and add/merge Quantum migrations. Do not replace `StorageMigrator.swift` wholesale.

Suggested commit:

```text
fix(wallet-ios): preserve Quantum Wallet storage compatibility
```

## Phase 10 - Test and QA

Run build and tests, then execute manual QA.

Suggested build command after scheme/destination discovery:

```bash
xcodebuild \
  -workspace UnstoppableWallet/UnstoppableWallet.xcworkspace \
  -scheme Development \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

Suggested commit:

```text
test(wallet-ios): add Quantum Wallet forward-port validation
```

Final documentation commit, if needed:

```text
docs(wallet-ios): document forward-port result
```
