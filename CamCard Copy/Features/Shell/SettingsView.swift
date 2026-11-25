import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    signInCard
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                Section {
                    premiumCard
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                settingsSection
                Section {
                    // TODO(P10-S01)
                    inertRow("Resume In-APP Purchases", identifier: "settings.row.resumePurchases")
                }
                Section {
                    // TODO(P16-S01)
                    inertRow("Help and Feedback", identifier: "settings.row.helpFeedback")
                    // TODO(P17-S01)
                    inertRow("Recommend to Friends", identifier: "settings.row.recommendFriends")
                } header: {
                    Text("Help and Feedback")
                        .textCase(nil)
                }
                Section {
                    // TODO(P18-S01)
                    inertRow("About", identifier: "settings.row.about")
                    // TODO(P19-S01)
                    inertRow(
                        "Personal Information Collection Checklist",
                        identifier: "settings.row.personalInfoChecklist"
                    )
                } header: {
                    Text("ABOUT CAMCARD")
                        .textCase(nil)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
        }
    }

    private var settingsSection: some View {
        Section {
            // TODO(P10-S01)
            inertRow("Account and Sync", identifier: "settings.row.accountAndSync")
            NavigationLink {
                SettingsGeneralView()
            } label: {
                Text("General")
            }
            .accessibilityIdentifier("settings.row.general")
            // TODO(P12-S01)
            inertRow("Language setting", identifier: "settings.row.languageSetting")
            // TODO(P13-S01)
            inertRow("Notifications", identifier: "settings.row.notifications")
            // TODO(P14-S01)
            inertRow("Privacy Settings", identifier: "settings.row.privacySettings")
            // TODO(P15-S01)
            inertRow("System permissions", identifier: "settings.row.systemPermissions")
        } header: {
            Text("APP SETTINGS")
                .textCase(nil)
        }
    }

    private var signInCard: some View {
        VStack(spacing: 18) {
            Button {
                // TODO(P20-S01)
            } label: {
                HStack {
                    Text("Sign in to access more features")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings.signIn")
            .accessibilityLabel("Sign in to access more features")

            HStack(spacing: 0) {
                providerIcon { Image(systemName: "envelope") }
                providerIcon { Image(systemName: "iphone") }
                providerIcon { Text("G").font(.headline.weight(.bold)) }
                providerIcon { Image(systemName: "person.crop.circle") }
                providerIcon { Text("in").font(.headline.weight(.bold)) }
                providerIcon { Text("f").font(.headline.weight(.bold)) }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func providerIcon<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(width: 44, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
            .frame(maxWidth: .infinity)
    }

    private var premiumCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.orange)
                Text("Premium")
                    .font(.headline)
                Spacer()
                Button {
                    // TODO(P21-S01)
                } label: {
                    HStack(spacing: 4) {
                        Text("Upgrade")
                        Image(systemName: "plus")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.orange))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.premium.upgrade")
                .accessibilityLabel("Upgrade +")
            }

            HStack(spacing: 0) {
                premiumItem(
                    "Unlimited Scan",
                    symbol: "rectangle.on.rectangle",
                    identifier: "settings.premium.unlimitedScan"
                )
                premiumItem(
                    "Sync CRM",
                    symbol: "icloud",
                    identifier: "settings.premium.syncCRM"
                )
                premiumItem(
                    "Export to Excel",
                    symbol: "square.and.pencil",
                    identifier: "settings.premium.exportExcel"
                )
                premiumItem(
                    "Back up",
                    symbol: "person.badge.clock",
                    identifier: "settings.premium.backUp"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.22), Color.orange.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private func premiumItem(_ title: String, symbol: String, identifier: String) -> some View {
        Button {
            // TODO(P21-S01)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.orange)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.orange.opacity(0.15)))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(title)
    }

    private func inertRow(_ title: String, identifier: String) -> some View {
        Button {
            // The state named above keeps this row inert.
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
}

#Preview {
    SettingsView()
}
