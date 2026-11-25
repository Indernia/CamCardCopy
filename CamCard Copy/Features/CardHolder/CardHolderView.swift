import SwiftUI

struct CardHolderView: View {
    @State private var viewModel: CardHolderViewModel

    init(repository: CardRepository) {
        _viewModel = State(initialValue: CardHolderViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            CCTintedHeaderLayout {
                CardHolderSearchBar(viewModel: viewModel)
            } content: {
                sheetContent
            }
            .navigationTitle("CardHolder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(CCColor.headerTint, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: AppRoute.messages) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundStyle(CCColor.iconInk)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("cardholder.bell")
                    .accessibilityLabel("Notifications")
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .principal) {
                    Text("CardHolder")
                        .font(CCFont.navTitle)
                        .foregroundStyle(CCColor.textPrimary)
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .topBarTrailing) {
                    addMenu
                }
                .sharedBackgroundVisibility(.hidden)
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

    private var addMenu: some View {
        Menu {
            Button("Scan card") {
                // TODO(P01-S08)
            }
            Button("Import from album") {
                // TODO(P01-S08)
            }
        } label: {
            Image(systemName: "plus.circle")
                .font(.system(size: 20))
                .foregroundStyle(CCColor.iconInk)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityIdentifier("cardholder.add")
        .accessibilityLabel("Add card")
    }

    private var sheetContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Cards")
                .font(.system(size: 16))
                .foregroundStyle(CCColor.textPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 15)
                .padding(.bottom, 8)
            if viewModel.cards.isEmpty {
                emptyState
            } else if viewModel.visibleCards.isEmpty {
                // TODO(P01-S06): "No results" wording is ASSUMPTION (not captured)
                Text("No results")
                    .font(CCFont.row)
                    .foregroundStyle(CCColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                    .accessibilityIdentifier("cardholder.search.noResults")
                Spacer(minLength: 0)
            } else {
                cardList
            }
        }
    }

    private var cardList: some View {
        // TODO(P01-S02) / TODO(P01-S03): list layout is ASSUMPTION (not captured)
        List {
            ForEach(viewModel.visibleCards) { card in
                NavigationLink(value: card) {
                    CardHolderRow(card: card)
                }
                .accessibilityIdentifier("card.row")
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(CCColor.separator)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 92 }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        // Illustration is an SF Symbol: CamCard artwork is not copied.
        VStack(spacing: 0) {
            Image(systemName: "person.crop.rectangle.stack")
                .font(.system(size: 56))
                .foregroundStyle(CCColor.textSecondary)
                .padding(.top, 64)
            Text("No cards")
                .font(CCFont.rowEmphasis)
                .foregroundStyle(CCColor.textPrimary)
                .padding(.top, 43)
            Text("You can use the business card recognition function to upload business cards and efficiently manage your contacts")
                .font(CCFont.secondary)
                .foregroundStyle(CCColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 272)
                .padding(.top, 14)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
}
