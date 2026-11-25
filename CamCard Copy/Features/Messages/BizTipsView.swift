import SwiftUI

/// P32-S01: the Biz Tips feed with one inert card (design D5). No CamCard artwork.
struct BizTipsView: View {
    private static let dateInk = Color(hex: "#656565")
    private static let cardBorder = Color(hex: "#D8D8D8")
    private static let titleInk = Color(hex: "#1A1A1A")
    private static let bandFill = Color(hex: "#1D3C8A")

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Sunday")
                    .font(CCFont.secondary)
                    .foregroundStyle(Self.dateInk)
                    .padding(.top, 18)
                    .padding(.bottom, 8.5)
                card
                    .padding(.horizontal, 9)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CCColor.groupedBackground.ignoresSafeArea())
        .ccPushedNavigationBar(title: "Biz Tips")
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner
                .padding(7)
            Text("Welcome to CamCard")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Self.titleInk)
                .padding(.leading, 11.2)
                .padding(.top, 12.4)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CCColor.sheet)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Self.cardBorder, lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture {
            // TODO(P32-S02): article view not captured
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("bizTips.card")
    }

    private var banner: some View {
        LinearGradient(
            colors: [Color(hex: "#3272F5"), Color(hex: "#22458D")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 173)
        .overlay(alignment: .bottom) {
            Text("Great business begins with a great first impression")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.leading, 11.2)
                .padding(.trailing, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 29)
                .background(Self.bandFill.opacity(0.85))
        }
        .clipped()
    }
}
