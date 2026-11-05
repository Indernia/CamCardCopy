import Foundation

@MainActor
final class InMemoryCardRepository: CardRepository {
    private var cards: [UUID: CardRecord] = [:]
    private var groups: [UUID: GroupRecord] = [:]

    func fetchAll() throws -> [CardRecord] {
        cards.values.sorted { $0.createdAt > $1.createdAt }
    }

    func fetch(id: UUID) throws -> CardRecord? {
        cards[id]
    }

    func create(_ record: CardRecord) throws {
        guard cards[record.id] == nil else {
            throw CardRepositoryError.duplicateIdentifier(record.id)
        }
        cards[record.id] = try normalized(record)
    }

    func update(_ record: CardRecord) throws {
        guard cards[record.id] != nil else {
            throw CardRepositoryError.cardNotFound(record.id)
        }
        cards[record.id] = try normalized(record)
    }

    func delete(id: UUID) throws {
        guard cards.removeValue(forKey: id) != nil else {
            throw CardRepositoryError.cardNotFound(id)
        }
    }

    func fetchAllGroups() throws -> [GroupRecord] {
        groups.values.sorted { $0.name < $1.name }
    }

    func ensureGroup(named name: String) throws -> GroupRecord {
        if let existing = groups.values.first(where: { $0.name == name }) {
            return existing
        }
        let group = GroupRecord(id: UUID(), name: name)
        groups[group.id] = group
        return group
    }

    private func normalized(_ record: CardRecord) throws -> CardRecord {
        var normalized = record
        normalized.groups = try record.groups.map { groupRecord in
            guard let stored = groups[groupRecord.id] else {
                throw CardRepositoryError.groupNotFound(groupRecord.id)
            }
            return stored
        }
        .sorted { $0.name < $1.name }
        normalized.notes = record.notes.sorted { $0.createdAt < $1.createdAt }
        return normalized
    }
}
