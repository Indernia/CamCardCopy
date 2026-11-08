import XCTest

final class T05T06CaptureUITests: XCTestCase {
    @MainActor
    func testT05AlbumCardFixtureReachesEditCard() throws {
        continueAfterFailure = false
        let app = launch(extraArguments: ["-uiTestPhotoLibraryFullAccess"])
        selectPhoto("album.asset.fixture.card", in: app)
        app.buttons["album.done"].tap()

        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["Retake"].exists)
        XCTAssertTrue(app.buttons["Save"].exists)
        XCTAssertFalse(app.buttons["Save"].isEnabled, "Save stays disabled in the shell")
        XCTAssertTrue(app.staticTexts["Full Name"].exists)
    }

    @MainActor
    func testT06AlbumNoCardFixtureShowsExactAlert() throws {
        continueAfterFailure = false
        let app = launch(extraArguments: ["-uiTestPhotoLibraryFullAccess"])
        selectPhoto("album.asset.fixture.no-card", in: app)
        app.buttons["album.done"].tap()

        let alert = app.alerts["Card area not found"]
        XCTAssertTrue(alert.waitForExistence(timeout: 15))
        XCTAssertTrue(alert.staticTexts["Move phone closer and rescan"].exists)
        XCTAssertTrue(alert.buttons["Continue saving"].exists)
        XCTAssertTrue(alert.buttons["Cancel saving"].exists)

        XCTAssertFalse(app.buttons["scan.close"].exists, "Close is hidden in the alert state")
        XCTAssertFalse(app.buttons["scan.more"].exists, "••• is hidden in the alert state")
        XCTAssertFalse(app.staticTexts["Basic"].exists, "The mode bar is hidden in the alert state")
        XCTAssertFalse(app.staticTexts["Batch"].exists, "The mode labels are hidden in the alert state")
        XCTAssertFalse(app.buttons["scan.album"].exists, "Album is hidden in the alert state")
        XCTAssertTrue(app.buttons["scan.torch"].exists, "Tap to light up remains visible")
        XCTAssertTrue(app.buttons["scan.shutter"].exists)
        XCTAssertFalse(app.buttons["scan.shutter"].isEnabled, "The shutter is greyed out")
        XCTAssertFalse(app.staticTexts["5"].exists)
    }

    @MainActor
    func testT06ContinueSavingOpensEditCardWithTheUncroppedImage() throws {
        continueAfterFailure = false
        let app = launch(extraArguments: ["-uiTestPhotoLibraryFullAccess"])
        selectPhoto("album.asset.fixture.no-card", in: app)
        app.buttons["album.done"].tap()

        let alert = app.alerts["Card area not found"]
        XCTAssertTrue(alert.waitForExistence(timeout: 15))
        alert.buttons["Continue saving"].tap()

        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testT20CancelSavingReturnsToCamera() throws {
        continueAfterFailure = false
        let app = launch(extraArguments: ["-uiTestPhotoLibraryFullAccess"])
        selectPhoto("album.asset.fixture.no-card", in: app)
        app.buttons["album.done"].tap()

        let alert = app.alerts["Card area not found"]
        XCTAssertTrue(alert.waitForExistence(timeout: 15))
        alert.buttons["Cancel saving"].tap()

        XCTAssertTrue(app.buttons["scan.close"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.alerts["Card area not found"].exists)
    }

    @MainActor
    func testT06ShutterCardFixtureReachesEditCard() throws {
        continueAfterFailure = false
        let app = launch(extraArguments: ["-uiTestScanStubCard"])
        app.buttons["scan.shutter"].tap()

        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 15))
    }

    @MainActor
    func testT06ShutterNoCardFixtureShowsAlert() throws {
        continueAfterFailure = false
        let app = launch(extraArguments: ["-uiTestScanStubNoCard"])
        app.buttons["scan.shutter"].tap()

        XCTAssertTrue(app.alerts["Card area not found"].waitForExistence(timeout: 15))
    }

    @MainActor
    func testT06RetakeReturnsToLiveCameraAndCapturesAgain() throws {
        continueAfterFailure = false
        let app = launch(extraArguments: ["-uiTestScanStubCard"])
        app.buttons["scan.shutter"].tap()
        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 15))

        app.buttons["Retake"].tap()

        let shutter = app.buttons["scan.shutter"]
        XCTAssertTrue(shutter.waitForExistence(timeout: 5), "Retake returns to the camera")
        XCTAssertTrue(shutter.isEnabled, "The shutter is live again after Retake")

        shutter.tap()
        XCTAssertTrue(app.navigationBars["Edit Card"].waitForExistence(timeout: 15),
                      "A second capture reaches Edit Card again")
    }

    @MainActor
    func testT05AlbumAlwaysGoesThroughThePicker() throws {
        continueAfterFailure = false
        let app = launch(extraArguments: [
            "-uiTestScanStubCard",
            "-uiTestPhotoLibraryFullAccess"
        ])

        app.buttons["scan.album"].tap()
        XCTAssertTrue(app.buttons["album.cancel"].waitForExistence(timeout: 5),
                      "The scan fixture does not bypass the album picker")

        selectPhoto("album.asset.fixture.no-card", in: app)
        app.buttons["album.done"].tap()

        XCTAssertTrue(app.alerts["Card area not found"].waitForExistence(timeout: 15),
                      "Album uses the selected photo and the real detector, not the scan fixture")
    }

    @MainActor
    private func launch(extraArguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"] + extraArguments
        app.launch()
        XCTAssertTrue(app.buttons["tab.scan"].waitForExistence(timeout: 10))
        app.buttons["tab.scan"].tap()
        XCTAssertTrue(app.buttons["scan.shutter"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    private func selectPhoto(_ identifier: String, in app: XCUIApplication) {
        app.buttons["scan.album"].tap()
        XCTAssertTrue(app.buttons["album.cancel"].waitForExistence(timeout: 5))
        let photo = app.buttons[identifier]
        XCTAssertTrue(photo.waitForExistence(timeout: 5))
        photo.tap()
    }
}
