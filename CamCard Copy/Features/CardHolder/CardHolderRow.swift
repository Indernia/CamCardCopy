import SwiftUI
import UIKit

/// The stored corrected image when there is one, otherwise the original (audit bug 4).
nonisolated func cardDisplayImageData(_ card: CardRecord) -> Data? {
    card.processedImage ?? card.originalImage
}

/// TODO(P01-S02) / TODO(P01-S03): row layout is ASSUMPTION (not captured).
struct CardHolderRow: View {
    let card: CardRecord
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            thumbnailView
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name ?? "Untitled")
                    .font(CCFont.rowEmphasis)
                    .foregroundStyle(CCColor.textPrimary)
                if let company = card.company, !company.isEmpty {
                    Text(company)
                        .font(CCFont.secondary)
                        .foregroundStyle(CCColor.textSecondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .task(id: card.id) {
            if let data = cardDisplayImageData(card) {
                thumbnail = await CardImageThumbnail.make(from: data, maxPixelSize: 200)
            }
        }
    }

    private var thumbnailView: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.rectangle")
                    .font(.system(size: 20))
                    .foregroundStyle(CCColor.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CCColor.groupedBackground)
            }
        }
        .frame(width: 64, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
