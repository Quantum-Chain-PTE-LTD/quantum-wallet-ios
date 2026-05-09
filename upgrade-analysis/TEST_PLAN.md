# Test Plan

| Test Area                                  | Automated | Manual | Existing Coverage                   | New Coverage Needed           | Notes                                                |
| ------------------------------------------ | --------: | -----: | ----------------------------------- | ----------------------------- | ---------------------------------------------------- |
| Clean build                                |       Yes |     No | Xcode build schemes                 | CI/simulator build after port | Required before source branch handoff.               |
| App launch                                 |       Yes |    Yes | Smoke build may cover launch partly | Launch on simulator/device    | Verify `Core.initApp()` with QVM managers.           |
| Fresh install                              |        No |    Yes | Manual only                         | Manual QA                     | Verify Quantum branding and default setup.           |
| Upgrade from previous Quantum Wallet build |        No |    Yes | None confirmed                      | Critical manual/device test   | Must preserve keychain, database, app group, iCloud. |
| Wallet creation                            |       Yes |    Yes | Account tests not confirmed         | Unit/manual tests             | Include QVM address derivation.                      |
| Wallet import                              |       Yes |    Yes | Account tests not confirmed         | Unit/manual tests             | Include mnemonic/private/watch paths.                |
| Wallet restore                             |       Yes |    Yes | Backup restore flow exists          | Unit/manual tests             | Include cloud and file restore where available.      |
| Quantum Chain account creation             |       Yes |    Yes | None in target                      | Unit/manual tests             | Validate `qvmAddress(chain:)`.                       |
| Quantum address display                    |       Yes |    Yes | None in target                      | Parser/snapshot/manual        | Validate QIP55/QNS display.                          |
| Receive screen                             |        No |    Yes | Existing receive UI                 | Manual QA                     | QR, copy, share, Q address formatting.               |
| Send Q / native coin                       |       Yes |    Yes | Existing send tests unknown         | Integration/manual            | Fee, nonce, signing, broadcast.                      |
| Send Quantum token                         |       Yes |    Yes | None in target                      | Integration/manual            | QRC20 contract/token send.                           |
| Transaction signing                        |       Yes |    Yes | Kit-level assumed done              | App-level tests               | Ensure app passes correct chain/gas/data.            |
| Transaction broadcast                      |       Yes |    Yes | Kit-level assumed done              | Integration/manual            | RPC success/failure paths.                           |
| Pending transaction state                  |       Yes |    Yes | Transaction modules exist           | Manual/integration            | Verify QVM transaction record conversion.            |
| Confirmed transaction state                |       Yes |    Yes | Transaction modules exist           | Manual/integration            | Verify explorer sync.                                |
| Failed transaction state                   |       Yes |    Yes | Transaction modules exist           | Manual/integration            | Verify failed status and retry UX.                   |
| Balance sync                               |       Yes |    Yes | Adapter pattern exists              | Integration/manual            | Q and QRC20 balances.                                |
| Transaction history sync                   |       Yes |    Yes | Target transaction modules exist    | Integration/manual            | QVM Blockscout source.                               |
| Explorer links                             |       Yes |    Yes | Existing explorer links             | Unit/manual                   | Quantum explorer URLs.                               |
| App restart persistence                    |        No |    Yes | Existing storage                    | Manual QA                     | Q wallets/tokens/settings survive restart.           |
| Dark mode                                  |        No |    Yes | Theme system exists                 | Manual QA                     | Quantum colors/icons.                                |
| Light mode                                 |        No |    Yes | Theme system exists                 | Manual QA                     | Quantum colors/icons.                                |
| Offline behavior                           |        No |    Yes | Reachability manager exists         | Manual QA                     | No data loss; clear sync states.                     |
| RPC failure behavior                       |       Yes |    Yes | Existing network handling           | Integration/manual            | Qraft/custom RPC failure states.                     |
| Widget, if present                         |       Yes |    Yes | Widget target exists                | Build/manual                  | Quantum kind IDs and shared app group.               |
| Intent extension, if present               |       Yes |    Yes | Intent target exists                | Build/manual                  | Bundle ID, signing, intents.                         |
| Fastlane/release build                     |       Yes |    Yes | Fastlane exists                     | CI/manual                     | Signing IDs/profiles must be final.                  |

## Additional Focused Tests

| Test Area                               | Automated | Manual | Existing Coverage            | New Coverage Needed     | Notes                                                  |
| --------------------------------------- | --------: | -----: | ---------------------------- | ----------------------- | ------------------------------------------------------ |
| `AccountType` encoding/decoding         |       Yes |     No | Target account model         | Unit tests              | Add `qvmAddress` without breaking Stellar/Monero/TRON. |
| `StorageMigrator` Quantum compatibility |       Yes |    Yes | Existing migrations          | Fixture migration tests | Include legacy keychain services and QRC20 mappings.   |
| QVM address parser                      |       Yes |    Yes | None in target               | Unit/manual             | Raw address and QNS resolution.                        |
| QIP20 contract validator                |       Yes |    Yes | EIP20/TRC20 validators exist | Unit/integration        | Validate symbol/decimals/name.                         |
| QVM adapter factory routing             |       Yes |     No | Adapter factory exists       | Unit tests              | Native Q and QRC20 routes.                             |
| QVM transaction conversion              |       Yes |    Yes | EVM/Stellar converters exist | Unit/manual             | Incoming/outgoing/approve/contract call.               |
| QVM custom RPC source backup/restore    |       Yes |    Yes | EVM source backup exists     | Unit/manual             | Selected and custom sources.                           |
