import SwiftUI

/// Header on the header tint, white rounded sheet below (design D5).
struct CCTintedHeaderLayout<Header: View, Content: View>: View {
    let header: Header
    let content: Content

    init(@ViewBuilder header: () -> Header, @ViewBuilder content: () -> Content) {
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .frame(maxWidth: .infinity)
                .background(CCColor.headerTint.ignoresSafeArea(edges: .top))
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16)
                        .fill(CCColor.sheet)
                        .ignoresSafeArea(edges: .bottom)
                )
        }
        .background(CCColor.headerTint.ignoresSafeArea())
    }
}

/// Plain toolbar icon: no glass, no circle (design D5).
struct CCIconButton: View {
    let systemName: String
    let identifier: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20))
                .foregroundStyle(CCColor.iconInk)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(label)
    }
}

private struct CCPushedNavigationBar: ViewModifier {
    let title: String
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CCIconButton(
                        systemName: "chevron.left",
                        identifier: "nav.back",
                        label: "Back",
                        action: { dismiss() }
                    )
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(CCFont.navTitle)
                        .foregroundStyle(CCColor.textPrimary)
                }
                .sharedBackgroundVisibility(.hidden)
            }
    }
}

extension View {
    /// Plain "‹" back chevron and a centered title; no system back button, no glass.
    func ccPushedNavigationBar(title: String) -> some View {
        modifier(CCPushedNavigationBar(title: title))
    }
}

/// Barebones page for destinations that are not built yet.
struct CCPlaceholderPage: View {
    let title: String
    let stateID: String

    var body: some View {
        VStack(spacing: 8) {
            Text("Not built yet")
                .font(CCFont.secondary)
                .foregroundStyle(CCColor.textSecondary)
            Text(stateID)
                .font(CCFont.secondary)
                .foregroundStyle(CCColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CCColor.sheet)
        .ccPushedNavigationBar(title: title)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("placeholder.route.\(stateID)")
    }
}
