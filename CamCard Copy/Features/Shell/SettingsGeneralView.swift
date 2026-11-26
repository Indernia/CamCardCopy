import SwiftUI

/// P11-S01 General. Read-only: rows open nothing and toggles show off and never change (design D4).
struct SettingsGeneralView: View {
    var body: some View {
        SettingsPageScaffold(title: "General", identifier: "settings.page.general") {
            SettingsListSection {
                // TODO(P11-S01)
                SettingsInertRow(
                    title: "New cards autosaved to Contacts",
                    value: "Off",
                    identifier: "settings.general.newCardsAutosaved"
                )
            }
            SettingsListSection {
                // TODO(P11-S01)
                SettingsInertRow(title: "Font Size", identifier: "settings.general.fontSize")
                // TODO(P11-S01)
                SettingsInertRow(title: "Recognition Languages", identifier: "settings.general.recognitionLanguages")
                // ASSUMPTION: P11-S01 shows this off; reference/observations.md notes P07-S01 shows it on.
                SettingsToggleRow(
                    title: "Show group settings when saving cards",
                    isOn: false,
                    labelIdentifier: "settings.general.showGroupSettings",
                    toggleIdentifier: "settings.general.showGroupSettings.toggle"
                )
                SettingsToggleRow(
                    title: "Save Card Image",
                    isOn: false,
                    labelIdentifier: "settings.general.saveCardImage",
                    toggleIdentifier: "settings.general.saveCardImage.toggle"
                )
            }
            SettingsListSection {
                // TODO(P11-S01)
                SettingsInertRow(title: "Sort Order", value: "First, Last", identifier: "settings.general.sortOrder")
                // TODO(P11-S01)
                SettingsInertRow(title: "Display Order", value: "First, Last", identifier: "settings.general.displayOrder")
            }
            SettingsListSection {
                // TODO(P11-S01)
                SettingsInertRow(
                    title: "Clear your space",
                    value: "Not logged in",
                    identifier: "settings.general.clearYourSpace"
                )
            }
            SettingsListSection {
                // TODO(P11-S01)
                SettingsInertRow(title: "App Lock", identifier: "settings.general.appLock")
            }
            SettingsFooter(text: "Once enabled, a password will be required to open the app")
        }
        .navigationTitle("General")
    }
}

#Preview {
    NavigationStack {
        SettingsGeneralView()
    }
}
