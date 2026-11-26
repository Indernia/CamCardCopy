import XCTest

final class T21ShellPlaceholderUITests: XCTestCase {
    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"]
        app.launch()
        XCTAssertTrue(app.buttons["tab.home"].waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    private func assertStillOnHome(_ app: XCUIApplication) {
        XCTAssertEqual(app.sheets.count, 0, "No sheet should open")
        XCTAssertEqual(app.keyboards.count, 0, "No keyboard should appear")
        XCTAssertTrue(app.staticTexts["placeholder.home"].exists, "Home content should stay visible")
    }

    @MainActor
    func testHomePlaceholdersExistAndAreInert() throws {
        continueAfterFailure = false
        let app = launch()

        let search = app.buttons["home.search"]
        let bell = app.buttons["home.bell"]
        let crown = app.buttons["home.crown"]
        let stats = app.buttons["home.stats"]
        let speech = app.buttons["home.promo.speechToText"]
        let accuracy = app.buttons["home.promo.highAccuracy"]
        let create = app.buttons["home.digitalCard.create"]

        for element in [search, bell, crown, stats, speech, accuracy, create] {
            XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing Home placeholder")
        }

        XCTAssertTrue(search.label.contains("Search Card Holder"))
        XCTAssertTrue(speech.label.contains("Speech to Text"))
        XCTAssertTrue(speech.label.contains("AI Summary"))
        XCTAssertTrue(accuracy.label.contains("High Accuracy"))
        XCTAssertTrue(accuracy.label.contains("99.99% Accuracy"))
        XCTAssertTrue(create.label.contains("Create New Card"))

        let myDigitalCard = app.staticTexts["placeholder.home"]
        XCTAssertEqual(myDigitalCard.label, "My Digital Card")
        XCTAssertTrue(app.staticTexts["No cards yet. Create a new one!"].exists)

        for element in [search, bell, crown, stats, speech, accuracy, create] {
            element.tap()
            assertStillOnHome(app)
        }
    }

    @MainActor
    func testCardHolderBellIsInert() throws {
        continueAfterFailure = false
        let app = launch()

        app.buttons["tab.cardHolder"].tap()

        let bell = app.buttons["cardholder.bell"]
        XCTAssertTrue(bell.waitForExistence(timeout: 5), "Missing CardHolder bell")
        XCTAssertTrue(app.staticTexts["No cards"].exists, "The empty state should stay visible")

        bell.tap()

        XCTAssertEqual(app.sheets.count, 0, "No sheet should open")
        XCTAssertTrue(app.staticTexts["No cards"].exists, "CardHolder content should stay visible")
        XCTAssertTrue(app.buttons["tab.cardHolder"].exists, "CardHolder should stay the current tab")
    }

    @MainActor
    func testToolsPlaceholdersExistAndAreInert() throws {
        continueAfterFailure = false
        let app = launch()

        app.buttons["tab.tools"].tap()

        let recommend = app.buttons["tools.segment.recommend"]
        let smartSync = app.buttons["tools.segment.smartSync"]
        XCTAssertTrue(recommend.waitForExistence(timeout: 5), "Missing Tools selector")
        XCTAssertTrue(smartSync.waitForExistence(timeout: 5), "Missing Tools selector")
        XCTAssertTrue(app.buttons["tools.help"].exists, "Missing Tools Help")

        let recommendTiles = [
            "aiTranscription",
            "emailSignatures",
            "videoConferenceCard",
            "dashboard",
            "highAccuracy",
            "teamBusinessCard"
        ].map { app.buttons["tools.recommend.\($0)"] }
        for tile in recommendTiles {
            XCTAssertTrue(tile.waitForExistence(timeout: 5), "Missing Recommend tile")
        }

        recommendTiles[0].tap()
        XCTAssertEqual(app.sheets.count, 0, "No sheet should open")
        XCTAssertTrue(recommendTiles[1].exists, "Recommend should stay selected")

        smartSync.tap()

        let syncTiles = [
            "saveToContacts",
            "contactsBackup",
            "salesforce",
            "googleContacts",
            "outlookOffice365",
            "exportExcelVcf"
        ].map { app.buttons["tools.sync.\($0)"] }
        for tile in syncTiles {
            XCTAssertTrue(tile.waitForExistence(timeout: 5), "Missing Smart sync tile")
        }
        XCTAssertFalse(recommendTiles[0].exists, "Recommend tiles should be gone")

        syncTiles[0].tap()
        XCTAssertEqual(app.sheets.count, 0, "No sheet should open")
        XCTAssertTrue(syncTiles[1].exists, "Smart sync should stay selected")

        app.buttons["tools.help"].tap()
        XCTAssertEqual(app.sheets.count, 0, "No sheet should open")
        XCTAssertTrue(app.buttons["tools.segment.smartSync"].exists, "Tools should stay visible")

        let title = app.staticTexts["tools.title"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "Missing Tools title")
        let frameBefore = title.frame

        app.swipeUp()

        XCTAssertEqual(title.frame, frameBefore, "The Tools title must stay fixed while the grid scrolls")
        XCTAssertTrue(title.isHittable, "The Tools title must stay visible above the grid")
    }

    @MainActor
    func testSettingsRowsExistAndOpenTheirPages() throws {
        continueAfterFailure = false
        let app = launch()

        app.buttons["tab.settings"].tap()

        let signIn = app.buttons["settings.signIn"]
        let upgrade = app.buttons["settings.premium.upgrade"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 5), "Missing Settings sign-in")
        XCTAssertTrue(upgrade.exists, "Missing Settings Upgrade")
        XCTAssertTrue(app.staticTexts["APP SETTINGS"].exists, "Missing APP SETTINGS header")

        let premiumItems = [
            "unlimitedScan",
            "syncCRM",
            "exportExcel",
            "backUp"
        ].map { app.buttons["settings.premium.\($0)"] }
        for item in premiumItems {
            XCTAssertTrue(item.waitForExistence(timeout: 5), "Missing Premium item")
        }

        let topRows = [
            "accountAndSync",
            "general",
            "languageSetting"
        ].map { app.buttons["settings.row.\($0)"] }
        for row in topRows {
            XCTAssertTrue(row.waitForExistence(timeout: 5), "Missing Settings row \(row.identifier)")
        }

        for (element, page) in [(signIn, "settings.page.login"), (upgrade, "settings.page.paywall")]
            + premiumItems.map({ ($0, "settings.page.paywall") }) {
            element.tap()
            XCTAssertTrue(app.descendants(matching: .any)[page].waitForExistence(timeout: 5), "\(page) should open")
            app.buttons["nav.back"].tap()
            XCTAssertTrue(signIn.waitForExistence(timeout: 5), "Settings content should return")
        }

        app.swipeUp()
        app.swipeUp()

        let lowerRows = [
            "notifications",
            "privacySettings",
            "systemPermissions",
            "resumePurchases",
            "helpFeedback",
            "recommendFriends",
            "about",
            "personalInfoChecklist"
        ].map { app.buttons["settings.row.\($0)"] }
        for row in lowerRows {
            XCTAssertTrue(row.waitForExistence(timeout: 5), "Missing lower Settings row \(row.identifier)")
        }
        XCTAssertTrue(app.staticTexts["ABOUT CAMCARD"].exists, "Missing ABOUT CAMCARD header")

        let lowerPages = [
            "notifications": "settings.page.notifications",
            "privacySettings": "settings.page.privacy",
            "systemPermissions": "settings.page.permissions",
            "helpFeedback": "settings.page.helpFeedback",
            "recommendFriends": "settings.page.inviteFriends",
            "about": "settings.page.about",
            "personalInfoChecklist": "settings.page.piChecklist"
        ]
        for row in lowerRows {
            if row.identifier == "settings.row.resumePurchases" {
                row.tap()
                XCTAssertEqual(app.sheets.count, 0, "No sheet should open")
                XCTAssertTrue(app.buttons["tab.settings"].exists, "Settings should stay the current screen")
                continue
            }
            let page = lowerPages[String(row.identifier.dropFirst("settings.row.".count))]!
            row.tap()
            XCTAssertTrue(app.descendants(matching: .any)[page].waitForExistence(timeout: 5), "\(page) should open")
            app.buttons["nav.back"].tap()
            XCTAssertTrue(app.buttons["tab.settings"].waitForExistence(timeout: 5), "Settings should return")
        }
    }

