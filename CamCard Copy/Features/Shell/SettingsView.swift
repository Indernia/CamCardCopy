import SwiftUI

/// P10-S01 Settings root: pinned header, sign-in card, Premium card and grouped rows (design D3).
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Settings")
                    .font(CCFont.pageTitle)
                    .foregroundStyle(CCColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
                ScrollView {
                    VStack(spacing: 0) {
                        signInCard
                        premiumCard.padding(.top, 15)
                        sectionHeader("APP SETTINGS")
                        SettingsGroup {
                            routeRow("Account and Sync", route: .settings(.accountSync), id: "accountAndSync")
                            NavigationLink {
                                SettingsGeneralView()
                            } label: {
                                SettingsRowContent(title: "General")
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settings.row.general")
                            routeRow("Language setting", route: .settings(.language), id: "languageSetting")
                            routeRow("Notifications", route: .settings(.notifications), id: "notifications")
                            routeRow("Privacy Settings", route: .settings(.privacy), id: "privacySettings")
                            routeRow("System permissions", route: .settings(.permissions), id: "systemPermissions")
                        }
                        SettingsGroup {
                            // TODO(P10-S01): a purchase action with no captured screen, so it stays inert.
                            SettingsInertRow(
                                title: "Resume In-APP Purchases",
                                identifier: "settings.row.resumePurchases"
                            )
                        }
                        .padding(.top, 12)
                        sectionHeader("Help and Feedback")
                        SettingsGroup {
                            routeRow("Help and Feedback", route: .settings(.helpFeedback), id: "helpFeedback")
                            routeRow("Recommend to Friends", route: .settings(.inviteFriends), id: "recommendFriends")
                        }
                        sectionHeader("ABOUT CAMCARD")
                        SettingsGroup {
                            routeRow("About", route: .settings(.about), id: "about")
                            routeRow(
                                "Personal Information Collection Checklist",
                                route: .settings(.piChecklist),
                                id: "personalInfoChecklist"
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 25)
                    .padding(.bottom, 24)
                }
            }
            .background(CCColor.sheet)
            .toolbar(.hidden, for: .navigationBar)
            .appRoutes()
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(CCFont.sectionHeader)
            .foregroundStyle(CCColor.sectionHeader)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 31)
            .padding(.bottom, 12)
    }

    private func routeRow(_ title: String, route: AppRoute, id: String) -> some View {
        NavigationLink(value: route) {
            SettingsRowContent(title: title)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("settings.row.\(id)")
        .accessibilityLabel(title)
    }

    private var signInCard: some View {
        VStack(spacing: 23) {
            NavigationLink(value: AppRoute.login) {
                HStack(spacing: 8) {
                    Text("Sign in to access more features")
                        .font(CCFont.row)
                        .foregroundStyle(CCColor.textPrimary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(CCColor.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings.signIn")
            .accessibilityLabel("Sign in to access more features")

            HStack(spacing: 0) {
                providerTile { Image(systemName: "envelope.fill") }
                providerTile { Image(systemName: "iphone") }
                providerTile { Text("G").font(.system(size: 22, weight: .bold)) }
                providerTile { Image(systemName: "apple.logo") }
                providerTile { Text("in").font(.system(size: 22, weight: .bold)) }
                providerTile { Text("f").font(.system(size: 24, weight: .bold)) }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 28)
        .padding(.bottom, 13)
        .background(RoundedRectangle(cornerRadius: 12).fill(CCColor.groupedCard))
    }

    private func providerTile<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .font(.system(size: 20))
            .foregroundStyle(Color(hex: "#4A4A4A"))
            .frame(width: 41, height: 42)
            .background(RoundedRectangle(cornerRadius: 10).fill(.white))
            .frame(maxWidth: .infinity)
    }

    private var premiumCard: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: "#DDAA5B"))
                Text("Premium")
                    .font(CCFont.sectionTitle)
                    .foregroundStyle(CCColor.textPrimary)
                Spacer()
                NavigationLink(value: AppRoute.paywall) {
                    HStack(spacing: 4) {
                        Text("Upgrade")
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .font(CCFont.rowEmphasis)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 28)
                    .background(Capsule().fill(CCColor.premiumGradient))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.premium.upgrade")
                .accessibilityLabel("Upgrade +")
            }

            HStack(spacing: 0) {
                premiumItem("Unlimited Scan", symbol: "viewfinder", identifier: "settings.premium.unlimitedScan")
                premiumItem("Sync CRM", symbol: "icloud", identifier: "settings.premium.syncCRM")
                premiumItem("Export to Excel", symbol: "tablecells", identifier: "settings.premium.exportExcel")
                premiumItem("Back up", symbol: "person.crop.circle.badge.clock", identifier: "settings.premium.backUp")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 21)
        .padding(.bottom, 24)
        .background(RoundedRectangle(cornerRadius: 12).fill(CCColor.premiumCard))
    }

    private func premiumItem(_ title: String, symbol: String, identifier: String) -> some View {
        NavigationLink(value: AppRoute.paywall) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SettingsStyle.premiumInk)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(SettingsStyle.premiumCircle))
                Text(title)
                    .font(CCFont.secondary)
                    .foregroundStyle(CCColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
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
