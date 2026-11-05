import XCTest

final class T18PersistenceUITests: XCTestCase {
    @MainActor
    func testT12T13AndT18Persistence() throws {
        continueAfterFailure = false

        let app = XCUIApplication()

        app.launchArguments = ["-uiTestEmptyStore", "-uiTestSeedCards"]
        app.launch()
        openCardHolder(in: app)
        assertThreeRows(in: app)
        openAveryDetail(in: app)
        assertAveryDetail(in: app)
        app.terminate()

        app.launchArguments = ["-uiTestSeedCards"]
        app.launch()
        openCardHolder(in: app)
        assertThreeRows(in: app)
        openAveryDetail(in: app)
        assertAveryDetail(in: app)
        app.terminate()

        app.launchArguments = []
        app.launch()
        openCardHolder(in: app)
        assertThreeRows(in: app)
        openAveryDetail(in: app)
        assertAveryDetail(in: app)
    }

    @MainActor
    private func openCardHolder(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["tab.cardHolder"].waitForExistence(timeout: 10))
        app.buttons["tab.cardHolder"].tap()
        XCTAssertTrue(app.navigationBars["CardHolder"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func assertThreeRows(in app: XCUIApplication) {
        let rows = app.buttons.matching(identifier: "card.row")
        XCTAssertTrue(rows.element(boundBy: 2).waitForExistence(timeout: 5))
        XCTAssertEqual(rows.count, 3)
        XCTAssertFalse(app.staticTexts["No cards"].exists)
    }

    @MainActor
    private func openAveryDetail(in app: XCUIApplication) {
        let averyRow = app.buttons
            .matching(identifier: "card.row")
            .containing(.staticText, identifier: "Avery Chen")
            .firstMatch
        XCTAssertTrue(averyRow.waitForExistence(timeout: 5))
        averyRow.tap()
    }

    @MainActor
    private func assertAveryDetail(in app: XCUIApplication) {
        XCTAssertTrue(app.staticTexts["Full Name"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Avery Chen"].exists)
        XCTAssertTrue(app.staticTexts["Northwind Labs"].exists)
        XCTAssertTrue(app.staticTexts["avery.chen@northwind.example"].exists)
        XCTAssertTrue(app.staticTexts["VIP"].exists)
        XCTAssertTrue(app.staticTexts["Met at the iOS conference."].exists)
        XCTAssertFalse(app.staticTexts["Website"].exists)

        for label in ["Edit", "Save", "Delete", "Export", "Sync"] {
            XCTAssertFalse(app.buttons[label].exists, label)
        }
    }
}
