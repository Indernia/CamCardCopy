import Foundation

/// The values as currently edited on Edit Card. Empty means "not provided".
nonisolated struct EditedCardValues: Equatable, Sendable {
    var name: String = ""
    var company: String = ""
    var jobTitle: String = ""
    var mobile: String = ""
    var phone: String = ""
    var email: String = ""
    var website: String = ""
    var address: String = ""
    var extraPhones: [String] = []
    var extraEmails: [String] = []
}

/// Maps Edit Card's on-screen values onto a stored card. Never reads the
/// original parse for stored values, and never fabricates one.
@MainActor
struct CardSaver {
    let repository: CardRepository

    func save(
        image: ScannedCardImage,
        values: EditedCardValues,
        savedAt: Date = .now
    ) throws -> CardRecord {
        let group = try repository.ensureGroup(named: "Ungrouped")
        let note = NoteRecord(
            text: Self.noteText(savedAt: savedAt, source: image.source),
            createdAt: savedAt
        )

        let record = CardRecord(
            originalImage: image.originalImage,
            processedImage: image.processedImage,
            rawOCRText: image.recognized?.rawText,
            name: Self.text(values.name),
            company: Self.text(values.company),
            jobTitle: Self.text(values.jobTitle),
            mobile: Self.text(values.mobile),
            phone: Self.text(values.phone),
            email: Self.text(values.email),
            website: Self.text(values.website),
            address: Self.text(values.address),
            extraPhones: values.extraPhones.filter { !Self.isBlank($0) },
            extraEmails: values.extraEmails.filter { !Self.isBlank($0) },
            groups: [group],
            notes: [note],
            createdAt: savedAt
        )

        try repository.create(record)
        return record
    }

    /// "Card Saved <yyyy-MM-dd HH:mm>" followed by the observed source line.
    nonisolated static func noteText(savedAt: Date, source: ScanSource) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return "Card Saved \(formatter.string(from: savedAt))\nFrom: \(source.notePhrase)"
    }

    nonisolated static func text(_ value: String) -> String? {
        isBlank(value) ? nil : value
    }

    nonisolated private static func isBlank(_ value: String) -> Bool {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
