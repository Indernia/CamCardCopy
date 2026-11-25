import XCTest

/// T15 — CardHolder search on the three seed cards.
final class T15SearchUITests: XCTestCase {
    @MainActor
    private func launchCardHolder() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore", "-uiTestSeedCards"]
        app.launch()
        XCTAssertTrue(app.buttons["tab.cardHolder"].waitForExistence(timeout: 10))
        app.buttons["tab.cardHolder"].tap()
        XCTAssertTrue(app.buttons["cardholder.search"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    private func openSearch(_ app: XCUIApplication) -> XCUIElement {
        app.buttons["cardholder.search"].tap()
        let field = app.textFields["cardholder.search.field"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["cardholder.search.cancel"].exists)
        return field
    }

    @MainActor
    func testT15TappingSearchOpensFocusedField() throws {
        continueAfterFailure = false
        let app = launchCardHolder()
        _ = openSearch(app)
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
    }

    @MainActor
    func testT15NameMatch() throws {
        continueAfterFailure = false
        let app = launchCardHolder()
        let field = openSearch(app)

        field.typeText("ortiz")
        XCTAssertTrue(app.staticTexts["Blair Ortiz"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Avery Chen"].exists)
        XCTAssertFalse(app.staticTexts["Casey Lund"].exists)
    }

    @MainActor
    func testT15CompanyMatchIgnoresCase() throws {
        continueAfterFailure = false
        let app = launchCardHolder()
        let field = openSearch(app)

        field.typeText("FABRI")
        XCTAssertTrue(app.staticTexts["Casey Lund"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Blair Ortiz"].exists)
        XCTAssertFalse(app.staticTexts["Avery Chen"].exists)
    }

    @MainActor
    func testT15NoMatchShowsNoResults() throws {
        continueAfterFailure = false
        let app = launchCardHolder()
        let field = openSearch(app)

        field.typeText("zzqx")
        XCTAssertTrue(app.staticTexts["No results"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(identifier: "card.row").count, 0)
    }

    @MainActor
    func testT15CancelRestoresFullList() throws {
        continueAfterFailure = false
        let app = launchCardHolder()
        let field = openSearch(app)

        field.typeText("ortiz")
        XCTAssertTrue(app.staticTexts["Blair Ortiz"].waitForExistence(timeout: 5))

        app.buttons["cardholder.search.cancel"].tap()
        XCTAssertFalse(app.textFields["cardholder.search.field"].exists)
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5), "Keyboard should be dismissed")
        XCTAssertTrue(app.staticTexts["Avery Chen"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Casey Lund"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons.matching(identifier: "card.row").count, 3)
    }
}
