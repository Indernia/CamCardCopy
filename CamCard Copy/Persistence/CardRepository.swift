import Foundation

enum CardRepositoryError: Error, Equatable {
    case cardNotFound(UUID)
    case duplicateIdentifier(UUID)
    case groupNotFound(UUID)
}

@MainActor
protocol CardRepository {
    func fetchAll() throws -> [CardRecord]
    func fetch(id: UUID) throws -> CardRecord?
    func create(_ record: CardRecord) throws
    func update(_ record: CardRecord) throws
    func delete(id: UUID) throws
    func fetchAllGroups() throws -> [GroupRecord]
    func ensureGroup(named name: String) throws -> GroupRecord
}
