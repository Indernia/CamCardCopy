import Foundation

nonisolated struct NoteRecord: Identifiable, Equatable, Hashable, Sendable {
    var id: UUID
    var text: String
    var createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = .now) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

nonisolated struct GroupRecord: Identifiable, Equatable, Hashable, Sendable {
    var id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

nonisolated struct CardRecord: Identifiable, Equatable, Hashable, Sendable {
    var id: UUID
    var originalImage: Data?
    var processedImage: Data?
    var rawOCRText: String?
    var name: String?
    var company: String?
    var jobTitle: String?
    var mobile: String?
    var phone: String?
    var email: String?
    var website: String?
    var address: String?
    var groups: [GroupRecord]
    var notes: [NoteRecord]
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
        groups: [GroupRecord] = [],
        notes: [NoteRecord] = [],
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
