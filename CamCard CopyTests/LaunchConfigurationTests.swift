import XCTest
@testable import CamCard_Copy

final class LaunchConfigurationTests: XCTestCase {
    func testDefaultLaunchUsesNoFixtures() {
        let configuration = LaunchConfiguration(arguments: ["CamCard Copy"])

        XCTAssertFalse(configuration.resetsStore)
        XCTAssertFalse(configuration.seedsCards)
        XCTAssertEqual(configuration.scanFixture, .camera)
        XCTAssertFalse(configuration.forcesCameraDenied)
        XCTAssertNil(configuration.photoAccessOverride)
    }

    func testScanFixtureArguments() {
        XCTAssertEqual(
            LaunchConfiguration(arguments: ["-uiTestScanStubCard"]).scanFixture,
            .card
        )
        XCTAssertEqual(
            LaunchConfiguration(arguments: ["-uiTestScanStubNoCard"]).scanFixture,
            .noCard
        )
    }

    func testCameraDeniedArgument() {
        XCTAssertTrue(
            LaunchConfiguration(arguments: ["-uiTestScanStubCameraDenied"]).forcesCameraDenied
        )
    }

    func testPhotoLibraryAccessArguments() {
        XCTAssertEqual(
            LaunchConfiguration(arguments: ["-uiTestPhotoLibraryFullAccess"]).photoAccessOverride,
            .full
        )
        XCTAssertEqual(
            LaunchConfiguration(arguments: ["-uiTestPhotoLibraryLimited"]).photoAccessOverride,
            .limited
        )
        XCTAssertEqual(
            LaunchConfiguration(arguments: ["-uiTestPhotoLibraryDenied"]).photoAccessOverride,
            .denied
        )
        XCTAssertEqual(
            LaunchConfiguration(arguments: ["-uiTestPhotoLibraryNotDetermined"]).photoAccessOverride,
            .notDetermined
        )
    }
}
