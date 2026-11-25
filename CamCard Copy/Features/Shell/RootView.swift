import SwiftUI

struct RootView: View {
    let repository: CardRepository

    @State private var selectedTab: AppTab = .home
    @State private var isScanPresented = false
    /// Bumped when a card is saved so CardHolder reloads even if it is already selected.
    @State private var cardHolderRefresh = 0
    /// Pushed pages hide the tab bar (fix-pushed-page-chrome D2).
    @State private var tabBarVisibility = TabBarVisibility()

    var body: some View {
        VStack(spacing: 0) {
            content
            if !tabBarVisibility.isHidden {
                MainTabBar(selectedTab: $selectedTab, onScan: { isScanPresented = true })
            }
        }
        .environment(tabBarVisibility)
        .fullScreenCover(isPresented: $isScanPresented) {
            ScanFlowView(
                repository: repository,
                onDone: {
                    // ASSUMPTION (P01-S02 not captured): Done lands on CardHolder with the new card.
                    cardHolderRefresh += 1
                    selectedTab = .cardHolder
                    isScanPresented = false
                }
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .home:
            NavigationStack {
                HomeView()
                    .toolbar(.hidden, for: .navigationBar)
                    .appRoutes()
            }
        case .cardHolder:
            CardHolderView(repository: repository)
                .id(cardHolderRefresh)
        case .tools:
            ToolsView()
        case .settings:
            SettingsView()
        }
    }
}
