import SwiftUI

enum CardHolderSearch {
    /// Case-insensitive substring match on name and company; keeps input order.
    static func filter(_ cards: [CardRecord], query: String) -> [CardRecord] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return cards }
        return cards.filter { card in
            (card.name?.localizedCaseInsensitiveContains(trimmed) ?? false)
                || (card.company?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
    }
}

/// White capsule on the header tint. TODO(P01-S04): searching layout is ASSUMPTION (not captured).
struct CardHolderSearchBar: View {
    @Bindable var viewModel: CardHolderViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            if viewModel.isSearching {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(CCColor.textSecondary)
                    TextField("Search", text: $viewModel.query)
                        .font(CCFont.row)
                        .foregroundStyle(CCColor.textPrimary)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("cardholder.search.field")
                }
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(Capsule().fill(CCColor.sheet))

                Button("Cancel") {
                    isFocused = false
                    viewModel.cancelSearch()
                }
                .font(CCFont.row)
                .foregroundStyle(CCColor.iconInk)
                .accessibilityIdentifier("cardholder.search.cancel")
            } else {
                Button {
                    guard !viewModel.cards.isEmpty else { return }
                    viewModel.isSearching = true
                    isFocused = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                            .font(CCFont.row)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(CCColor.textSecondary)
                    .padding(.horizontal, 14)
                    .frame(height: 38)
                    .background(Capsule().fill(CCColor.sheet))
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("cardholder.search")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 17)
    }
}
