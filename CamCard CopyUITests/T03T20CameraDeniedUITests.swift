import XCTest

final class T03T20CameraDeniedUITests: XCTestCase {
    @MainActor
    func testT03T20DeniedExplainsAndOffersSettings() throws {
        continueAfterFailure = false
        let app = launchDeniedCamera()

        XCTAssertTrue(
            app.staticTexts["Camera access is needed to photograph business cards."]
                .waitForExistence(timeout: 5)
        )
        XCTAssertTrue(app.buttons["scan.openSettings"].exists)
        XCTAssertFalse(app.alerts.element.exists, "No crash or blocking system alert is shown")
        XCTAssertFalse(app.staticTexts["Camera is not available on this device."].exists)
    }

    @MainActor
    func testT20DeniedStateCanStillBeDismissed() throws {
        continueAfterFailure = false
        let app = launchDeniedCamera()

        app.buttons["scan.close"].tap()

        XCTAssertTrue(app.staticTexts["placeholder.home"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testT03DeniedStateShutterIsDisabledAndDoesNotCrash() throws {
        continueAfterFailure = false
        let app = launchDeniedCamera()

        let shutter = app.buttons["scan.shutter"]
        XCTAssertTrue(shutter.exists)
        XCTAssertFalse(shutter.isEnabled, "The shutter is disabled without camera access")

        shutter.tap()

        XCTAssertTrue(app.buttons["scan.close"].exists, "Tapping the disabled shutter does not crash")
        XCTAssertFalse(app.navigationBars["Edit Card"].exists, "No scan starts from the denied state")
    }

    @MainActor
    private func launchDeniedCamera() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore", "-uiTestScanStubCameraDenied"]
        app.launch()

        XCTAssertTrue(app.buttons["tab.scan"].waitForExistence(timeout: 10))
        app.buttons["tab.scan"].tap()
        XCTAssertTrue(app.buttons["scan.close"].waitForExistence(timeout: 5))
        return app
    }
}
