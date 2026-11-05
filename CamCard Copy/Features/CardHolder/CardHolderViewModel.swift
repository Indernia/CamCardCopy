import Foundation
import Observation

@MainActor
@Observable
final class CardHolderViewModel {
    private let repository: CardRepository
    private(set) var cards: [CardRecord] = []
    private(set) var errorMessage: String?

    init(repository: CardRepository) {
        self.repository = repository
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
}
