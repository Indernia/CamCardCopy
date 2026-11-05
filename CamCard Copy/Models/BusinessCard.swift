import Foundation
import SwiftData

@Model
final class BusinessCard {
    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage) var originalImage: Data?
    @Attribute(.externalStorage) var processedImage: Data?
    var rawOCRText: String?
    var name: String?
    var company: String?
    var jobTitle: String?
    var mobile: String?
    var phone: String?
    var email: String?
    var website: String?
    var address: String?
    @Relationship(deleteRule: .nullify, inverse: \CardGroup.cards) var groups: [CardGroup]
    @Relationship(deleteRule: .cascade, inverse: \Note.card) var notes: [Note]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        originalImage: Data? = nil,
        processedImage: Data? = nil,
        rawOCRText: String? = nil,
        name: String? = nil,
        company: String? = nil,
        jobTitle: String? = nil,
        mobile: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        website: String? = nil,
        address: String? = nil,
        groups: [CardGroup] = [],
        notes: [Note] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.originalImage = originalImage
        self.processedImage = processedImage
        self.rawOCRText = rawOCRText
        self.name = name
        self.company = company
        self.jobTitle = jobTitle
        self.mobile = mobile
        self.phone = phone
        self.email = email
        self.website = website
        self.address = address
        self.groups = groups
        self.notes = notes
        self.createdAt = createdAt
    }
}

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var text: String
    var createdAt: Date
    var card: BusinessCard?

    init(id: UUID = UUID(), text: String, createdAt: Date = .now) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}
