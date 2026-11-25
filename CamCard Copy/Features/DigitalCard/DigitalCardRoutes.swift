import SwiftUI

/// Destinations for `.createCard`. Owned by add-tools-messages-digital-card.
@ViewBuilder
func digitalCardDestination(for route: AppRoute) -> some View {
    // TODO(P33-S01): build Create your card steps 1-3 (P33-S01, P33-S02, P33-S03).
    CCPlaceholderPage(title: route.title, stateID: route.stateID)
}
