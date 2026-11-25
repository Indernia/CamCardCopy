import Foundation
import SwiftData
import XCTest
@testable import CamCard_Copy

/// T11/T12/T18/T20 — the save mapping from Edit Card's on-screen values to a stored card.
final class CardSavingTests: XCTestCase {
    private struct Harness {
        let name: String
        let repository: CardRepository
    }

    private struct FailingRepository: CardRepository {
        struct Failure: Error {}

        func fetchAll() throws -> [CardRecord] { [] }
        func fetch(id: UUID) throws -> CardRecord? { nil }
        func create(_ record: CardRecord) throws { throw Failure() }
        func update(_ record: CardRecord) throws {}
        func delete(id: UUID) throws {}
        func fetchAllGroups() throws -> [GroupRecord] { [] }
        func ensureGroup(named name: String) throws -> GroupRecord {
            GroupRecord(id: UUID(), name: name)
        }
    }

    private let original = Data([0x0A, 0x0B, 0x0C])
    private let corrected = Data([0x0D, 0x0E])
    private let rawText = "Parsed Name\nParsed Co.\n  keep   exact\tspacing \n"

    private var savedAt: Date {
        Calendar.current.date(from: DateComponents(
            year: 2026, month: 11, day: 5, hour: 11, minute: 23
        ))!
    }

    @MainActor
    private func makeHarnesses() throws -> [Harness] {
        let schema = Schema([BusinessCard.self, Note.self, CardGroup.self])
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        return [
            Harness(name: "in-memory", repository: InMemoryCardRepository()),
            Harness(name: "swiftdata", repository: SwiftDataCardRepository(context: ModelContext(container)))
        ]
    }

    private func scanned(
        processed: Data? = nil,
        source: ScanSource = .camera
    ) -> ScannedCardImage {
        ScannedCardImage(
            originalImage: original,
            processedImage: processed,
            recognized: RecognizedCard(
                rawText: rawText,
                fields: CardFields(
                    name: "Parsed Name",
                    company: "Parsed Co.",
                    jobTitle: "Parsed Title",
                    mobile: "+1 000",
                    phone: "+1 111",
                    email: "parsed@example.com",
                    website: "parsed.example",
                    address: "1 Parsed Street"
                )
            ),
            source: source
        )
    }

    private func editedValues() -> EditedCardValues {
        EditedCardValues(
            name: "Edited Name",
            company: "Edited Co.",
            jobTitle: "Edited Title",
            mobile: "+1 222",
            phone: "+1 333",
            email: "edited@example.com",
            website: "edited.example",
            address: "2 Edited Street"
        )
    }

