import XCTest

final class T05AlbumUITests: XCTestCase {
    private let limitedBanner = "You did not allow Camcard to access all the pictures in the album,So only show the pictures you selected."

    @MainActor
    func testT05LimitedAccessShowsBannerAndActions() throws {
        continueAfterFailure = false
        let app = launchAlbum(access: "-uiTestPhotoLibraryLimited")

        XCTAssertTrue(app.staticTexts[limitedBanner].exists)
        XCTAssertTrue(app.buttons["album.selectMorePhotos"].exists)
        XCTAssertTrue(app.buttons["album.allowAll"].exists)
        XCTAssertTrue(app.buttons["album.done"].exists)
        XCTAssertFalse(app.buttons["album.done"].isEnabled, "Done is disabled until a photo is selected")
        XCTAssertTrue(app.buttons["album.asset.fixture.card"].exists)
        XCTAssertTrue(app.buttons["album.asset.fixture.no-card"].exists)
    }

    @MainActor
    func testT05BackChevronOpensAlbumListAndAlbumGrid() throws {
        continueAfterFailure = false
        let app = launchAlbum(access: "-uiTestPhotoLibraryLimited")

        app.buttons["album.back"].tap()

        XCTAssertTrue(app.buttons["album.list.recents"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["album.list.fixture.album.1"].exists)
        XCTAssertTrue(app.buttons["album.cancel"].exists)

        app.buttons["album.list.fixture.album.1"].tap()

        XCTAssertTrue(app.staticTexts["Business Cards"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["album.done"].exists)
        XCTAssertTrue(app.buttons["album.cancel"].exists)
    }

    @MainActor
    func testT05SelectingAPhotoEnablesDone() throws {
        continueAfterFailure = false
        let app = launchAlbum(access: "-uiTestPhotoLibraryFullAccess")

        app.buttons["album.asset.fixture.card"].tap()

        XCTAssertEqual(app.buttons["album.asset.fixture.card"].value as? String, "Selected")
        XCTAssertTrue(app.buttons["album.done"].isEnabled)
    }

    @MainActor
    func testT05CancelReturnsToCameraFromRecentsGrid() throws {
        continueAfterFailure = false
        let app = launchAlbum(access: "-uiTestPhotoLibraryLimited")

        app.buttons["album.cancel"].tap()

        XCTAssertTrue(app.buttons["scan.shutter"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testT05CancelReturnsToCameraFromAlbumList() throws {
        continueAfterFailure = false
        let app = launchAlbum(access: "-uiTestPhotoLibraryLimited")

        app.buttons["album.back"].tap()
        XCTAssertTrue(app.buttons["album.list.recents"].waitForExistence(timeout: 5))
        app.buttons["album.cancel"].tap()

        XCTAssertTrue(app.buttons["scan.shutter"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testT05CancelReturnsToCameraFromAlbumGrid() throws {
        continueAfterFailure = false
        let app = launchAlbum(access: "-uiTestPhotoLibraryLimited")

        app.buttons["album.back"].tap()
        XCTAssertTrue(app.buttons["album.list.fixture.album.1"].waitForExistence(timeout: 5))
        app.buttons["album.list.fixture.album.1"].tap()
        XCTAssertTrue(app.staticTexts["Business Cards"].waitForExistence(timeout: 5))
        app.buttons["album.cancel"].tap()

        XCTAssertTrue(app.buttons["scan.shutter"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testT05T20PhotoDeniedShowsExplanationAndNoCrash() throws {
        continueAfterFailure = false
        let app = launchAlbum(access: "-uiTestPhotoLibraryDenied")

        XCTAssertTrue(app.staticTexts["Photo access is needed to import business cards."].exists)
        XCTAssertTrue(app.buttons["album.openSettings"].exists)

        app.buttons["album.cancel"].tap()
        XCTAssertTrue(app.buttons["scan.shutter"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func launchAlbum(access: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore", access]
        app.launch()

        XCTAssertTrue(app.buttons["tab.scan"].waitForExistence(timeout: 10))
        app.buttons["tab.scan"].tap()
        XCTAssertTrue(app.buttons["scan.album"].waitForExistence(timeout: 5))
        app.buttons["scan.album"].tap()
        XCTAssertTrue(app.buttons["album.cancel"].waitForExistence(timeout: 5))
        return app
    }
}
