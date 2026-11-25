import SwiftUI

/// Destinations for `.messages` and `.bizTips`. Owned by add-tools-messages-digital-card.
@ViewBuilder
func messagesDestination(for route: AppRoute) -> some View {
    // TODO(P31-S01): build Messages. TODO(P32-S01): build Biz Tips.
    CCPlaceholderPage(title: route.title, stateID: route.stateID)
}
