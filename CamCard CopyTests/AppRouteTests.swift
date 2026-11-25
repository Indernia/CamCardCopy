import XCTest

@testable import CamCard_Copy

final class AppRouteTests: XCTestCase {
    private var allRoutes: [AppRoute] {
        [.messages, .bizTips, .createCard(step: 1), .createCard(step: 2), .createCard(step: 3)]
            + SettingsPage.allCases.map { AppRoute.settings($0) }
            + [.login, .paywall]
    }

    func testEveryRouteHasTitleAndStateID() {
        for route in allRoutes {
            XCTAssertFalse(route.title.isEmpty, "\(route)")
            XCTAssertNotNil(
                route.stateID.range(of: #"^P\d{2}-S\d{2}$"#, options: .regularExpression),
                "\(route) -> \(route.stateID)"
            )
        }
    }

    func testTitlesEqualReferenceText() {
        XCTAssertEqual(AppRoute.messages.title, "Messages")
        XCTAssertEqual(AppRoute.bizTips.title, "Biz Tips")
        for step in 1...3 {
            XCTAssertEqual(AppRoute.createCard(step: step).title, "Create your card")
        }
        let settingsTitles = SettingsPage.allCases.map { AppRoute.settings($0).title }
        XCTAssertEqual(settingsTitles, [
            "Account and Sync", "Language setting", "Notifications", "Privacy Settings",
            "System permissions", "Help and Feedback", "Recommend to Friends", "About",
            "Personal Information Collection Checklist"
        ])
        XCTAssertEqual(AppRoute.login.title, "Login via email")
        XCTAssertEqual(AppRoute.paywall.title, "Upgrade Plans")
    }

    func testCreateCardStepsHaveDistinctStateIDs() {
        let ids = (1...3).map { AppRoute.createCard(step: $0).stateID }
        XCTAssertEqual(ids, ["P33-S01", "P33-S02", "P33-S03"])
    }
}
