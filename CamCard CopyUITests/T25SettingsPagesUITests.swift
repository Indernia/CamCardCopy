import XCTest

final class T25SettingsPagesUITests: XCTestCase {
    @MainActor
    private func launchSettings() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"]
        app.launch()
        XCTAssertTrue(app.buttons["tab.home"].waitForExistence(timeout: 10))
        app.buttons["tab.settings"].tap()
        XCTAssertTrue(app.buttons["settings.signIn"].waitForExistence(timeout: 5))
        return app
    }

    /// Scrolls the Settings root until the row is hittable, taps it and waits for the page.
    @MainActor
    private func open(_ rowID: String, page pageID: String, in app: XCUIApplication) {
        let row = app.buttons[rowID]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "Missing \(rowID)")
        var swipes = 0
        while !row.isHittable && swipes < 4 {
            app.swipeUp()
            swipes += 1
        }
        row.tap()
        XCTAssertTrue(page(pageID, in: app).waitForExistence(timeout: 5), "\(pageID) should open")
        XCTAssertFalse(app.buttons["tab.settings"].exists, "The tab bar is hidden on \(pageID)")
    }

    @MainActor
    private func page(_ id: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    @MainActor
    private func assertNothingOpened(_ app: XCUIApplication, _ message: String) {
        XCTAssertEqual(app.sheets.count, 0, message)
        XCTAssertEqual(app.alerts.count, 0, message)
        XCTAssertFalse(app.keyboards.element.exists, message)
    }

    @MainActor
    private func back(in app: XCUIApplication) {
        app.buttons["nav.back"].tap()
        XCTAssertTrue(app.buttons["tab.settings"].waitForExistence(timeout: 5), "Settings root should return")
    }

    @MainActor
    func testT25TabBarIsHiddenOnPushedPageAndReturns() throws {
        continueAfterFailure = false
        let app = launchSettings()
        XCTAssertTrue(app.buttons["tab.settings"].exists)
        open("settings.row.languageSetting", page: "settings.page.language", in: app)
        XCTAssertFalse(app.buttons["tab.settings"].exists)
        back(in: app)
    }

    @MainActor
    func testT25LanguageNotificationsAndPrivacy() throws {
        continueAfterFailure = false
        let app = launchSettings()

        open("settings.row.languageSetting", page: "settings.page.language", in: app)
        let languages = [
            "System Default", "Simplified Chinese", "Traditional Chinese",
            "English", "Japanese", "Korean"
        ]
        for language in languages {
            XCTAssertTrue(app.buttons[language].exists, "Missing \(language)")
        }
        XCTAssertEqual(app.buttons["System Default"].value as? String, "Selected")
        app.buttons["English"].tap()
        XCTAssertEqual(app.buttons["System Default"].value as? String, "Selected")
        XCTAssertNotEqual(app.buttons["English"].value as? String, "Selected")
        assertNothingOpened(app, "Language rows are inert")
        back(in: app)

        open("settings.row.notifications", page: "settings.page.notifications", in: app)
        XCTAssertTrue(app.staticTexts["Receive notifications"].exists)
        XCTAssertTrue(app.staticTexts["Disabled"].exists)
        XCTAssertTrue(
            app.staticTexts["Enable CamCard notifications via iPhone's Settings-> Notifications -> CamCard"].exists
        )
        let sound = app.switches["settings.notifications.sound.toggle"]
        let vibrate = app.switches["settings.notifications.vibrate.toggle"]
        XCTAssertEqual(sound.value as? String, "1")
        XCTAssertEqual(vibrate.value as? String, "1")
        sound.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertEqual(sound.value as? String, "1", "The toggle must not change")
        assertNothingOpened(app, "Notification toggles are inert")
        back(in: app)

        open("settings.row.privacySettings", page: "settings.page.privacy", in: app)
        XCTAssertTrue(app.staticTexts["AI Data Processing Consent"].exists)
        let consent = app.switches["settings.privacy.aiConsent.toggle"]
        XCTAssertEqual(consent.value as? String, "0")
        XCTAssertTrue(
            app.staticTexts["For information about CamCard's third-party AI services, tap Third Party List."].exists
        )
        consent.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertEqual(consent.value as? String, "0", "The toggle must not change")
        back(in: app)
    }

    @MainActor
    func testT25PermissionsHelpAndAbout() throws {
        continueAfterFailure = false
        let app = launchSettings()

        open("settings.row.systemPermissions", page: "settings.page.permissions", in: app)
        XCTAssertTrue(app.staticTexts["Ad tracking permission"].exists)
        XCTAssertTrue(
            app.staticTexts["Personalized ads, cross-app tracking, attribution, ad fraud prevention"].exists
        )
        XCTAssertTrue(app.buttons["Settings"].exists)
        app.buttons["Settings"].tap()
        XCTAssertTrue(page("settings.page.permissions", in: app).exists, "The Settings link opens nothing")
        assertNothingOpened(app, "The Settings link is inert")
        back(in: app)

        open("settings.row.helpFeedback", page: "settings.page.helpFeedback", in: app)
        XCTAssertTrue(app.staticTexts["Most Asked Questions"].exists)
        XCTAssertTrue(app.staticTexts["Question Categories"].exists)
        let questions = [
            "How to redeem premium code?",
            "How to reset my login password?",
            "How to set the recognition languages?",
            "How can I get the support if I have problems or questions?",
            "How to add cards to phone contacts?",
            "How to sync cards on the phone to CamCard cloud?",
            "My phone has connected with WiFi. Why I got the message ”Sync failed”?",
            "How to continue the paid version if I changed my phone?",
            "How to transfer my cards to my new phone?"
        ]
        for question in questions {
            XCTAssertTrue(app.buttons[question].exists, "Missing question \(question)")
        }
        for category in ["Account Setting", "CardHolder", "Scan"] {
            XCTAssertTrue(app.buttons[category].exists, "Missing category \(category)")
        }
        XCTAssertTrue(app.buttons["Contact Us"].exists)
        app.buttons["Contact Us"].tap()
        assertNothingOpened(app, "Contact Us is inert")
        XCTAssertTrue(page("settings.page.helpFeedback", in: app).exists)
        back(in: app)

        open("settings.row.about", page: "settings.page.about", in: app)
        for row in ["Rate It Now", "Follow us", "Contact Us"] {
            XCTAssertTrue(app.buttons[row].exists, "Missing \(row)")
        }
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'CamCard Copy '")).count > 0)
        XCTAssertTrue(app.staticTexts["CamCardTerms of Service"].exists)
        XCTAssertTrue(app.staticTexts["CamCardPrivacy Policy"].exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'IntSig'")).count > 0)
        app.buttons["Rate It Now"].tap()
        assertNothingOpened(app, "About rows are inert")
        back(in: app)
    }

    @MainActor
    func testT25InviteFriendsAndChecklist() throws {
        continueAfterFailure = false
        let app = launchSettings()

        open("settings.row.recommendFriends", page: "settings.page.inviteFriends", in: app)
        XCTAssertTrue(app.staticTexts["Recommend CamCard"].exists)
        XCTAssertTrue(app.staticTexts["Invite Friends"].exists)
        for day in ["15 days", "30 days", "180 days", "360 days"] {
            XCTAssertTrue(app.staticTexts[day].exists, "Missing \(day)")
        }
        for invited in ["invited 1", "invited 2", "invited 12", "invited 24"] {
            XCTAssertTrue(app.staticTexts[invited].exists, "Missing \(invited)")
        }
        for share in ["facebook", "sms", "email"] {
            XCTAssertTrue(app.buttons[share].exists, "Missing \(share)")
        }
        app.buttons["email"].tap()
        assertNothingOpened(app, "No composer or share sheet")
        XCTAssertTrue(page("settings.page.inviteFriends", in: app).exists)
        back(in: app)

        open("settings.row.personalInfoChecklist", page: "settings.page.piChecklist", in: app)
        let tableTitle = app.staticTexts.matching(
            NSPredicate(format: "label == 'CamCard App Collect personal information list'")
        )
        XCTAssertTrue(tableTitle.count >= 1, "Missing table title")
        for header in ["Scenario/Business Function", "Types of personal information", "Objective"] {
            XCTAssertTrue(app.staticTexts[header].exists, "Missing column \(header)")
        }
        let rowTitles = [
            "Registration and login",
            "Third party account login",
            "One click login",
            "Business card scanning, storage, reading, and management",
            "OCR recognition",
            "Address book import Network analysis"
        ]
        for title in rowTitles {
            XCTAssertTrue(app.staticTexts[title].exists, "Missing row \(title)")
        }
        back(in: app)
    }

    @MainActor
    func testT25LoginViaEmail() throws {
        continueAfterFailure = false
        let app = launchSettings()

        app.buttons["settings.signIn"].tap()
        XCTAssertTrue(page("settings.page.login", in: app).waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["tab.settings"].exists)
        XCTAssertTrue(app.staticTexts["Login via email"].exists)
        XCTAssertTrue(app.staticTexts["The Unregistered mailbox will be automatically registered"].exists)
        let email = app.textFields["settings.login.email"]
        XCTAssertTrue(email.exists)
        XCTAssertEqual(email.placeholderValue, "Please enter email")
        XCTAssertTrue(app.staticTexts["Or continue with"].exists)
        for label in [
            "Sign in with phone", "Sign in with Facebook", "Sign in with Linkedin",
            "Sign in with Google", "Sign in with Apple"
        ] {
            XCTAssertTrue(app.buttons[label].exists, "Missing \(label)")
        }
        XCTAssertTrue(app.buttons["Next"].exists)

        let agree = app.buttons["settings.login.agree"]
        agree.tap()
        XCTAssertEqual(agree.value as? String, "Unchecked", "The agree box stays unchecked")
        app.buttons["Next"].tap()
        app.buttons["Sign in with Apple"].tap()
        XCTAssertEqual(app.sheets.count, 0)
        XCTAssertEqual(app.alerts.count, 0)
        XCTAssertTrue(page("settings.page.login", in: app).exists, "Buttons open nothing")

        email.tap()
        email.typeText("a@b.c")
        XCTAssertEqual(email.value as? String, "a@b.c")
        app.staticTexts["Login via email"].tap()
        back(in: app)
        app.buttons["settings.signIn"].tap()
        XCTAssertTrue(app.textFields["settings.login.email"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["settings.login.email"].placeholderValue, "Please enter email")
        XCTAssertNotEqual(app.textFields["settings.login.email"].value as? String, "a@b.c")
        back(in: app)
    }

    @MainActor
    func testT25UpgradePlansAndAccountSync() throws {
        continueAfterFailure = false
        let app = launchSettings()

        app.buttons["settings.premium.upgrade"].tap()
        XCTAssertTrue(page("settings.page.paywall", in: app).waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["tab.settings"].exists)
        XCTAssertTrue(app.staticTexts["Upgrade Plans"].exists)
        XCTAssertTrue(app.staticTexts["Business Card Scanner"].exists)
        XCTAssertTrue(app.staticTexts["Unlimited paper business card transcriptions"].exists)
        XCTAssertTrue(app.buttons["PRO"].exists)
        XCTAssertTrue(app.buttons["Premium"].exists)
        XCTAssertTrue(app.staticTexts["Free for 3 days,then $49.99 per year.Cancel anytime."].exists)
        XCTAssertTrue(app.buttons["Continue"].exists)
        let month = app.buttons["settings.paywall.plan.1"]
        let year = app.buttons["settings.paywall.plan.12"]
        let triple = app.buttons["settings.paywall.plan.36"]
        XCTAssertTrue(month.label.contains("1 Month") && month.label.contains("$9.99/mo") && month.label.contains("$9.99"))
        XCTAssertTrue(year.label.contains("12 Months") && year.label.contains("$4.17/mo") && year.label.contains("$49.99"))
        XCTAssertTrue(year.label.contains("3-day Free Trial"))
        XCTAssertTrue(triple.label.contains("36 Months") && triple.label.contains("$3.05/mo") && triple.label.contains("$109.99"))
        XCTAssertEqual(year.value as? String, "Selected")

        month.tap()
        XCTAssertEqual(year.value as? String, "Selected", "The selection does not change")
        XCTAssertNotEqual(month.value as? String, "Selected")
        app.buttons["PRO"].tap()
        app.buttons["Continue"].tap()
        XCTAssertEqual(app.sheets.count, 0)
        XCTAssertEqual(app.alerts.count, 0)
        XCTAssertTrue(page("settings.page.paywall", in: app).exists)
        back(in: app)

        open("settings.row.accountAndSync", page: "placeholder.route.P10-S01", in: app)
        XCTAssertTrue(app.staticTexts["Not built yet"].exists)
        back(in: app)
    }
}
