import Foundation
import Observation

@MainActor
@Observable
final class CardHolderViewModel {
    private let repository: CardRepository
    private(set) var cards: [CardRecord] = []
    private(set) var errorMessage: String?
    var query = ""
    var isSearching = false

    init(repository: CardRepository) {
        self.repository = repository
    }

    var visibleCards: [CardRecord] {
        CardHolderSearch.filter(cards, query: query)
    }

    func load() {
        do {
            cards = try repository.fetchAll()
            errorMessage = nil
        } catch {
            cards = []
            errorMessage = String(describing: error)
        }
    }

    func cancelSearch() {
        query = ""
        isSearching = false
    }
}
