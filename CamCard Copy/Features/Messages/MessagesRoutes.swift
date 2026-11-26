import SwiftUI

/// Destinations for `.messages` and `.bizTips`. Owned by add-tools-messages-digital-card.
@ViewBuilder
func messagesDestination(for route: AppRoute) -> some View {
    switch route {
    case .bizTips:
        BizTipsView()
    default:
        MessagesView()
    }
}
