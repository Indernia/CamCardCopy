import XCTest

@testable import CamCard_Copy

final class UITestRouteHookTests: XCTestCase {
    func testNamesMapToRoutes() {
        XCTAssertEqual(UITestRouteHook.route(from: ["-uiTestOpenRoute", "messages"]), .messages)
        XCTAssertEqual(UITestRouteHook.route(from: ["-uiTestOpenRoute", "bizTips"]), .bizTips)
        XCTAssertEqual(UITestRouteHook.route(from: ["-uiTestOpenRoute", "createCard1"]), .createCard(step: 1))
        XCTAssertEqual(UITestRouteHook.route(from: ["-uiTestOpenRoute", "createCard2"]), .createCard(step: 2))
        XCTAssertEqual(UITestRouteHook.route(from: ["-uiTestOpenRoute", "createCard3"]), .createCard(step: 3))
    }

    func testUnknownOrMissingValueIsNil() {
        XCTAssertNil(UITestRouteHook.route(from: ["-uiTestOpenRoute", "nope"]))
        XCTAssertNil(UITestRouteHook.route(from: ["-uiTestOpenRoute"]))
        XCTAssertNil(UITestRouteHook.route(from: []))
    }
}
