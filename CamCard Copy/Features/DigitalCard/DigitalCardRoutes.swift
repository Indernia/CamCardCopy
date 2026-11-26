import SwiftUI

/// Destinations for `.createCard`. Owned by add-tools-messages-digital-card.
@ViewBuilder
func digitalCardDestination(for route: AppRoute) -> some View {
    switch route {
    case .createCard(let step):
        CreateCardStepView(step: step)
    default:
        CCPlaceholderPage(title: route.title, stateID: route.stateID)
    }
}
