import XCTest

@testable import CamCard_Copy

@MainActor
final class TabBarVisibilityTests: XCTestCase {
    func testStartsVisible() {
        XCTAssertFalse(TabBarVisibility().isHidden)
    }

    func testAppearHides() {
        let visibility = TabBarVisibility()
        visibility.pageAppeared()
        XCTAssertTrue(visibility.isHidden)
    }

    func testStackedPagesStayHiddenUntilAllDisappear() {
        let visibility = TabBarVisibility()
        visibility.pageAppeared()
        visibility.pageAppeared()
        visibility.pageDisappeared()
        XCTAssertTrue(visibility.isHidden)
        visibility.pageDisappeared()
        XCTAssertFalse(visibility.isHidden)
    }

    func testExtraDisappearNeverGoesNegative() {
        let visibility = TabBarVisibility()
        visibility.pageDisappeared()
        XCTAssertEqual(visibility.pushedPages, 0)
        visibility.pageAppeared()
        XCTAssertTrue(visibility.isHidden)
    }
}
