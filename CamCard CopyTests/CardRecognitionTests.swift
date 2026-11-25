import Foundation
import XCTest

@testable import CamCard_Copy

final class CardRecognitionTests: XCTestCase {
    func testT07ScanProducesRawTextWithTheExpectedName() async throws {
        let cards = try DatasetFixtures.groundTruth()
        let card = try XCTUnwrap(cards.first)
        let data = try DatasetFixtures.imageData(for: card.image)

        let rawText = try await VisionTextRecognizer().recognizeText(in: data)

        XCTAssertFalse(rawText.isEmpty, "the real recognizer returned no text")
        let expectedName = try XCTUnwrap(card.expected.name)
        XCTAssertTrue(rawText.contains(expectedName), "raw text was:\n\(rawText)")
    }

    func testT07ToT10DatasetAccuracyScansAssertEveryFieldAndPhotosAssertEssentials() async throws {
        let recognizer = VisionTextRecognizer()
        let parser = CardFieldParser()
        let cards = try DatasetFixtures.groundTruth()

        for card in cards {
            let scanRawText = try await recognizer.recognizeText(
                in: try DatasetFixtures.imageData(for: card.image)
            )
            let scanCopy = scanRawText
            let scanFields = parser.parse(scanRawText)
            XCTAssertEqual(scanRawText, scanCopy, "\(card.id) scan: parsing must not mutate raw text")
            report(card: card, kind: "scan", fields: scanFields)
            assertEveryScanField(card: card, fields: scanFields, rawText: scanRawText)

            let photoRawText = try await recognizer.recognizeText(
                in: try DatasetFixtures.imageData(for: card.photo)
            )
            let photoCopy = photoRawText
            let photoFields = parser.parse(photoRawText)
            XCTAssertEqual(photoRawText, photoCopy, "\(card.id) photo: parsing must not mutate raw text")
            report(card: card, kind: "photo", fields: photoFields)
            assertPhotoEssentials(card: card, fields: photoFields, rawText: photoRawText)
        }
    }
}

// MARK: - Assertions

private extension CardRecognitionTests {
    func assertEveryScanField(card: GroundTruthCard, fields: CardFields, rawText: String) {
        XCTAssertFalse(rawText.isEmpty, "\(card.id) scan: no raw text")
        XCTAssertEqual(normalized(fields.name), normalized(card.expected.name), "\(card.id) scan name")
        XCTAssertEqual(normalized(fields.company), normalized(card.expected.company), "\(card.id) scan company")
        XCTAssertEqual(normalized(fields.jobTitle), normalized(card.expected.jobTitle), "\(card.id) scan job title")
        XCTAssertEqual(normalized(fields.mobile), normalized(card.expected.mobile), "\(card.id) scan mobile")
        XCTAssertEqual(normalized(fields.phone), normalized(card.expected.phone), "\(card.id) scan phone")
        XCTAssertEqual(
            normalizedCaseInsensitive(fields.email),
            normalizedCaseInsensitive(card.expected.email),
            "\(card.id) scan email"
        )
        XCTAssertEqual(
            normalizedCaseInsensitive(fields.website),
            normalizedCaseInsensitive(card.expected.website),
            "\(card.id) scan website"
        )
        XCTAssertEqual(normalized(fields.address), normalized(card.expected.address), "\(card.id) scan address")
    }

    func assertPhotoEssentials(card: GroundTruthCard, fields: CardFields, rawText: String) {
        XCTAssertFalse(rawText.isEmpty, "\(card.id) photo: no raw text")
        XCTAssertEqual(normalized(fields.name), normalized(card.expected.name), "\(card.id) photo name")
        XCTAssertEqual(
            normalizedCaseInsensitive(fields.email),
            normalizedCaseInsensitive(card.expected.email),
            "\(card.id) photo email"
        )

        // Primary phone: the label decision is mobile when present, otherwise phone.
        let expectedPrimary = normalized(card.expected.mobile ?? card.expected.phone)
        let actualPrimary = normalized(fields.mobile ?? fields.phone)
        XCTAssertEqual(actualPrimary, expectedPrimary, "\(card.id) photo primary phone")
    }

    func report(card: GroundTruthCard, kind: String, fields: CardFields) {
        let pairs: [(String, String?, String?)] = [
            ("name", card.expected.name, fields.name),
            ("company", card.expected.company, fields.company),
            ("jobTitle", card.expected.jobTitle, fields.jobTitle),
            ("mobile", card.expected.mobile, fields.mobile),
            ("phone", card.expected.phone, fields.phone),
            ("email", card.expected.email, fields.email),
            ("website", card.expected.website, fields.website),
            ("address", card.expected.address, fields.address)
        ]

        for (field, expected, actual) in pairs {
            let matches: Bool
            if field == "email" || field == "website" {
                matches = normalizedCaseInsensitive(expected) == normalizedCaseInsensitive(actual)
            } else {
                matches = normalized(expected) == normalized(actual)
            }
            print("[\(kind)] \(card.id) \(field): expected=\(expected ?? "nil") actual=\(actual ?? "nil") \(matches ? "MATCH" : "MISMATCH")")
        }
        if !fields.extraEmails.isEmpty {
            print("[\(kind)] \(card.id) extraEmails: \(fields.extraEmails)")
        }
        if !fields.extraPhones.isEmpty {
            print("[\(kind)] \(card.id) extraPhones: \(fields.extraPhones)")
        }
    }

    func normalized(_ value: String?) -> String? {
        guard let value else { return nil }
        return value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }

    func normalizedCaseInsensitive(_ value: String?) -> String? {
        normalized(value)?.lowercased()
    }
}
