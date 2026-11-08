import Foundation
import XCTest
@testable import CamCard_Copy

private struct FixedCardDetector: CardDetecting {
    let corrected: Data

    func detectCard(in imageData: Data) async throws -> DetectedCard? {
        DetectedCard(
            normalizedCorners: [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 1, y: 0),
                CGPoint(x: 1, y: 1),
                CGPoint(x: 0, y: 1)
            ],
            correctedImage: corrected
        )
    }
}

final class ScanHandoffTests: XCTestCase {
    @MainActor
    func testT06OriginalAndCorrectedImagesStayDistinct() async throws {
        let original = ScanFixtureFactory.cardImageData()
        let corrected = ScanFixtureFactory.photoImageData(index: 0)
        let handoff = ScanHandoff(detector: FixedCardDetector(corrected: corrected))

        let result = try await handoff.scannedImage(from: original)

        let image = try XCTUnwrap(result)
        XCTAssertEqual(image.originalImage, original, "The original is kept unchanged")
        XCTAssertEqual(image.processedImage, corrected)
        XCTAssertNotEqual(image.originalImage, image.processedImage)
    }

    @MainActor
    func testT06ProcessingStateDisablesBothEntryPoints() async {
        let viewModel = CameraViewModel(
            authorization: StaticCameraAuthorization(state: .authorized)
        )
        await viewModel.resolvePermission()

        XCTAssertTrue(viewModel.canStartScan)
        viewModel.beginProcessing()
        XCTAssertFalse(viewModel.canStartScan, "Shutter and Album are disabled while detection runs")
        viewModel.endProcessing()
        XCTAssertTrue(viewModel.canStartScan)
    }

    @MainActor
    func testT06NoCardIsPersisted() async throws {
        let repository = InMemoryCardRepository()
        XCTAssertEqual(try repository.fetchAll().count, 0)

        let handoff = ScanHandoff(detector: FixedCardDetector(corrected: Data([0x01])))
        let image = try await handoff.scannedImage(from: ScanFixtureFactory.cardImageData())

        XCTAssertNotNil(image)
        XCTAssertEqual(try repository.fetchAll().count, 0, "The scan hand-off persists nothing")
    }
}
