import SwiftUI

struct RootView: View {
    let repository: CardRepository

    @State private var selectedTab: AppTab = .home
    @State private var isScanPresented = false

    var body: some View {
        VStack(spacing: 0) {
            content
            MainTabBar(selectedTab: $selectedTab, onScan: { isScanPresented = true })
        }
        .fullScreenCover(isPresented: $isScanPresented) {
            ScanPlaceholderView()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .home:
            PlaceholderView(title: "Home")
        case .cardHolder:
            CardHolderView(repository: repository)
        case .tools:
            PlaceholderView(title: "Tools")
        case .settings:
            PlaceholderView(title: "Settings")
        }
    }
}
