import SwiftUI

/// Destinations for `.settings`, `.login` and `.paywall`. Owned by add-settings-pages.
@ViewBuilder
func settingsDestination(for route: AppRoute) -> some View {
    switch route {
    case .settings(let page):
        switch page {
        case .accountSync:
            // TODO(P10-S01): "Account and Sync" was not captured.
            CCPlaceholderPage(title: route.title, stateID: route.stateID)
        case .language: SettingsLanguageView()
        case .notifications: SettingsNotificationsView()
        case .privacy: SettingsPrivacyView()
        case .permissions: SettingsPermissionsView()
        case .helpFeedback: SettingsHelpFeedbackView()
        case .inviteFriends: SettingsInviteFriendsView()
        case .about: SettingsAboutView()
        case .piChecklist: SettingsPIChecklistView()
        }
    case .login:
        LoginEmailView()
    case .paywall:
        UpgradePlansView()
    default:
        CCPlaceholderPage(title: route.title, stateID: route.stateID)
    }
}
