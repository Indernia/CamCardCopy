import SwiftUI

/// P13-S01 Notifications. Toggles show the observed state and never change.
struct SettingsNotificationsView: View {
    var body: some View {
        SettingsPageScaffold(title: "Notifications", identifier: "settings.page.notifications") {
            SettingsListSection {
                // TODO(P13-S01): real permission state is out of scope; "Disabled" is the observed value.
                HStack {
                    Text("Receive notifications")
                        .font(CCFont.row)
                        .foregroundStyle(CCColor.textPrimary)
                    Spacer(minLength: 8)
                    Text("Disabled")
                        .font(CCFont.row)
                        .foregroundStyle(SettingsStyle.value)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 50)
            }
            SettingsFooter(text: "Enable CamCard notifications via iPhone's Settings-> Notifications -> CamCard")
            SettingsListSection {
                SettingsToggleRow(
                    title: "Sound",
                    isOn: true,
                    labelIdentifier: "settings.notifications.sound",
                    toggleIdentifier: "settings.notifications.sound.toggle"
                )
                SettingsToggleRow(
                    title: "Vibrate",
                    isOn: true,
                    labelIdentifier: "settings.notifications.vibrate",
                    toggleIdentifier: "settings.notifications.vibrate.toggle"
                )
            }
        }
    }
}