    @MainActor
    func testT11EditedValuesWinOverParsedValues() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)
            let saved = try saver.save(image: scanned(), values: editedValues(), savedAt: savedAt)
            let fetched = try XCTUnwrap(try harness.repository.fetch(id: saved.id), harness.name)

            XCTAssertEqual(fetched.name, "Edited Name", harness.name)
            XCTAssertEqual(fetched.company, "Edited Co.", harness.name)
            XCTAssertEqual(fetched.jobTitle, "Edited Title", harness.name)
            XCTAssertEqual(fetched.mobile, "+1 222", harness.name)
            XCTAssertEqual(fetched.phone, "+1 333", harness.name)
            XCTAssertEqual(fetched.email, "edited@example.com", harness.name)
            XCTAssertEqual(fetched.website, "edited.example", harness.name)
            XCTAssertEqual(fetched.address, "2 Edited Street", harness.name)
        }
    }

    @MainActor
    func testT12RawOCRTextAndBothImagesAreStoredUnchanged() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)
            let saved = try saver.save(
                image: scanned(processed: corrected),
                values: editedValues(),
                savedAt: savedAt
            )
            let fetched = try XCTUnwrap(try harness.repository.fetch(id: saved.id), harness.name)

            XCTAssertEqual(fetched.rawOCRText, rawText, harness.name)
            XCTAssertEqual(fetched.originalImage, original, harness.name)
            XCTAssertEqual(fetched.processedImage, corrected, harness.name)
            XCTAssertEqual(fetched.createdAt, savedAt, harness.name)
        }
    }

    @MainActor
    func testT12ProcessedImageStaysNilWhenDetectionFoundNoCard() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)
            let saved = try saver.save(image: scanned(processed: nil), values: editedValues(), savedAt: savedAt)
            let fetched = try XCTUnwrap(try harness.repository.fetch(id: saved.id), harness.name)

            XCTAssertNil(fetched.processedImage, harness.name)
            XCTAssertEqual(fetched.originalImage, original, harness.name)
        }
    }

    @MainActor
    func testT12SavingCreatesExactlyOneCardInUngroupedWithOneNote() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)
            _ = try saver.save(image: scanned(), values: editedValues(), savedAt: savedAt)

            let cards = try harness.repository.fetchAll()
            XCTAssertEqual(cards.count, 1, harness.name)
            XCTAssertEqual(cards.first?.groups.map(\.name), ["Ungrouped"], harness.name)
            XCTAssertEqual(cards.first?.notes.count, 1, harness.name)
        }
    }

    @MainActor
    func testT12UngroupedIsNeverDuplicatedBySaving() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)
            _ = try saver.save(image: scanned(), values: editedValues(), savedAt: savedAt)
            _ = try saver.save(image: scanned(), values: editedValues(), savedAt: savedAt)

            let ungrouped = try harness.repository.fetchAllGroups().filter { $0.name == "Ungrouped" }
            XCTAssertEqual(ungrouped.count, 1, harness.name)
            XCTAssertEqual(try harness.repository.fetchAll().count, 2, harness.name)
        }
    }

    @MainActor
    func testT12FirstNoteHasTheObservedTextForCameraAndAlbum() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)

            let camera = try saver.save(image: scanned(source: .camera), values: editedValues(), savedAt: savedAt)
            let album = try saver.save(image: scanned(source: .album), values: editedValues(), savedAt: savedAt)

            let cameraNote = try XCTUnwrap(try harness.repository.fetch(id: camera.id)?.notes.first, harness.name)
            let albumNote = try XCTUnwrap(try harness.repository.fetch(id: album.id)?.notes.first, harness.name)

            XCTAssertEqual(cameraNote.text, "Card Saved 2026-11-05 11:23\nFrom: Taking photo", harness.name)
            XCTAssertEqual(cameraNote.createdAt, savedAt, harness.name)
            // ASSUMPTION: the album source line is not captured.
            XCTAssertEqual(albumNote.text, "Card Saved 2026-11-05 11:23\nFrom: Importing photo", harness.name)
        }
    }

    @MainActor
    func testT20EmptyValuesAreStoredAsNilAndNoNameIsFabricated() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)
            let blank = EditedCardValues(
                name: "", company: "  ", jobTitle: "\n", mobile: "", phone: " \t ",
                email: "", website: "", address: ""
            )
            let saved = try saver.save(
                image: ScannedCardImage(originalImage: original, processedImage: nil),
                values: blank,
                savedAt: savedAt
            )
            let fetched = try XCTUnwrap(try harness.repository.fetch(id: saved.id), harness.name)

            XCTAssertNil(fetched.name, harness.name)
            XCTAssertNil(fetched.company, harness.name)
            XCTAssertNil(fetched.jobTitle, harness.name)
            XCTAssertNil(fetched.mobile, harness.name)
            XCTAssertNil(fetched.phone, harness.name)
            XCTAssertNil(fetched.email, harness.name)
            XCTAssertNil(fetched.website, harness.name)
            XCTAssertNil(fetched.address, harness.name)
            XCTAssertNil(fetched.rawOCRText, "No recognition happened, so no raw text is stored")
            XCTAssertEqual(fetched.originalImage, original, "The image is still kept")
        }
    }

    @MainActor
    func testT20TypedValuesAreStoredExactlyWithoutTrimming() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)
            let saved = try saver.save(
                image: scanned(),
                values: EditedCardValues(name: "  Padded Name "),
                savedAt: savedAt
            )
            XCTAssertEqual(
                try harness.repository.fetch(id: saved.id)?.name,
                "  Padded Name ",
                harness.name
            )
        }
    }

    @MainActor
    func testT10ExtraPhonesAndEmailsAreStoredAndBlanksDropped() throws {
        for harness in try makeHarnesses() {
            let saver = CardSaver(repository: harness.repository)
            var values = editedValues()
            values.extraPhones = ["+1 444", "  ", "+1 555"]
            values.extraEmails = ["second@example.com", ""]

            let saved = try saver.save(image: scanned(), values: values, savedAt: savedAt)
            let fetched = try XCTUnwrap(try harness.repository.fetch(id: saved.id), harness.name)

            XCTAssertEqual(fetched.extraPhones, ["+1 444", "+1 555"], harness.name)
            XCTAssertEqual(fetched.extraEmails, ["second@example.com"], harness.name)
        }
    }

    @MainActor
    func testT20FailedSaveThrowsAndReturnsNoCard() {
        let saver = CardSaver(repository: FailingRepository())
        XCTAssertThrowsError(
            try saver.save(image: scanned(), values: editedValues(), savedAt: savedAt)
        )
    }
}
