import SwiftUI

struct ToolsView: View {
    private enum Pane {
        case recommend, smartSync
    }

    @State private var pane: Pane = .recommend

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                selector
                ScrollView {
                    grid
                        .padding(16)
                }
            }
            .background(Color(.systemBackground))
            .toolbar(.hidden, for: .navigationBar)
            .appRoutes()
        }
    }

    private var header: some View {
        HStack {
            Text("Tools")
                .font(.largeTitle.bold())
                .accessibilityIdentifier("tools.title")
            Spacer()
            Button {
                // TODO(P16-S01)
            } label: {
                HStack(spacing: 4) {
                    Text("Help")
                    Image(systemName: "questionmark.circle.fill")
                }
                .font(.subheadline.weight(.medium))
            }
            .accessibilityIdentifier("tools.help")
            .accessibilityLabel("Help")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var selector: some View {
        HStack(spacing: 0) {
            segment(.recommend, title: "Recommend")
            segment(.smartSync, title: "Smart sync")
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }

    private func segment(_ pane: Pane, title: String) -> some View {
        Button {
            // TODO(P30-S01) Recommend pane; TODO(P30-S02) Smart sync pane
            self.pane = pane
        } label: {
            Text(title)
                .font(.headline)
                .foregroundStyle(self.pane == pane ? Color.primary : Color.secondary)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(self.pane == pane ? Color.accentColor : Color.clear)
                        .frame(height: 3)
                }
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(
            pane == .recommend ? "tools.segment.recommend" : "tools.segment.smartSync"
        )
        .accessibilityLabel(title)
    }

    private var grid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
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
                    tint: .purple
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

                Text(tile.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .shadow(radius: 2)
                    .padding(12)
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(tile.identifier)
        .accessibilityLabel(tile.title)
    }
}

private struct ToolsTile: Identifiable {
    let identifier: String
    let title: String
    let symbol: String
    let tint: Color

    var id: String { identifier }
}

#Preview {
    ToolsView()
}
