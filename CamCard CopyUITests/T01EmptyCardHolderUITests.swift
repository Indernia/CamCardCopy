import XCTest

final class T01EmptyCardHolderUITests: XCTestCase {
    @MainActor
    func testT01EmptyCardHolder() throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"]
        app.launch()

        XCTAssertTrue(app.staticTexts["placeholder.home"].waitForExistence(timeout: 10))
        for identifier in ["tab.home", "tab.cardHolder", "tab.scan", "tab.tools", "tab.settings"] {
            XCTAssertTrue(app.buttons[identifier].exists, identifier)
        }

        app.buttons["tab.scan"].tap()
        XCTAssertTrue(app.buttons["scan.close"].waitForExistence(timeout: 5))
        app.buttons["scan.close"].tap()
        XCTAssertTrue(app.staticTexts["placeholder.home"].waitForExistence(timeout: 5))

        app.buttons["tab.cardHolder"].tap()
        XCTAssertTrue(app.navigationBars["CardHolder"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Search"].exists)
        XCTAssertTrue(app.staticTexts["Cards"].exists)
        XCTAssertTrue(app.staticTexts["No cards"].exists)
        XCTAssertTrue(
            app.staticTexts["You can use the business card recognition function to upload business cards and efficiently manage your contacts"].exists
        )

        let addButton = app.buttons["cardholder.add"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        XCTAssertTrue(app.staticTexts["No cards"].exists)
        XCTAssertTrue(app.navigationBars["CardHolder"].exists)

        app.staticTexts["Search"].tap()
        XCTAssertEqual(app.keyboards.count, 0)
        XCTAssertEqual(app.textFields.count, 0)
    }
}
