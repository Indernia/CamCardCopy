import SwiftUI

struct ToolsView: View {
    private enum Pane {
        case recommend, smartSync
    }

    private static let helpInk = CCColor.iconInk
    private static let selectedInk = CCColor.tabSelected
    private static let unselectedInk = CCColor.textSecondary
    private static let selectorDivider = CCColor.groupedBackground
    private static let badgeRed = Color(hex: "#EB3324")

    @State private var pane: Pane = .recommend
    @State private var path: [AppRoute] = []
    @State private var didApplyRouteHook = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                selector
                ScrollView {
                    grid
                        .padding(.horizontal, 16)
                        .padding(.top, 17)
                        .padding(.bottom, 16)
                }
            }
            .background(CCColor.sheet)
            .toolbar(.hidden, for: .navigationBar)
            .appRoutes()
            .onAppear {
                guard !didApplyRouteHook else { return }
                didApplyRouteHook = true
                if let route = UITestRouteHook.route(from: ProcessInfo.processInfo.arguments) {
                    path.append(route)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text("Tools")
                .font(CCFont.pageTitle)
                .foregroundStyle(CCColor.textPrimary)
                .accessibilityIdentifier("tools.title")
            Spacer()
            Button {
                // TODO(P16-S01)
            } label: {
                HStack(spacing: 7) {
                    Text("Help")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Self.helpInk)
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Self.helpInk)
                }
            }
            .accessibilityIdentifier("tools.help")
            .accessibilityLabel("Help")
        }
        .padding(.leading, 18)
        .padding(.trailing, 19)
        .padding(.bottom, 7)
        .frame(height: 40)
    }

    private var selector: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                segment(.recommend, title: "Recommend")
                segment(.smartSync, title: "Smart sync")
            }
            .padding(.top, 14)
            Rectangle()
                .fill(Self.selectorDivider)
                .frame(height: 0.5)
        }
    }

    private func segment(_ pane: Pane, title: String) -> some View {
        let isSelected = self.pane == pane
        return Button {
            // TODO(P30-S01) Recommend pane; TODO(P30-S02) Smart sync pane
            self.pane = pane
        } label: {
            VStack(spacing: 15) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(isSelected ? Self.selectedInk : Self.unselectedInk)
                Capsule()
                    .fill(isSelected ? CCColor.accent : Color.clear)
                    .frame(width: 23, height: 2)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(
            pane == .recommend ? "tools.segment.recommend" : "tools.segment.smartSync"
        )
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var grid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12.7
        ) {
            ForEach(tiles) { tile in
                tileButton(tile)
            }
        }
    }

    private var tiles: [ToolsTile] {
        switch pane {
        case .recommend:
            return [
                ToolsTile(
                    identifier: "tools.recommend.aiTranscription",
                    title: "AI Transcription",
                    symbol: "waveform",
                    tint: .purple,
                    showsNewBadge: true
                ),
                ToolsTile(
                    identifier: "tools.recommend.emailSignatures",
                    title: "Email Signatures",
                    symbol: "envelope",
                    tint: .blue
                ),
                ToolsTile(
                    identifier: "tools.recommend.videoConferenceCard",
                    title: "Video Conference Card",
                    symbol: "video",
                    tint: .indigo
                ),
                ToolsTile(
                    identifier: "tools.recommend.dashboard",
                    title: "Dashboard",
                    symbol: "chart.bar",
                    tint: .teal
                ),
                ToolsTile(
                    identifier: "tools.recommend.highAccuracy",
                    title: "High Accuracy",
                    symbol: "viewfinder",
                    tint: .orange
                ),
                ToolsTile(
                    identifier: "tools.recommend.teamBusinessCard",
                    title: "Team Business Card",
                    symbol: "person.3",
                    tint: .cyan
                )
            ]
        case .smartSync:
            return [
                ToolsTile(
                    identifier: "tools.sync.saveToContacts",
                    title: "Save to Contacts",
                    symbol: "person.crop.circle.badge.plus",
                    tint: .green
                ),
                ToolsTile(
                    identifier: "tools.sync.contactsBackup",
                    title: "Contacts Backup",
                    symbol: "arrow.triangle.2.circlepath",
                    tint: .gray
                ),
                ToolsTile(
                    identifier: "tools.sync.salesforce",
                    title: "Salesforce",
                    symbol: "cloud",
                    tint: .blue
                ),
                ToolsTile(
                    identifier: "tools.sync.googleContacts",
                    title: "Google Contacts",
                    symbol: "person.crop.square",
                    tint: .mint
                ),
                ToolsTile(
                    identifier: "tools.sync.outlookOffice365",
                    title: "Outlook/Office365",
                    symbol: "envelope.badge",
                    tint: .indigo
                ),
                ToolsTile(
                    identifier: "tools.sync.exportExcelVcf",
                    title: "Export to Excel/Vcf",
                    symbol: "square.and.arrow.up",
                    tint: .green
                )
            ]
        }
    }

    private func tileButton(_ tile: ToolsTile) -> some View {
        ZStack(alignment: .topTrailing) {
            Button {
                // TODO(P30-S01) Recommend tiles and TODO(P30-S02) Smart sync tiles
            } label: {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [tile.tint.opacity(0.7), tile.tint.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: tile.symbol)
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    LinearGradient(
                        colors: [Color.black.opacity(0), Color.black.opacity(0.25)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 188 * 0.4)

                    Text(tile.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.25), radius: 2)
                        .padding(.leading, 13.6)
                        .padding(.trailing, 8)
                        .padding(.bottom, 12)
                }
                .frame(height: 188)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(tile.identifier)
            .accessibilityLabel(tile.title)

            if tile.showsNewBadge {
                Text("New")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 37, height: 19.5)
                    .background(Capsule().fill(Self.badgeRed))
                    .padding(.top, 13.7)
                    .padding(.trailing, 9.7)
                    .allowsHitTesting(false)
                    .accessibilityIdentifier("\(tile.identifier).badge")
            }
        }
    }
}

private struct ToolsTile: Identifiable {
    let identifier: String
    let title: String
    let symbol: String
    let tint: Color
    var showsNewBadge: Bool = false

    var id: String { identifier }
}

#Preview {
    ToolsView()
}