    @MainActor
    func testSettingsGeneralIsReadOnlyAndInert() throws {
        continueAfterFailure = false
        let app = launch()

        app.buttons["tab.settings"].tap()

        let general = app.buttons["settings.row.general"]
        XCTAssertTrue(general.waitForExistence(timeout: 5), "Missing General row")
        general.tap()

        XCTAssertTrue(app.navigationBars["General"].waitForExistence(timeout: 5), "General should open")

        let newCards = app.buttons["settings.general.newCardsAutosaved"]
        XCTAssertTrue(newCards.waitForExistence(timeout: 5), "Missing General rows")
        XCTAssertTrue(newCards.label.contains("Off"), "New cards should show Off")

        let rows = [
            "fontSize",
            "recognitionLanguages",
            "sortOrder",
            "displayOrder",
            "clearYourSpace",
            "appLock"
        ].map { app.buttons["settings.general.\($0)"] }
        for row in rows {
            XCTAssertTrue(row.waitForExistence(timeout: 5), "Missing General row")
        }
        XCTAssertTrue(rows[2].label.contains("First, Last"), "Sort Order should show First, Last")
        XCTAssertTrue(rows[4].label.contains("Not logged in"), "Clear your space should show Not logged in")
        XCTAssertTrue(app.staticTexts["settings.general.showGroupSettings"].exists, "Missing toggle label")

        let showGroupSettings = app.switches["settings.general.showGroupSettings.toggle"]
        let saveCardImage = app.switches["settings.general.saveCardImage.toggle"]
        XCTAssertTrue(showGroupSettings.waitForExistence(timeout: 5), "Missing show group settings toggle")
        XCTAssertTrue(saveCardImage.exists, "Missing save card image toggle")
        XCTAssertEqual(showGroupSettings.value as? String, "0", "The toggle starts off")
        XCTAssertEqual(saveCardImage.value as? String, "0", "The toggle starts off")

        rows[0].tap()
        XCTAssertTrue(app.navigationBars["General"].exists, "General should stay visible")

        showGroupSettings.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        saveCardImage.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertEqual(showGroupSettings.value as? String, "0", "The toggle must not change")
        XCTAssertEqual(saveCardImage.value as? String, "0", "The toggle must not change")

        app.swipeUp()
        XCTAssertTrue(
            app.staticTexts["Once enabled, a password will be required to open the app"].exists,
            "Missing App Lock footer"
        )

        app.navigationBars["General"].buttons.element(boundBy: 0).tap()
        XCTAssertTrue(
            app.buttons["settings.row.general"].waitForExistence(timeout: 5),
            "Settings root should return"
        )
    }
}
