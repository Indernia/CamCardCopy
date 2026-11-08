import XCTest

final class T02CameraUITests: XCTestCase {
    @MainActor
    func testT02CameraBasicSingleChromeIsShown() throws {
        continueAfterFailure = false
        let app = launchAtCamera()

        XCTAssertTrue(app.buttons["scan.close"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["scan.more"].exists)
        XCTAssertTrue(app.buttons["scan.torch"].exists)
        XCTAssertTrue(app.buttons["scan.album"].exists)
        XCTAssertTrue(app.buttons["scan.shutter"].exists)

        XCTAssertTrue(app.staticTexts["Basic"].exists)
        for title in ["Batch", "Multiple", "Single", "QR Code"] {
            XCTAssertTrue(app.staticTexts[title].exists, title)
        }
        XCTAssertEqual(app.staticTexts["scan.mode.single"].value as? String, "Selected")
        XCTAssertFalse(app.staticTexts["5"].exists, "The unconfirmed counter is not rendered")
    }

    @MainActor
    func testT02MorePlaceholderIsInert() throws {
        continueAfterFailure = false
        let app = launchAtCamera()

        app.buttons["scan.more"].tap()

        XCTAssertEqual(app.sheets.count, 0, "Tapping ••• opens no menu")
        XCTAssertTrue(app.buttons["scan.shutter"].exists)
        XCTAssertEqual(app.staticTexts["scan.mode.single"].value as? String, "Selected")
    }

    @MainActor
    func testT02OutOfScopeModeLabelsAreInert() throws {
        continueAfterFailure = false
        let app = launchAtCamera()

        for title in ["Batch", "Multiple", "QR Code"] {
            app.staticTexts[title].tap()
            XCTAssertEqual(app.staticTexts["scan.mode.single"].value as? String, "Selected")
            XCTAssertTrue(app.buttons["scan.shutter"].exists)
        }
    }

    @MainActor
    func testT02CloseReturnsToThePreviousTab() throws {
        continueAfterFailure = false
        let app = launchAtCamera()

        app.buttons["scan.close"].tap()

        XCTAssertTrue(app.staticTexts["placeholder.home"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func launchAtCamera() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"]
        app.launch()
        XCTAssertTrue(app.buttons["tab.scan"].waitForExistence(timeout: 10))
        app.buttons["tab.scan"].tap()
        return app
    }
}
