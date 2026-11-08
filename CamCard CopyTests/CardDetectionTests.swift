import XCTest
@testable import CamCard_Copy

final class CardDetectionTests: XCTestCase {
    @MainActor
    func testT06U1RotatedCardYieldsRectangleAndCorrectedImage() async throws {
        let original = ScanFixtureFactory.cardImageData()
        let detector = VisionCardDetector()

        let detected = try await detector.detectCard(in: original)

        let card = try XCTUnwrap(detected, "A rotated synthetic card should be detected")
        XCTAssertEqual(card.normalizedCorners.count, 4)
        XCTAssertFalse(card.correctedImage.isEmpty, "A corrected image should be produced")
        XCTAssertEqual(ScanFixtureFactory.cardImageData(), original, "The original image data must be unchanged")
    }

    @MainActor
    func testT06U2PlainImageYieldsNoCard() async throws {
        let original = ScanFixtureFactory.noCardImageData()
        let detector = VisionCardDetector()

        let detected = try await detector.detectCard(in: original)

        XCTAssertNil(detected, "A plain image should not yield a card rectangle")
    }

    @MainActor
    func testCorrectionFailureIsTreatedAsNoCardFound() async throws {
        let detector = StubCardDetector(behavior: .correctionFailure)

        let detected = try await detector.detectCard(in: ScanFixtureFactory.cardImageData())

        XCTAssertNil(detected, "A correction failure reports no corrected card")
    }
}
