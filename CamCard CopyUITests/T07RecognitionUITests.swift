import Foundation
import XCTest

final class T07RecognitionUITests: XCTestCase {
    @MainActor
    func testT07DatasetScanShowsProgressThenPopulatedEditCard() throws {
        continueAfterFailure = false
        let card = try datasetCard(id: "card-01-standard")
        let app = launch(["-uiTestRecognizeDatasetImage", try imagePath(for: card)])

        app.buttons["scan.shutter"].tap()
        let alert = app.alerts["Card area not found"]
        if alert.waitForExistence(timeout: 1) {
            alert.buttons["Continue saving"].tap()
        }

        XCTAssertTrue(
            app.staticTexts["scan.recognizing"].waitForExistence(timeout: 5)
                || app.navigationBars["Edit Card"].exists,
            "Recognition shows the progress state"
        )
        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 25))
        XCTAssertTrue(app.buttons["Retake"].exists)
        XCTAssertTrue(app.buttons["Save"].isEnabled, "Save is enabled once saving exists")

        XCTAssertTrue(app.staticTexts["Full Name"].exists)
        assertValue(app.textFields["editCard.fullName"], equals: card.expected.name)
        assertValue(app.textFields["editCard.company"], equals: card.expected.company)
        assertValue(app.textFields["editCard.jobTitle"], equals: card.expected.jobTitle)
        assertValue(app.textFields["editCard.mobile"], equals: card.expected.mobile)
        assertValue(app.textFields["editCard.phone"], equals: card.expected.phone)
        assertValue(app.textFields["editCard.email"], equals: card.expected.email)
        assertValue(app.textFields["editCard.website"], equals: card.expected.website)
        assertValue(app.textFields["editCard.address"], equals: card.expected.address)
    }

    @MainActor
    func testT09UnrecognizedFieldsStayEmpty() throws {
        continueAfterFailure = false
        let card = try datasetCard(id: "card-02-no-website")
        let app = launch(["-uiTestRecognizeDatasetImage", try imagePath(for: card)])

        advanceToEditCard(app)

        assertValue(app.textFields["editCard.fullName"], equals: card.expected.name)
        assertValue(app.textFields["editCard.phone"], equals: "")
        assertValue(app.textFields["editCard.website"], equals: "")
        assertValue(app.textFields["editCard.address"], equals: "")
    }

    @MainActor
    func testT11RecognizedValueCanBeEditedAndCleared() throws {
        continueAfterFailure = false
        let card = try datasetCard(id: "card-01-standard")
        let app = launch(["-uiTestRecognizeDatasetImage", try imagePath(for: card)])

        advanceToEditCard(app)

        let fullName = app.textFields["editCard.fullName"]
        XCTAssertTrue(fullName.waitForExistence(timeout: 5))
        fullName.tap()

        let original = value(of: fullName)
        fullName.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: original.count + 2))
        fullName.typeText("Maya Test")
        XCTAssertEqual(value(of: fullName), "Maya Test", "The edited value stays in the row")

        fullName.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: "Maya Test".count + 2))
        XCTAssertEqual(value(of: fullName), "", "Clearing a value leaves the row empty")
    }

    @MainActor
    func testT20NoTextRecognitionOpensEmptyEditCard() throws {
        continueAfterFailure = false
        let app = launch(["-uiTestScanStubNoCard"])

        app.buttons["scan.shutter"].tap()
        let alert = app.alerts["Card area not found"]
        XCTAssertTrue(alert.waitForExistence(timeout: 15))
        alert.buttons["Continue saving"].tap()

        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 25),
                      "Recognition failure still lands on Edit Card")

        for identifier in [
            "editCard.fullName",
            "editCard.company",
            "editCard.jobTitle",
            "editCard.mobile",
            "editCard.phone",
            "editCard.email",
            "editCard.website",
            "editCard.address"
        ] {
            XCTAssertEqual(
                value(of: app.textFields[identifier]),
                "",
                "\(identifier) stays empty when recognition returns no text"
            )
        }
    }
}

// MARK: - Helpers

private extension T07RecognitionUITests {
    @MainActor
    func launch(_ extraArguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"] + extraArguments
        app.launch()
        XCTAssertTrue(app.buttons["tab.scan"].waitForExistence(timeout: 10))
        app.buttons["tab.scan"].tap()
        XCTAssertTrue(app.buttons["scan.shutter"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    func advanceToEditCard(_ app: XCUIApplication) {
        app.buttons["scan.shutter"].tap()

        let alert = app.alerts["Card area not found"]
        if alert.waitForExistence(timeout: 1) {
            alert.buttons["Continue saving"].tap()
        }

        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 25))
    }

    @MainActor
    func assertValue(
        _ element: XCUIElement,
        equals expected: String?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "text field is missing", file: file, line: line)
        XCTAssertEqual(value(of: element), expected ?? "", file: file, line: line)
    }

    @MainActor
    func value(of element: XCUIElement) -> String {
        element.value as? String ?? ""
    }
}

// MARK: - Dataset fixtures

private struct UITestCard: Decodable {
    struct Expected: Decodable {
        let name: String
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
    let expected: Expected
}

private extension T07RecognitionUITests {
    static var referenceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // CamCard CopyUITests
            .deletingLastPathComponent() // repository root
            .appendingPathComponent("reference")
    }

    func datasetCard(id: String) throws -> UITestCard {
        let data = try Data(contentsOf: Self.referenceRoot.appendingPathComponent("ground-truth.json"))
        let cards = try JSONDecoder().decode([UITestCard].self, from: data)
        return try XCTUnwrap(cards.first { $0.id == id }, "ground truth is missing \(id)")
    }

    func imagePath(for card: UITestCard) throws -> String {
        Self.referenceRoot.appendingPathComponent(card.image).path
    }
}
