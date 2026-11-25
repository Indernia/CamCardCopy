import SwiftUI

/// P15-S01 System permissions. The "Settings" link does not open iOS Settings.
struct SettingsPermissionsView: View {
    var body: some View {
        SettingsPageScaffold(title: "System permissions", identifier: "settings.page.permissions") {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ad tracking permission")
                        .font(.system(size: 16))
                        .foregroundStyle(CCColor.textPrimary)
                    Text("Personalized ads, cross-app tracking, attribution, ad fraud prevention")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#6B6B6B"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    // TODO(P15-S01): would open iOS Settings; out of scope.
                } label: {
                    HStack(spacing: 6) {
                        Text("Settings")
                            .font(.system(size: 16))
                            .foregroundStyle(CCColor.accent)
                        SettingsChevron()
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.permissions.settings")
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 21)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            .padding(.horizontal, 15)
            .padding(.top, 25)
        }
    }
}
