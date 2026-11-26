import SwiftUI

/// P31-S01: the Messages list with its single Biz Tips row (design D4). Inert apart from the row link.
struct MessagesView: View {
    private static let pageBackground = CCColor.groupedBackground
    private static let rowTitle = CCColor.textPrimary
    private static let rowSubtitle = Color(hex: "#9F9F9F")
    private static let rowHairline = Color(hex: "#EEEEEE")
    private static let avatarFill = Color(hex: "#FDEEE5")
    private static let avatarGlyph = Color(hex: "#F3AF81")

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(value: AppRoute.bizTips) {
                row
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("messages.row.bizTips")
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Self.pageBackground.ignoresSafeArea())
        .ccPushedNavigationBar(title: "Messages")
    }

    private var row: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Self.avatarFill)
                .frame(width: 48.8, height: 48.8)
                .overlay {
                    Image(systemName: "ellipsis.bubble.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Self.avatarGlyph)
                }
                .padding(.leading, 17)
                .padding(.trailing, 17.5)
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("Biz Tips")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Self.rowTitle)
                    Spacer(minLength: 0)
                    Text("Sunday")
                        .font(CCFont.secondary)
                        .foregroundStyle(Self.rowSubtitle)
                }
                Text("Great business begins with a great first impression")
                    .font(CCFont.row)
                    .foregroundStyle(Self.rowSubtitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.trailing, 14.3)
            .offset(y: 2.8)
        }
        .frame(height: 78)
        .frame(maxWidth: .infinity)
        .background(CCColor.sheet)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Self.rowHairline).frame(height: 0.5)
        }
        .contentShape(Rectangle())
    }
}
