import SwiftUI

/// Shared list of pushable destinations (design D7). No control pushes these yet.
enum AppRoute: Hashable {
    case messages
    case bizTips
    case createCard(step: Int)
    case settings(SettingsPage)
    case login
    case paywall

    var title: String {
        switch self {
        case .messages: "Messages"
        case .bizTips: "Biz Tips"
        case .createCard: "Create your card"
        case .settings(let page): page.title
        case .login: "Login via email"
        case .paywall: "Upgrade Plans"
        }
    }

    var stateID: String {
        switch self {
        case .messages: "P31-S01"
        case .bizTips: "P32-S01"
        case .createCard(let step): "P33-S0\(min(max(step, 1), 3))"
        case .settings(let page): page.stateID
        case .login: "P20-S01"
        case .paywall: "P21-S01"
        }
    }
}

enum SettingsPage: CaseIterable, Hashable {
    case accountSync, language, notifications, privacy, permissions
    case helpFeedback, inviteFriends, about, piChecklist

    var title: String {
        switch self {
        case .accountSync: "Account and Sync"
        case .language: "Language setting"
        case .notifications: "Notifications"
        case .privacy: "Privacy Settings"
        case .permissions: "System permissions"
        case .helpFeedback: "Help and Feedback"
        case .inviteFriends: "Recommend to Friends"
        case .about: "About"
        case .piChecklist: "Personal Information Collection Checklist"
        }
    }

    var stateID: String {
        switch self {
        case .accountSync: "P10-S01" // ASSUMPTION: not captured
        case .language: "P12-S01"
        case .notifications: "P13-S01"
        case .privacy: "P14-S01"
        case .permissions: "P15-S01"
        case .helpFeedback: "P16-S01"
        case .inviteFriends: "P17-S01"
        case .about: "P18-S01"
        case .piChecklist: "P19-S01"
        }
    }
}

extension View {
    /// Registers every route once per navigation stack; each feature folder owns its destinations.
    func appRoutes() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .messages, .bizTips:
                messagesDestination(for: route)
            case .createCard:
                digitalCardDestination(for: route)
            case .settings, .login, .paywall:
                settingsDestination(for: route)
            }
        }
    }
}
