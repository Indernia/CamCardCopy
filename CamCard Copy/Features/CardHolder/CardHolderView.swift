import SwiftUI
import UIKit

struct CardHolderView: View {
    @State private var viewModel: CardHolderViewModel

    init(repository: CardRepository) {
        _viewModel = State(initialValue: CardHolderViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchPill
                List {
                    Section {
                        if viewModel.cards.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.cards) { card in
                                NavigationLink(value: card) {
                                    CardRow(card: card)
                                }
                                .accessibilityIdentifier("card.row")
                            }
                        }
                    } header: {
                        Text("Cards")
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("CardHolder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // TODO(P31-S01)
                    } label: {
                        Image(systemName: "bell")
                    }
                    .accessibilityIdentifier("cardholder.bell")
                    .accessibilityLabel("Notifications")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO(P01-S08)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .accessibilityIdentifier("cardholder.add")
                    .accessibilityLabel("Add card")
                }
            }
            .navigationDestination(for: CardRecord.self) { card in
                CardDetailView(card: card)
            }
            .appRoutes()
            .task {
                viewModel.load()
            }
        }
    }

    private var searchPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            Text("Search")
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Capsule().fill(Color(.secondarySystemBackground)))
        .accessibilityIdentifier("cardholder.search")
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.rectangle.stack")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No cards")
                .font(.headline)
            Text("You can use the business card recognition function to upload business cards and efficiently manage your contacts")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowSeparator(.hidden)
    }
}

private struct CardRow: View {
    let card: CardRecord

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name ?? "Untitled")
                    .font(.headline)
                if let company = card.company, !company.isEmpty {
                    Text(company)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = card.originalImage, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 22))
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemBackground))
                )
        }
    }
}
