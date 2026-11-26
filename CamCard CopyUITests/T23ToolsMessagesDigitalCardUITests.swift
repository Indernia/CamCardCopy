import XCTest

final class T23ToolsMessagesDigitalCardUITests: XCTestCase {
    @MainActor
    private func launch(route: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestEmptyStore"]
        if let route { app.launchArguments += ["-uiTestOpenRoute", route] }
        app.launch()
        XCTAssertTrue(app.buttons["tab.tools"].waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    private func element(_ app: XCUIApplication, _ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    @MainActor
    private func labelExists(_ app: XCUIApplication, _ label: String) -> Bool {
        app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", label))
            .firstMatch.waitForExistence(timeout: 5)
    }

    @MainActor
    private func assertNoOverlay(_ app: XCUIApplication, _ message: String) {
        XCTAssertEqual(app.sheets.count, 0, message)
        XCTAssertEqual(app.alerts.count, 0, message)
        XCTAssertEqual(app.webViews.count, 0, message)
    }

    @MainActor
    private func back(_ app: XCUIApplication) {
        let button = app.buttons["nav.back"]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Missing back control")
        button.tap()
    }

    @MainActor
    func testT23ToolsBadgeAndSelectorState() throws {
        continueAfterFailure = false
        let app = launch()
        app.buttons["tab.tools"].tap()

        let recommend = app.buttons["tools.segment.recommend"]
        let smartSync = app.buttons["tools.segment.smartSync"]
        XCTAssertTrue(recommend.waitForExistence(timeout: 5))

        XCTAssertTrue(element(app, "tools.recommend.aiTranscription.badge").exists, "Missing New badge")
        for tile in ["emailSignatures", "videoConferenceCard", "dashboard", "highAccuracy", "teamBusinessCard"] {
            XCTAssertFalse(
                element(app, "tools.recommend.\(tile).badge").exists,
                "\(tile) must not show a badge"
            )
        }

        XCTAssertTrue(recommend.isSelected)
        XCTAssertFalse(smartSync.isSelected)

        smartSync.tap()
        XCTAssertFalse(recommend.isSelected)
        XCTAssertTrue(smartSync.isSelected)
        XCTAssertFalse(element(app, "tools.recommend.aiTranscription.badge").exists)

        recommend.tap()
        XCTAssertTrue(recommend.isSelected)
        XCTAssertFalse(smartSync.isSelected)
    }

    @MainActor
    func testT23MessagesToBizTipsAndBack() throws {
        continueAfterFailure = false
        let app = launch(route: "messages")
        app.buttons["tab.tools"].tap()

        let row = app.buttons["messages.row.bizTips"]
        XCTAssertTrue(row.waitForExistence(timeout: 5), "Missing Biz Tips row")
        XCTAssertTrue(app.staticTexts["Messages"].exists, "Missing Messages title")
        XCTAssertTrue(row.label.contains("Biz Tips"))
        XCTAssertTrue(row.label.contains("Sunday"))
        XCTAssertTrue(row.label.contains("Great business begins with a great first"))

        row.tap()
        XCTAssertTrue(app.staticTexts["Welcome to CamCard"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Sunday"].exists)
        XCTAssertTrue(app.staticTexts["Biz Tips"].exists, "Missing Biz Tips title")

        element(app, "bizTips.card").tap()
        assertNoOverlay(app, "The Biz Tips card must be inert")
        XCTAssertTrue(app.staticTexts["Welcome to CamCard"].exists, "Biz Tips should stay visible")

        back(app)
        XCTAssertTrue(app.buttons["messages.row.bizTips"].waitForExistence(timeout: 5))
        back(app)
        XCTAssertTrue(app.staticTexts["tools.title"].waitForExistence(timeout: 5), "Tools should return")
    }

    @MainActor
    func testT23CreateCardStepsForwardAndBack() throws {
        continueAfterFailure = false
        let app = launch(route: "createCard1")
        app.buttons["tab.tools"].tap()

        // Step 1
        XCTAssertTrue(labelExists(app, "CREATE YOUR CARD"))
        XCTAssertTrue(labelExists(app, "Choose the template you want for your digital business card"))
        XCTAssertEqual(element(app, "createCard.progress").value as? String, "1")
        XCTAssertTrue(app.buttons["createCard.continue"].exists)
        XCTAssertTrue(labelExists(app, "Already have an account"))

        app.buttons["createCard.signIn"].tap()
        assertNoOverlay(app, "Sign in must be inert")
        XCTAssertEqual(element(app, "createCard.progress").value as? String, "1")
        XCTAssertTrue(app.buttons["createCard.continue"].exists, "Step 1 should stay visible")

        app.buttons["createCard.continue"].tap()

        // Step 2
        XCTAssertTrue(labelExists(app, "Complete your information."))
        XCTAssertTrue(labelExists(app, "CREATE YOUR CARD"))
        XCTAssertEqual(element(app, "createCard.progress").value as? String, "2")
        XCTAssertTrue(labelExists(app, "Full Name"))
        XCTAssertTrue(app.textFields["createCard.field.fullName"].exists)
        XCTAssertEqual(
            app.textFields["createCard.field.company"].placeholderValue,
            "Enter company info to display."
        )
        XCTAssertEqual(
            app.textFields["createCard.field.jobTitle"].placeholderValue,
            "Enter job title info to display."
        )
        XCTAssertEqual(
            app.textFields["createCard.field.email"].placeholderValue,
            "Add an email address to be contacted."
        )
        let scan = app.buttons["createCard.scanPaperCards"]
        XCTAssertTrue(scan.exists)
        scan.tap()
        assertNoOverlay(app, "Scan paper cards must be inert")
        XCTAssertEqual(element(app, "createCard.progress").value as? String, "2")

        app.buttons["createCard.nextStep"].tap()

        // Step 3
        XCTAssertTrue(labelExists(app, "Only one step away, Sign in to save your card"))
        XCTAssertTrue(labelExists(app, "CREATE YOUR CARD"))
        XCTAssertEqual(element(app, "createCard.progress").value as? String, "3")
        XCTAssertTrue(labelExists(app, "Unregistered camcard email will be registered automatically"))
        XCTAssertTrue(labelExists(app, "Email Number"))
        XCTAssertTrue(labelExists(app, "Or continue with"))

        for identifier in [
            "createCard.signInNext",
            "createCard.agree",
            "createCard.terms",
            "createCard.privacy",
            "createCard.signIn.phone",
            "createCard.signIn.google",
            "createCard.signIn.apple"
        ] {
            let control = app.buttons[identifier]
            XCTAssertTrue(control.exists, "Missing \(identifier)")
            if !control.isHittable { app.swipeUp() }
            control.tap()
            assertNoOverlay(app, "\(identifier) must be inert")
            XCTAssertEqual(
                element(app, "createCard.progress").value as? String, "3",
                "Step 3 should stay visible after \(identifier)"
            )
        }

        back(app)
        XCTAssertEqual(element(app, "createCard.progress").value as? String, "2")
        back(app)
        XCTAssertEqual(element(app, "createCard.progress").value as? String, "1")
        back(app)
        XCTAssertTrue(app.staticTexts["tools.title"].waitForExistence(timeout: 5), "Tools should return")
    }
}
