import SwiftUI

/// Destinations for `.settings`, `.login` and `.paywall`. Owned by add-settings-pages.
@ViewBuilder
func settingsDestination(for route: AppRoute) -> some View {
    // TODO(P12-S01): build the Settings sub-pages (P10-S01 to P19-S01), Login (P20-S01), Upgrade Plans (P21-S01).
    CCPlaceholderPage(title: route.title, stateID: route.stateID)
}
