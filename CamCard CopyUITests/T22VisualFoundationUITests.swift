import XCTest

final class T22VisualFoundationUITests: XCTestCase {
    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"]
        app.launch()
        XCTAssertTrue(app.buttons["tab.home"].waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    func testT22SelectedTabIsMarkedAndOthersAreNot() throws {
        continueAfterFailure = false
        let app = launch()

        let ids = ["tab.home", "tab.cardHolder", "tab.tools", "tab.settings"]
        for selected in ids {
            app.buttons[selected].tap()
            for id in ids {
                let button = app.buttons[id]
                XCTAssertTrue(button.waitForExistence(timeout: 5), id)
                XCTAssertEqual(button.isSelected, id == selected, "\(id) while \(selected) is selected")
            }
        }
        for title in ["Home", "CardHolder", "Tools", "Settings"] {
            XCTAssertTrue(app.buttons["tab.\(title.prefix(1).lowercased() + title.dropFirst())"].label.contains(title))
        }
    }

    @MainActor
    func testT22ScanButtonOpensCamera() throws {
        continueAfterFailure = false
        let app = launch()

        app.buttons["tab.scan"].tap()

        XCTAssertTrue(app.buttons["scan.close"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testT22InertControlsStayInert() throws {
        continueAfterFailure = false
        let app = launch()

        app.buttons["home.bell"].tap()
        XCTAssertTrue(app.staticTexts["placeholder.home"].exists, "Home bell opens nothing")
        XCTAssertFalse(app.buttons["nav.back"].exists)

        app.buttons["home.digitalCard.create"].tap()
        XCTAssertTrue(app.staticTexts["placeholder.home"].exists, "Create New Card opens nothing")
        XCTAssertFalse(app.buttons["nav.back"].exists)

        app.buttons["tab.cardHolder"].tap()
        let bell = app.buttons["cardholder.bell"]
        XCTAssertTrue(bell.waitForExistence(timeout: 5))
        bell.tap()
        XCTAssertTrue(app.staticTexts["No cards"].exists, "CardHolder bell opens nothing")
        XCTAssertFalse(app.buttons["nav.back"].exists)

        app.buttons["tab.settings"].tap()
        let language = app.buttons["settings.row.languageSetting"]
        XCTAssertTrue(language.waitForExistence(timeout: 5))
        language.tap()
        XCTAssertTrue(app.buttons["settings.signIn"].exists, "Language setting opens nothing")
        XCTAssertFalse(app.buttons["nav.back"].exists)
    }
}
