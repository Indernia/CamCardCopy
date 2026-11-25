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
        .background(CCColor.sheet)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(CCColor.separator)
                .frame(height: 0.5)
        }
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedSystemImage : tab.systemImage)
                    .font(.system(size: 20))
                Text(tab.title)
                    .font(CCFont.tabLabel)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? CCColor.tabSelected : CCColor.tabUnselected)
        }
        .accessibilityIdentifier(tab.accessibilityIdentifier)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var scanButton: some View {
        Button(action: onScan) {
            Image(systemName: "camera.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(CCColor.scanGradient))
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("tab.scan")
        .accessibilityLabel("Scan")
    }
}
