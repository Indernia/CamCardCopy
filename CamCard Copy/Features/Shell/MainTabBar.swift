import SwiftUI

struct MainTabBar: View {
    @Binding var selectedTab: AppTab
    let onScan: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            tabButton(for: .home)
            tabButton(for: .cardHolder)
            scanButton
            tabButton(for: .tools)
            tabButton(for: .settings)
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(.bar)
    }

    private func tabButton(for tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 20))
                Text(tab.title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selectedTab == tab ? Color.primary : Color.secondary)
        }
        .accessibilityIdentifier(tab.accessibilityIdentifier)
    }

    private var scanButton: some View {
        Button(action: onScan) {
            Image(systemName: "camera.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.purple))
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("tab.scan")
        .accessibilityLabel("Scan")
    }
}
