import XCTest
@testable import CamCard_Copy

final class PhotoLibraryTests: XCTestCase {
    @MainActor
    func testT05FullAccessListsFixturePhotos() async {
        let library = PhotoFixtureFactory.makeLibrary(accessState: .full)
        let state = await library.accessState()
        XCTAssertEqual(state, .full)

        let albums = await library.albums()
        XCTAssertEqual(albums.first?.title, "Recents")

        let assets = await library.assets(in: "recents")
        XCTAssertEqual(assets.count, 6)
        XCTAssertTrue(assets.contains { $0.id == PhotoFixtureFactory.cardAssetID })
        XCTAssertTrue(assets.contains { $0.id == PhotoFixtureFactory.noCardAssetID })
    }

    @MainActor
    func testT05LimitedAccessShowsOnlySelectedPhotos() async {
        let library = PhotoFixtureFactory.makeLibrary(accessState: .limited)
        let state = await library.accessState()
        XCTAssertEqual(state, .limited)

        let assets = await library.assets(in: "recents")
        XCTAssertFalse(assets.isEmpty)
        XCTAssertLessThanOrEqual(assets.count, 6)
    }

    @MainActor
    func testT05DeniedAccessMapsToDenied() async {
        let library = PhotoFixtureFactory.makeLibrary(accessState: .denied)
        let state = await library.accessState()
        XCTAssertEqual(state, .denied)
    }

    @MainActor
    func testT05NotDeterminedRequestsThenResolves() async {
        let library = PhotoFixtureFactory.makeLibrary(accessState: .notDetermined, resolvedState: .full)
        let initial = await library.accessState()
        XCTAssertEqual(initial, .notDetermined)

        let resolved = await library.requestAccess()
        XCTAssertEqual(resolved, .full)

        let afterRequest = await library.accessState()
        XCTAssertEqual(afterRequest, .full)
    }

    @MainActor
    func testT05SelectingAFixturePhotoLoadsItsImageData() async {
        let library = PhotoFixtureFactory.makeLibrary(accessState: .full)

        let data = await library.imageData(for: PhotoFixtureFactory.cardAssetID)

        XCTAssertNotNil(data)
        XCTAssertEqual(data, ScanFixtureFactory.cardImageData())
    }
}
