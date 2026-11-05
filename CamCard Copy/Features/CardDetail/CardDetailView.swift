import SwiftUI
import UIKit

struct CardDetailView: View {
    let card: CardRecord

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
        .accessibilityIdentifier("cardDetail")
    }

    @ViewBuilder
    private var cardImage: some View {
        if let data = card.originalImage, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
        }
    }

    @ViewBuilder
    private func field(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }

    @ViewBuilder
    private var groups: some View {
        if !card.groups.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text("Groups")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(card.groups) { group in
                    Text(group.name)
                }
            }
        }
    }

    @ViewBuilder
    private var notes: some View {
        if !card.notes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(card.notes) { note in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(note.text)
                        Text(note.createdAt, format: .dateTime.year().month().day().hour().minute())
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
