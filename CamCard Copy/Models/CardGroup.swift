import Foundation
import SwiftData

@Model
final class CardGroup {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    var cards: [BusinessCard]

    init(id: UUID = UUID(), name: String, cards: [BusinessCard] = []) {
        self.id = id
        self.name = name
        self.cards = cards
    }
}
