import XCTest

/// T24 — Home and CardHolder wiring. Destination pages are not asserted by identifier:
/// the real pages from parallel changes replace the placeholders.
final class T24HomeCardHolderUITests: XCTestCase {
    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"]
        app.launch()
        XCTAssertTrue(app.buttons["tab.home"].waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    func testT24HomeEntriesPushAPageAndBackReturns() throws {
        continueAfterFailure = false
        let app = launch()

        for id in ["home.bell", "home.crown", "home.digitalCard.create"] {
            app.buttons[id].tap()
            XCTAssertTrue(app.buttons["nav.back"].waitForExistence(timeout: 5), "\(id) should push a page")
            XCTAssertFalse(app.staticTexts["placeholder.home"].exists, "\(id) should leave Home")
            app.buttons["nav.back"].tap()
            XCTAssertTrue(app.staticTexts["placeholder.home"].waitForExistence(timeout: 5), "\(id) back returns Home")
        }
    }

    @MainActor
    func testT24CardHolderBellPushesAndBackReturns() throws {
        continueAfterFailure = false
        let app = launch()

        app.buttons["tab.cardHolder"].tap()
        let bell = app.buttons["cardholder.bell"]
        XCTAssertTrue(bell.waitForExistence(timeout: 5))
        bell.tap()
        XCTAssertTrue(app.buttons["nav.back"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["No cards"].exists)
        app.buttons["nav.back"].tap()
        XCTAssertTrue(app.staticTexts["No cards"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testT24AddMenuShowsItemsAndOpensNothing() throws {
        continueAfterFailure = false
        let app = launch()

        app.buttons["tab.cardHolder"].tap()
        let add = app.buttons["cardholder.add"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()

        let scan = app.buttons["Scan card"]
        XCTAssertTrue(scan.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Import from album"].exists)
        XCTAssertTrue(app.staticTexts["No cards"].exists)

        scan.tap()
        XCTAssertFalse(scan.waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["No cards"].exists)
        XCTAssertFalse(app.buttons["nav.back"].exists)
        XCTAssertTrue(app.navigationBars["CardHolder"].exists)
    }
}
