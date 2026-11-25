import Foundation

/// Decodes `reference/ground-truth.json` and loads its images without copying
/// them into the test bundle.
struct GroundTruthCard: Decodable {
    struct Expected: Decodable {
        let name: String?
        let company: String?
        let jobTitle: String?
        let mobile: String?
        let phone: String?
        let email: String?
        let website: String?
        let address: String?
    }

    let id: String
    let image: String
    let photo: String
    let tests: [String]
    let purpose: String
    let expected: Expected
    let fax: String?
    let emails: [String]?
    let note: String?
}

enum DatasetFixtures {
    static var referenceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // CamCard CopyTests
            .deletingLastPathComponent() // repository root
            .appendingPathComponent("reference")
    }

    static func groundTruth() throws -> [GroundTruthCard] {
        let data = try Data(contentsOf: referenceRoot.appendingPathComponent("ground-truth.json"))
        return try JSONDecoder().decode([GroundTruthCard].self, from: data)
    }

    static func imageData(for relativePath: String) throws -> Data {
        try Data(contentsOf: referenceRoot.appendingPathComponent(relativePath))
    }
}
