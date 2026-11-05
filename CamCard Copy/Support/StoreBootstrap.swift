import Foundation

enum StoreBootstrap {
    @MainActor
    static func prepare(repository: CardRepository, seed: Bool) throws {
        _ = try repository.ensureGroup(named: "Ungrouped")
        guard seed else { return }
        try SeedData.seedIfEmpty(repository: repository)
    }
}
