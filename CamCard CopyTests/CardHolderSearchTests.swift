import XCTest
@testable import CamCard_Copy

final class CardHolderSearchTests: XCTestCase {
    private let cards = [
        CardRecord(name: "Avery Chen", company: "Northwind Labs"),
        CardRecord(name: "Blair Ortiz", company: "Contoso"),
        CardRecord(name: "Casey Lund", company: "Fabrikam")
    ]

    private func names(_ query: String) -> [String] {
        CardHolderSearch.filter(cards, query: query).compactMap(\.name)
    }

    func testMatchesName() {
        XCTAssertEqual(names("ortiz"), ["Blair Ortiz"])
    }

    func testMatchesCompanyIgnoringCase() {
        XCTAssertEqual(names("FABRI"), ["Casey Lund"])
    }

    func testTrimsSurroundingWhitespace() {
        XCTAssertEqual(names("  ortiz "), ["Blair Ortiz"])
    }

    func testEmptyAndWhitespaceOnlyReturnEverything() {
        XCTAssertEqual(names(""), ["Avery Chen", "Blair Ortiz", "Casey Lund"])
        XCTAssertEqual(names("   "), ["Avery Chen", "Blair Ortiz", "Casey Lund"])
    }

    func testNoMatchReturnsNothing() {
        XCTAssertTrue(names("zzqx").isEmpty)
    }

    func testOrderIsPreserved() {
        XCTAssertEqual(names("a"), ["Avery Chen", "Blair Ortiz", "Casey Lund"])
    }

    func testDoesNotReadRawOCRText() {
        let card = CardRecord(rawOCRText: "secret", name: "Dana", company: nil)
        XCTAssertTrue(CardHolderSearch.filter([card], query: "secret").isEmpty)
    }

    func testDisplayImagePrefersProcessedThenOriginalThenNil() {
        let original = Data([1])
        let processed = Data([2])
        XCTAssertEqual(cardDisplayImageData(CardRecord(originalImage: original, processedImage: processed)), processed)
        XCTAssertEqual(cardDisplayImageData(CardRecord(originalImage: original)), original)
        XCTAssertNil(cardDisplayImageData(CardRecord()))
    }
}
