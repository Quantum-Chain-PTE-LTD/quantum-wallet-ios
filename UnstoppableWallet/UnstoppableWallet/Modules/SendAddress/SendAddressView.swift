
import SwiftUI

struct SendAddressView: View {
    private let wallet: Wallet
    private let address: String?
    private let fromAddress: String?
    private let amount: Decimal?
    private let memo: String?

    @Binding var path: NavigationPath
    @Binding var isPresented: Bool

    init(wallet: Wallet, address: String? = nil, amount: Decimal? = nil, memo: String? = nil, path: Binding<NavigationPath>, isPresented: Binding<Bool>) {
        self.wallet = wallet
        self.address = address
        self.amount = amount
        self.memo = memo
        _path = path
        _isPresented = isPresented

        fromAddress = Core.shared.adapterManager.depositAdapter(for: wallet)?.receiveAddress.address
    }

    var body: some View {
        let _ = Self._printChanges()
        ThemeView {
            AddressView(token: wallet.token, buttonTitle: "send.next_button".localized, destination: .send(fromAddress: fromAddress), address: address) { resolvedAddress in
                print("[SEND-DEBUG] AddressView onFinish called with resolvedAddress: \(String(describing: resolvedAddress?.address))")
                if let resolvedAddress {
                    print("[SEND-DEBUG] About to path.append(resolvedAddress)")
                    path.append(resolvedAddress)
                    print("[SEND-DEBUG] path.append done")
                }
            }
        }
        .navigationTitle("address.title".localized)
        .navigationDestination(for: ResolvedAddress.self) { resolvedAddress in
            let _ = print("[SEND-DEBUG] navigationDestination closure invoked for address: \(resolvedAddress.address)")
            let _ = print("[SEND-DEBUG] About to build preSendHandler")
            if let handler = SendHandlerFactory.preSendHandler(wallet: wallet, address: resolvedAddress) {
                let _ = print("[SEND-DEBUG] Handler built: \(type(of: handler))")
                PreSendView(wallet: wallet, handler: handler, resolvedAddress: resolvedAddress, amount: amount, memo: memo, path: $path) {
                    isPresented = false
                }
                .toolbarRole(.editor)
            } else {
                let _ = print("[SEND-DEBUG] Handler is nil — no PreSendView will be shown")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if path.count == 0 {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image("close")
                    }
                }
            }
        }
    }
}

struct SendAddressViewWrapper: View {
    let wallet: Wallet
    @Binding var isPresented: Bool

    @State private var path = NavigationPath()

    var body: some View {
        ThemeNavigationStack(path: $path) {
            SendAddressView(wallet: wallet, path: $path, isPresented: $isPresented)
        }
    }
}
