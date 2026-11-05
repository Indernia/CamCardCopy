import Foundation

enum SeedData {
    @MainActor
    static func seedIfEmpty(repository: CardRepository) throws {
        guard try repository.fetchAll().isEmpty else { return }

        let vip = try repository.ensureGroup(named: "VIP")
        let customer = try repository.ensureGroup(named: "Customer")
        _ = try repository.ensureGroup(named: "Supplier")
        let partner = try repository.ensureGroup(named: "Partner")
        _ = try repository.ensureGroup(named: "Industry Peer")

        let note = NoteRecord(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            text: "Met at the iOS conference.",
            createdAt: Date(timeIntervalSinceReferenceDate: 1_000_100)
        )

        try repository.create(
            CardRecord(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                name: "Avery Chen",
                company: "Northwind Labs",
                jobTitle: "Product Designer",
                email: "avery.chen@northwind.example",
                groups: [vip],
                notes: [note],
                createdAt: Date(timeIntervalSinceReferenceDate: 1_000_000)
            )
        )

        try repository.create(
            CardRecord(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                name: "Blair Ortiz",
                company: "Contoso",
                jobTitle: "Sales Director",
                email: "blair.ortiz@contoso.example",
                groups: [customer],
                createdAt: Date(timeIntervalSinceReferenceDate: 999_000)
            )
        )

        try repository.create(
            CardRecord(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                name: "Casey Lund",
                company: "Fabrikam",
                jobTitle: "Engineering Manager",
                email: "casey.lund@fabrikam.example",
                groups: [partner],
                createdAt: Date(timeIntervalSinceReferenceDate: 998_000)
            )
        )
    }
}
