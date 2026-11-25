import SwiftUI

/// P18-S01 About. Version comes from our own bundle and the IntSig copyright line is omitted (design D6).
struct SettingsAboutView: View {
    private var version: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        return "CamCard Copy \(short)"
    }

    var body: some View {
        SettingsPageScaffold(title: "About", identifier: "settings.page.about") {
            SettingsListSection {
                SettingsInertRow(title: "Rate It Now", identifier: "settings.about.rate") // TODO(P18-S01)
                SettingsInertRow(title: "Follow us", identifier: "settings.about.follow") // TODO(P18-S01)
                SettingsInertRow(title: "Contact Us", identifier: "settings.about.contact") // TODO(P18-S01)
            }
            VStack(spacing: 6) {
                Text(version)
                    .font(CCFont.row)
                    .foregroundStyle(Color(hex: "#9F9F9F"))
                // TODO(P18-S01): the terms and privacy links are inert text.
                HStack(spacing: 4) {
                    Text("CamCardTerms of Service")
                        .foregroundStyle(Color(hex: "#6292DC"))
                    Text("and")
                        .foregroundStyle(Color(hex: "#9F9F9F"))
                    Text("CamCardPrivacy Policy")
                        .foregroundStyle(Color(hex: "#6292DC"))
                }
                .font(CCFont.secondary)
                // D6: the IntSig copyright line is replaced by an empty line of the same height.
                Text(" ")
                    .font(CCFont.secondary)
                    .padding(.top, 12)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
        }
    }
}
