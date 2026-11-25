import Foundation
import SwiftData

@MainActor
final class SwiftDataCardRepository: CardRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [CardRecord] {
        let descriptor = FetchDescriptor<BusinessCard>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map(record(from:))
    }

    func fetch(id: UUID) throws -> CardRecord? {
        try fetchModel(id: id).map(record(from:))
    }

    func create(_ record: CardRecord) throws {
        guard try fetchModel(id: record.id) == nil else {
            throw CardRepositoryError.duplicateIdentifier(record.id)
        }

        let card = BusinessCard(id: record.id, createdAt: record.createdAt)
        apply(record, to: card)
        card.groups = try resolveGroups(record.groups)
        card.notes = record.notes.map { noteRecord in
            Note(id: noteRecord.id, text: noteRecord.text, createdAt: noteRecord.createdAt)
        }
        context.insert(card)
        card.notes.forEach { $0.card = card }
        try context.save()
    }

    func update(_ record: CardRecord) throws {
        guard let card = try fetchModel(id: record.id) else {
            throw CardRepositoryError.cardNotFound(record.id)
        }

        apply(record, to: card)
        card.groups = try resolveGroups(record.groups)

        for note in card.notes {
            context.delete(note)
        }
        card.notes = []
        try context.save()

        card.notes = record.notes.map { noteRecord in
            Note(id: noteRecord.id, text: noteRecord.text, createdAt: noteRecord.createdAt)
        }
        card.notes.forEach { $0.card = card }
        try context.save()
    }

    func delete(id: UUID) throws {
        guard let card = try fetchModel(id: id) else {
            throw CardRepositoryError.cardNotFound(id)
        }
        context.delete(card)
        try context.save()
    }

    func fetchAllGroups() throws -> [GroupRecord] {
        let descriptor = FetchDescriptor<CardGroup>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return try context.fetch(descriptor).map {
            GroupRecord(id: $0.id, name: $0.name)
        }
    }

    func ensureGroup(named name: String) throws -> GroupRecord {
        let descriptor = FetchDescriptor<CardGroup>(
            predicate: #Predicate { $0.name == name }
        )
        if let existing = try context.fetch(descriptor).first {
            return GroupRecord(id: existing.id, name: existing.name)
        }
        let group = CardGroup(name: name)
        context.insert(group)
        try context.save()
        return GroupRecord(id: group.id, name: group.name)
    }

    private func fetchModel(id: UUID) throws -> BusinessCard? {
        var descriptor = FetchDescriptor<BusinessCard>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func resolveGroups(_ records: [GroupRecord]) throws -> [CardGroup] {
        try records.map { groupRecord in
            let groupID = groupRecord.id
            let descriptor = FetchDescriptor<CardGroup>(
                predicate: #Predicate { $0.id == groupID }
            )
            guard let group = try context.fetch(descriptor).first else {
                throw CardRepositoryError.groupNotFound(groupRecord.id)
            }
            return group
        }
    }

    private func apply(_ record: CardRecord, to card: BusinessCard) {
        card.originalImage = record.originalImage
        card.processedImage = record.processedImage
        card.rawOCRText = record.rawOCRText
        card.name = record.name
        card.company = record.company
        card.jobTitle = record.jobTitle
        card.mobile = record.mobile
        card.phone = record.phone
        card.email = record.email
        card.website = record.website
        card.address = record.address
        card.extraPhones = record.extraPhones
        card.extraEmails = record.extraEmails
        card.createdAt = record.createdAt
    }

    private func record(from card: BusinessCard) -> CardRecord {
        CardRecord(
            id: card.id,
            originalImage: card.originalImage,
            processedImage: card.processedImage,
            rawOCRText: card.rawOCRText,
            name: card.name,
            company: card.company,
            jobTitle: card.jobTitle,
            mobile: card.mobile,
            phone: card.phone,
            email: card.email,
            website: card.website,
            address: card.address,
            extraPhones: card.extraPhones,
            extraEmails: card.extraEmails,
            groups: card.groups
                .map { GroupRecord(id: $0.id, name: $0.name) }
                .sorted { $0.name < $1.name },
            notes: card.notes
                .map { NoteRecord(id: $0.id, text: $0.text, createdAt: $0.createdAt) }
                .sorted { $0.createdAt < $1.createdAt },
            createdAt: card.createdAt
        )
    }
}
