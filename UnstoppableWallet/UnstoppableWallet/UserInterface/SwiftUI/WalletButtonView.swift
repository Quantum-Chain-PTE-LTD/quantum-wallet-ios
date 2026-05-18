import SwiftUI

struct WalletButtonView: View {
    let icon: String
    let title: String
    let accent: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(title)
                    .textCaptionSB(color: .themeLawrence)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52)
            .padding(.horizontal, 12)
            .foregroundStyle(Color.themeLawrence)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(accent ? Color.themeJacob : Color.themeLeah)
            )
        }
        .buttonStyle(.plain)
    }
}
