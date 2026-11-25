import Foundation
import XCTest

/// T11/T12/T13/T18 — Save on Edit Card, the Card Saved screen, and the saved card in CardHolder.
final class T12SaveCardUITests: XCTestCase {
    private let editedName = "Maya Test"

    @MainActor
    func testT12SaveShowsCardSavedThenCardHolderAndDetail() throws {
        continueAfterFailure = false
        let card = try datasetCard(id: "card-01-standard")
        let app = launch(emptyStore: true, datasetImage: try imagePath(for: card))

        saveEditedCard(in: app)

        // Card Saved (P06-S01): exact observed text, thumbnail, inert actions.
        XCTAssertTrue(app.staticTexts["Card Saved"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["cardSaved.done"].exists)
        XCTAssertTrue(app.images["cardSaved.thumbnail"].exists || app.otherElements["cardSaved.thumbnail"].exists)
        for identifier in ["cardSaved.group", "cardSaved.note", "cardSaved.sync", "cardSaved.export"] {
            let action = app.buttons[identifier]
            XCTAssertTrue(action.exists, identifier)
            action.tap()
            XCTAssertTrue(app.staticTexts["Card Saved"].exists, "\(identifier) is inert and opens nothing")
            XCTAssertTrue(app.buttons["cardSaved.done"].exists, identifier)
        }
        XCTAssertTrue(app.buttons["cardSaved.takeNext"].exists)
        XCTAssertFalse(app.buttons["Contacts"].exists, "No paywall or other screen is shown")

        // Done → CardHolder with the saved card.
        app.buttons["cardSaved.done"].tap()
        XCTAssertTrue(app.navigationBars["CardHolder"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["No cards"].exists)

        let rows = app.buttons.matching(identifier: "card.row")
        XCTAssertEqual(rows.count, 1, "Exactly one card was saved")
        let row = rows.containing(.staticText, identifier: editedName).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5), "CardHolder shows the edited name")
        row.tap()

        // Card detail (T13): edited name wins, other recognized fields, group and first Note.
        XCTAssertTrue(app.staticTexts["Full Name"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[editedName].exists)
        if let company = card.expected.company {
            XCTAssertTrue(app.staticTexts[company].exists)
        }
        if let email = card.expected.email {
            XCTAssertTrue(app.staticTexts[email].exists)
        }
        XCTAssertTrue(app.staticTexts["Ungrouped"].exists)
        let note = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Card Saved '")).firstMatch
        XCTAssertTrue(note.exists, "The first Note is created on save")
        XCTAssertTrue(note.label.contains("From: Taking photo"))
    }

    @MainActor
    func testT18SavedCardSurvivesRelaunchWithoutAnyTestArguments() throws {
        continueAfterFailure = false
        let card = try datasetCard(id: "card-01-standard")
        let app = launch(emptyStore: true, datasetImage: try imagePath(for: card))

        saveEditedCard(in: app)
        XCTAssertTrue(app.buttons["cardSaved.done"].waitForExistence(timeout: 10))
        app.buttons["cardSaved.done"].tap()
        XCTAssertTrue(app.navigationBars["CardHolder"].waitForExistence(timeout: 10))
        app.terminate()

        // No -uiTestEmptyStore, no seed: this is the real store from the first launch.
        let relaunched = XCUIApplication()
        relaunched.launchArguments = []
        relaunched.launch()
        XCTAssertTrue(relaunched.buttons["tab.cardHolder"].waitForExistence(timeout: 10))
        relaunched.buttons["tab.cardHolder"].tap()
        XCTAssertTrue(relaunched.navigationBars["CardHolder"].waitForExistence(timeout: 5))

        let row = relaunched.buttons
            .matching(identifier: "card.row")
            .containing(.staticText, identifier: editedName)
            .firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10), "The saved card persists across launches")
        row.tap()
        XCTAssertTrue(relaunched.staticTexts[editedName].waitForExistence(timeout: 5))
        XCTAssertTrue(relaunched.staticTexts["Ungrouped"].exists)
    }

    @MainActor
    func testT12TakeTheNextReturnsToTheCameraWithoutSavingAnotherCard() throws {
        continueAfterFailure = false
        let card = try datasetCard(id: "card-01-standard")
        let app = launch(emptyStore: true, datasetImage: try imagePath(for: card))

        saveEditedCard(in: app)
        XCTAssertTrue(app.buttons["cardSaved.takeNext"].waitForExistence(timeout: 10))
        app.buttons["cardSaved.takeNext"].tap()

        XCTAssertTrue(app.buttons["scan.shutter"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["scan.close"].exists)
        XCTAssertTrue(app.buttons["scan.album"].exists)
        XCTAssertEqual(app.staticTexts["scan.mode.single"].value as? String, "Selected")
        XCTAssertFalse(app.staticTexts["Card Saved"].exists)

        app.buttons["scan.close"].tap()
        XCTAssertTrue(app.buttons["tab.cardHolder"].waitForExistence(timeout: 10))
        app.buttons["tab.cardHolder"].tap()
        XCTAssertTrue(app.navigationBars["CardHolder"].waitForExistence(timeout: 5))
        XCTAssertEqual(
            app.buttons.matching(identifier: "card.row").count,
            1,
            "Take the next does not save a second card"
        )
    }
}

// MARK: - Helpers

private extension T12SaveCardUITests {
    @MainActor
    func launch(emptyStore: Bool, datasetImage: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = (emptyStore ? ["-uiTestEmptyStore"] : [])
            + ["-uiTestRecognizeDatasetImage", datasetImage]
        app.launch()
        XCTAssertTrue(app.buttons["tab.scan"].waitForExistence(timeout: 10))
        app.buttons["tab.scan"].tap()
        XCTAssertTrue(app.buttons["scan.shutter"].waitForExistence(timeout: 5))
        return app
    }

    /// Shutter → (Continue saving if no card rectangle) → Edit Card → rename → Save.
    @MainActor
    func saveEditedCard(in app: XCUIApplication) {
        app.buttons["scan.shutter"].tap()
        let alert = app.alerts["Card area not found"]
        if alert.waitForExistence(timeout: 1) {
            alert.buttons["Continue saving"].tap()
        }
        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 25))

        let fullName = app.textFields["editCard.fullName"]
        XCTAssertTrue(fullName.waitForExistence(timeout: 5))
        fullName.tap()
        let current = fullName.value as? String ?? ""
        fullName.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count + 2))
        fullName.typeText(editedName)
        XCTAssertEqual(fullName.value as? String, editedName)

        let save = app.buttons["Save"]
        XCTAssertTrue(save.isEnabled)
        save.tap()
    }
}

// MARK: - Dataset fixtures

private struct SaveUITestCard: Decodable {
    struct Expected: Decodable {
        let company: String?
        let email: String?
    }

    let id: String
    let image: String
    let expected: Expected
}

private extension T12SaveCardUITests {
    static var referenceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // CamCard CopyUITests
            .deletingLastPathComponent() // repository root
            .appendingPathComponent("reference")
    }

    func datasetCard(id: String) throws -> SaveUITestCard {
        let data = try Data(contentsOf: Self.referenceRoot.appendingPathComponent("ground-truth.json"))
        let cards = try JSONDecoder().decode([SaveUITestCard].self, from: data)
        return try XCTUnwrap(cards.first { $0.id == id }, "ground truth is missing \(id)")
    }

    func imagePath(for card: SaveUITestCard) throws -> String {
        Self.referenceRoot.appendingPathComponent(card.image).path
    }
}
