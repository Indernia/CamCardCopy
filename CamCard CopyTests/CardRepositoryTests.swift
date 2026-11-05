import SwiftData
import XCTest
@testable import CamCard_Copy

final class CardRepositoryTests: XCTestCase {
    private struct Harness {
        let name: String
        let repository: CardRepository
        let context: ModelContext?
        let container: ModelContainer?
    }

    @MainActor
    private func makeHarnesses() throws -> [Harness] {
        let schema = Schema([BusinessCard.self, Note.self, CardGroup.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)

        return [
            Harness(
                name: "in-memory",
                repository: InMemoryCardRepository(),
                context: nil,
                container: nil
            ),
            Harness(
                name: "swiftdata",
                repository: SwiftDataCardRepository(context: context),
                context: context,
                container: container
            )
        ]
    }

    private func makeCard(
        id: UUID = UUID(),
        name: String? = "Avery Chen",
        company: String? = "Northwind Labs",
        website: String? = "https://northwind.example",
        address: String? = "1 Main Street",
        groups: [GroupRecord] = [],
        notes: [NoteRecord] = [],
        createdAt: Date = Date(timeIntervalSince1970: 1_000)
    ) -> CardRecord {
        CardRecord(
            id: id,
            originalImage: Data([0x01, 0x02, 0x03]),
            processedImage: Data([0x04, 0x05]),
            rawOCRText: "Avery Chen\nNorthwind Labs",
            name: name,
            company: company,
            jobTitle: "Engineer",
            mobile: "+1 555 0100",
            phone: "+1 555 0101",
            email: "avery.chen@northwind.example",
            website: website,
            address: address,
            groups: groups,
            notes: notes,
            createdAt: createdAt
        )
    }

    @MainActor
    func testT18U1CreateStoresEveryField() throws {
        for harness in try makeHarnesses() {
            let vip = try harness.repository.ensureGroup(named: "VIP")
            let partner = try harness.repository.ensureGroup(named: "Partner")
            let record = makeCard(groups: [partner, vip])

            try harness.repository.create(record)
            let fetched = try XCTUnwrap(try harness.repository.fetch(id: record.id), harness.name)

            XCTAssertEqual(fetched.id, record.id, harness.name)
            XCTAssertEqual(fetched.originalImage, record.originalImage, harness.name)
            XCTAssertEqual(fetched.processedImage, record.processedImage, harness.name)
            XCTAssertEqual(fetched.rawOCRText, record.rawOCRText, harness.name)
            XCTAssertEqual(fetched.name, record.name, harness.name)
            XCTAssertEqual(fetched.company, record.company, harness.name)
            XCTAssertEqual(fetched.jobTitle, record.jobTitle, harness.name)
            XCTAssertEqual(fetched.mobile, record.mobile, harness.name)
            XCTAssertEqual(fetched.phone, record.phone, harness.name)
            XCTAssertEqual(fetched.email, record.email, harness.name)
            XCTAssertEqual(fetched.website, record.website, harness.name)
            XCTAssertEqual(fetched.address, record.address, harness.name)
            XCTAssertEqual(fetched.groups.map(\.name), ["Partner", "VIP"], harness.name)
            XCTAssertEqual(fetched.createdAt, record.createdAt, harness.name)
            XCTAssertEqual(try harness.repository.fetchAll().count, 1, harness.name)
        }
    }

    @MainActor
    func testT18U1AbsentFieldsStayNil() throws {
        for harness in try makeHarnesses() {
            let record = makeCard(website: nil, address: nil)

            try harness.repository.create(record)
            let fetched = try XCTUnwrap(try harness.repository.fetch(id: record.id), harness.name)

            XCTAssertNil(fetched.website, harness.name)
            XCTAssertNil(fetched.address, harness.name)
        }
    }

    @MainActor
    func testT18U2NotesRoundTripOldestFirst() throws {
        for harness in try makeHarnesses() {
            let older = NoteRecord(
                id: UUID(),
                text: "Older note",
                createdAt: Date(timeIntervalSince1970: 2_000)
            )
            let newer = NoteRecord(
                id: UUID(),
                text: "Newer note",
                createdAt: Date(timeIntervalSince1970: 3_000)
            )
            let record = makeCard(notes: [newer, older])

            try harness.repository.create(record)
            let fetched = try XCTUnwrap(try harness.repository.fetch(id: record.id), harness.name)

            XCTAssertEqual(fetched.notes.map(\.text), ["Older note", "Newer note"], harness.name)
            XCTAssertEqual(fetched.notes.map(\.id), [older.id, newer.id], harness.name)
            XCTAssertEqual(fetched.notes.map(\.createdAt), [older.createdAt, newer.createdAt], harness.name)
        }
    }

    @MainActor
    func testT18U2UnknownIdentifierReturnsNil() throws {
        for harness in try makeHarnesses() {
            XCTAssertNil(try harness.repository.fetch(id: UUID()), harness.name)
        }
    }

    @MainActor
    func testT18U3UpdatePersists() throws {
        for harness in try makeHarnesses() {
            let record = makeCard()
            try harness.repository.create(record)

            var updated = try XCTUnwrap(try harness.repository.fetch(id: record.id), harness.name)
            updated.name = "Avery Chen Updated"
            updated.company = "Contoso"
            updated.website = nil
            try harness.repository.update(updated)

            let fetched = try XCTUnwrap(try harness.repository.fetch(id: record.id), harness.name)
            XCTAssertEqual(fetched.name, "Avery Chen Updated", harness.name)
            XCTAssertEqual(fetched.company, "Contoso", harness.name)
            XCTAssertNil(fetched.website, harness.name)
        }
    }

    @MainActor
    func testT18U4DeleteRemovesCardAndNotes() throws {
        for harness in try makeHarnesses() {
            let note = NoteRecord(
                id: UUID(),
                text: "Follow up next week",
                createdAt: Date(timeIntervalSince1970: 2_000)
            )
            let record = makeCard(notes: [note])
            try harness.repository.create(record)

            try harness.repository.delete(id: record.id)

            XCTAssertNil(try harness.repository.fetch(id: record.id), harness.name)
            XCTAssertTrue(try harness.repository.fetchAll().isEmpty, harness.name)
            if let context = harness.context {
                XCTAssertEqual(try context.fetch(FetchDescriptor<Note>()).count, 0, harness.name)
            }
        }
    }

    @MainActor
    func testT18U5CardGroupsRoundTripAndSurviveCardDeletion() throws {
        for harness in try makeHarnesses() {
            let vip = try harness.repository.ensureGroup(named: "VIP")
            let customer = try harness.repository.ensureGroup(named: "Customer")
            let record = makeCard(groups: [vip])
            try harness.repository.create(record)

            let fetched = try XCTUnwrap(try harness.repository.fetch(id: record.id), harness.name)
            XCTAssertEqual(fetched.groups.map(\.id), [vip.id], harness.name)
            XCTAssertEqual(fetched.groups.map(\.name), ["VIP"], harness.name)

            try harness.repository.delete(id: record.id)

            let remainingGroups = try harness.repository.fetchAllGroups()
            XCTAssertTrue(remainingGroups.contains { $0.id == vip.id }, harness.name)
            XCTAssertTrue(remainingGroups.contains { $0.id == customer.id }, harness.name)
            XCTAssertEqual(remainingGroups.map(\.name), ["Customer", "VIP"], harness.name)
        }
    }

    @MainActor
    func testT16UngroupedExistsOnceAfterRepeatedBootstrap() throws {
        for harness in try makeHarnesses() {
            try StoreBootstrap.prepare(repository: harness.repository, seed: false)
            try StoreBootstrap.prepare(repository: harness.repository, seed: false)

            let ungrouped = try harness.repository.fetchAllGroups().filter { $0.name == "Ungrouped" }
            XCTAssertEqual(ungrouped.count, 1, harness.name)
        }
    }

    @MainActor
    func testT18SeedIsIdempotent() throws {
        for harness in try makeHarnesses() {
            try StoreBootstrap.prepare(repository: harness.repository, seed: true)
            try StoreBootstrap.prepare(repository: harness.repository, seed: true)

            XCTAssertEqual(try harness.repository.fetchAll().count, 3, harness.name)
            XCTAssertEqual(try harness.repository.fetchAllGroups().count, 6, harness.name)
            XCTAssertEqual(
                Set(try harness.repository.fetchAllGroups().map(\.name)),
                Set(["Ungrouped", "VIP", "Customer", "Supplier", "Partner", "Industry Peer"]),
                harness.name
            )
        }
    }

    @MainActor
    func testT01ResetStoreRemovesStoreSidecarsAndSupportDirectory() throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let storeURL = directory.appending(path: "CamCard.store")
        try Data().write(to: storeURL)
        try Data().write(to: URL(fileURLWithPath: storeURL.path + "-shm"))
        try Data().write(to: URL(fileURLWithPath: storeURL.path + "-wal"))

        let supportDirectory = directory.appending(path: ".CamCard_SUPPORT", directoryHint: .isDirectory)
        let externalData = supportDirectory.appending(path: "_EXTERNAL_DATA", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: externalData, withIntermediateDirectories: true)
        try Data([0x01]).write(to: externalData.appending(path: "image"))

        try ModelContainerFactory.resetStore(at: storeURL)

        XCTAssertFalse(FileManager.default.fileExists(atPath: storeURL.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: storeURL.path + "-shm"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: storeURL.path + "-wal"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: supportDirectory.path))
    }
}
