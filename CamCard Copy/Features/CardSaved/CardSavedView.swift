import SwiftUI
import UIKit

/// P06-S01. Group, Note and Sync/Export are deliberately inert until their
/// own changes exist.
struct CardSavedView: View {
    let card: CardRecord
    let onDone: () -> Void
    let onTakeNext: () -> Void

    @State private var thumbnail: UIImage?

    var body: some View {
        VStack(spacing: 20) {
            cardPanel
            actionRow
            Spacer(minLength: 0)
            takeNextButton
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Card Saved")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: onDone)
                    .accessibilityIdentifier("cardSaved.done")
            }
        }
        .task(id: card.id) {
            if let data = card.processedImage ?? card.originalImage {
                thumbnail = await CardImageThumbnail.make(from: data, maxPixelSize: 600)
            }
        }
    }

    private var cardPanel: some View {
        HStack(spacing: 12) {
            Group {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(white: 0.92)
                }
            }
            .frame(width: 120, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityIdentifier("cardSaved.thumbnail")

            VStack(alignment: .leading, spacing: 4) {
                // "Untitled" is a display placeholder; no name is stored.
                Text(card.name ?? "Untitled")
                    .font(.headline)
                if let company = card.company, !company.isEmpty {
                    Text(company)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
    }

    private var actionRow: some View {
        HStack(spacing: 0) {
            actionButton("Group", icon: "folder", identifier: "cardSaved.group")
            actionButton("Note", icon: "note.text", identifier: "cardSaved.note")
            actionButton("Sync", icon: "arrow.triangle.2.circlepath", isPremium: true, identifier: "cardSaved.sync")
            actionButton("Export", icon: "square.and.arrow.up", isPremium: true, identifier: "cardSaved.export")
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
    }

    private func actionButton(
        _ title: String,
        icon: String,
        isPremium: Bool = false,
        identifier: String
    ) -> some View {
        Button {
            // TODO(P07-S01): Add to group. TODO(P08-S01): Note screen.
            // TODO(P21-S01): Sync/Export premium flows.
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                HStack(spacing: 3) {
                    Text(title)
                        .font(.subheadline)
                    if isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.orange)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private var takeNextButton: some View {
        Button(action: onTakeNext) {
            Text("Take the next")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.accentColor))
                .foregroundStyle(.white)
        }
        .accessibilityIdentifier("cardSaved.takeNext")
    }
}
