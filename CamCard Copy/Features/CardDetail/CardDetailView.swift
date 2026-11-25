import SwiftUI
import UIKit

struct CardDetailView: View {
    let card: CardRecord
    @State private var image: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                cardImage
                VStack(alignment: .leading, spacing: 12) {
                    field("Full Name", card.name)
                    field("Company", card.company)
                    field("Job Title", card.jobTitle)
                    field("Mobile", card.mobile)
                    field("Phone", card.phone)
                    field("Email", card.email)
                    field("Website", card.website)
                    field("Address", card.address)
                    groups
                }
                notes
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(CCColor.sheet)
        .ccPushedNavigationBar(title: "") // TODO(P09-S01): layout is ASSUMPTION (not captured)
        .task(id: card.id) {
            if let data = cardDisplayImageData(card) {
                image = await CardImageThumbnail.make(from: data, maxPixelSize: 1500)
            }
        }
        .accessibilityIdentifier("cardDetail")
    }

    @ViewBuilder
    private var cardImage: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(CCColor.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CCColor.groupedBackground)
                )
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(CCFont.secondary)
            .foregroundStyle(CCColor.textSecondary)
    }

    @ViewBuilder
    private func field(_ title: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                label(title)
                Text(value)
                    .font(CCFont.row)
                    .foregroundStyle(CCColor.textPrimary)
            }
        }
    }

    @ViewBuilder
    private var groups: some View {
        if !card.groups.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                label("Groups")
                ForEach(card.groups) { group in
                    Text(group.name)
                        .font(CCFont.row)
                        .foregroundStyle(CCColor.textPrimary)
                }
            }
        }
    }

    @ViewBuilder
    private var notes: some View {
        if !card.notes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                label("Notes")
                ForEach(card.notes) { note in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(note.text)
                            .font(CCFont.row)
                            .foregroundStyle(CCColor.textPrimary)
                        Text(note.createdAt, format: .dateTime.year().month().day().hour().minute())
                            .font(CCFont.secondary)
                            .foregroundStyle(CCColor.textSecondary)
                    }
                }
            }
        }
    }
}
