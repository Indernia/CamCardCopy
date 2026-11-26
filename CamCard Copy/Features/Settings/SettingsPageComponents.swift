import SwiftUI

/// Page-local constants for Settings values that are not shared tokens (add-settings-pages D1).
enum SettingsStyle {
    static let value = Color(hex: "#A0A0A0")
    static let chevron = Color(hex: "#A1A1A1")
    static let blueTitle = Color(hex: "#4DADF7")
    static let premiumInk = CCColor.color(.premiumGradientStart)
    static let premiumCircle = Color(hex: "#FCE8AD")
}

struct SettingsChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(SettingsStyle.chevron)
            .accessibilityHidden(true)
    }
}

/// Container whose rows are split by inset separators: the root's rounded `#FAFAFA` group, or a full-width white list section.
struct SettingsGroup<Content: View>: View {
    var fill: Color = CCColor.groupedCard
    var radius: CGFloat = 12
    var separator: Color = .white
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content) { subviews in
                ForEach(subviews) { subview in
                    subview
                    if subview.id != subviews.last?.id {
                        Rectangle()
                            .fill(separator)
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: radius).fill(fill))
        .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

/// Full-width white section used on pushed list pages (P11 to P14, P18).
struct SettingsListSection<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        SettingsGroup(fill: .white, radius: 0, separator: CCColor.separator) { content }
    }
}

/// Title, optional grey value and optional chevron on one row.
struct SettingsRowContent: View {
    let title: String
    var value: String?
    var showsChevron = true

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(CCFont.row)
                .foregroundStyle(CCColor.textPrimary)
            Spacer(minLength: 8)
            if let value {
                Text(value)
                    .font(CCFont.row)
                    .foregroundStyle(SettingsStyle.value)
            }
            if showsChevron {
                SettingsChevron()
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 50)
        .contentShape(Rectangle())
    }
}

/// A row that looks tappable but opens nothing.
struct SettingsInertRow: View {
    let title: String
    var value: String?
    var showsChevron = true
    let identifier: String

    var body: some View {
        Button {
            // Inert visual copy: the caller's TODO(P##-S##) names the screen it copies.
        } label: {
            SettingsRowContent(title: title, value: value, showsChevron: showsChevron)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(value.map { "\(title), \($0)" } ?? title)
    }
}

/// A toggle row that shows an observed state and never changes (design D4).
struct SettingsToggleRow: View {
    let title: String
    let isOn: Bool
    let labelIdentifier: String
    let toggleIdentifier: String
    var rowHeight: CGFloat = 50

    var body: some View {
        HStack {
            Text(title)
                .font(CCFont.row)
                .foregroundStyle(CCColor.textPrimary)
                .accessibilityIdentifier(labelIdentifier)
            Spacer(minLength: 8)
            Toggle("", isOn: .constant(isOn))
                .labelsHidden()
                .tint(CCColor.accent)
                .accessibilityIdentifier(toggleIdentifier)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: rowHeight)
    }
}

struct SettingsFooter: View {
    let text: String

    var body: some View {
        Text(text)
            .font(CCFont.secondary)
            .foregroundStyle(SettingsStyle.value)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }
}

/// Grey page under the pushed-page bar with a scrollable stack of sections.
struct SettingsPageScaffold<Content: View>: View {
    let title: String
    let identifier: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                content
            }
            .padding(.top, 10)
            .frame(maxWidth: .infinity)
        }
        .background(CCColor.groupedBackground.ignoresSafeArea())
        .ccPushedNavigationBar(title: title)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(identifier)
    }
}
