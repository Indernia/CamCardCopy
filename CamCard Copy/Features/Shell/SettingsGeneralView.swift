import SwiftUI

struct SettingsGeneralView: View {
    var body: some View {
        List {
            Section {
                // TODO(P11-S01)
                valueRow(
                    "New cards autosaved to Contacts",
                    value: "Off",
                    identifier: "settings.general.newCardsAutosaved"
                )
            }
            Section {
                // TODO(P11-S01)
                inertRow("Font Size", identifier: "settings.general.fontSize")
                // TODO(P11-S01)
                inertRow("Recognition Languages", identifier: "settings.general.recognitionLanguages")
                // ASSUMPTION: P11-S01 shows this off; reference/observations.md notes P07-S01 shows it on.
                toggleRow(
                    "Show group settings when saving cards",
                    labelIdentifier: "settings.general.showGroupSettings",
                    toggleIdentifier: "settings.general.showGroupSettings.toggle"
                )
                toggleRow(
                    "Save Card Image",
                    labelIdentifier: "settings.general.saveCardImage",
                    toggleIdentifier: "settings.general.saveCardImage.toggle"
                )
            }
            Section {
                // TODO(P11-S01)
                valueRow(
                    "Sort Order",
                    value: "First, Last",
                    identifier: "settings.general.sortOrder"
                )
                // TODO(P11-S01)
                valueRow(
                    "Display Order",
                    value: "First, Last",
                    identifier: "settings.general.displayOrder"
                )
            }
            Section {
                // TODO(P11-S01)
                valueRow(
                    "Clear your space",
                    value: "Not logged in",
                    identifier: "settings.general.clearYourSpace"
                )
            }
            Section {
                // TODO(P11-S01)
                inertRow("App Lock", identifier: "settings.general.appLock")
            } footer: {
                Text("Once enabled, a password will be required to open the app")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("General")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func inertRow(_ title: String, identifier: String) -> some View {
        Button {
            // TODO(P11-S01)
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(title)
    }

    private func valueRow(_ title: String, value: String, identifier: String) -> some View {
        Button {
            // TODO(P11-S01)
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel("\(title), \(value)")
    }

    private func toggleRow(
        _ title: String,
        labelIdentifier: String,
        toggleIdentifier: String
    ) -> some View {
        HStack {
            Text(title)
                .accessibilityIdentifier(labelIdentifier)
            Spacer()
            Toggle("", isOn: .constant(false))
                .labelsHidden()
                .disabled(true)
                .accessibilityIdentifier(toggleIdentifier)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsGeneralView()
    }
}
