import SwiftUI

/// P14-S01 Privacy Settings. The consent toggle shows off and never changes.
struct SettingsPrivacyView: View {
    var body: some View {
        SettingsPageScaffold(title: "Privacy Settings", identifier: "settings.page.privacy") {
            SettingsListSection {
                SettingsToggleRow(
                    title: "AI Data Processing Consent",
                    isOn: false,
                    labelIdentifier: "settings.privacy.aiConsent",
                    toggleIdentifier: "settings.privacy.aiConsent.toggle",
                    rowHeight: 59
                )
            }
            // TODO(P14-S01): "Third Party List" is not a tappable link in the capture.
            SettingsFooter(
                text: "For information about CamCard's third-party AI services, tap Third Party List."
            )
        }
    }
}
