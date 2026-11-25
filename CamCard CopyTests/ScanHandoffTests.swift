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

private struct FixedTextRecognizer: TextRecognizing {
    let text: String

    func recognizeText(in imageData: Data) async throws -> String {
        text
    }
}

private struct FailingTextRecognizer: TextRecognizing {
    struct Failure: Error {}

    func recognizeText(in imageData: Data) async throws -> String {
        throw Failure()
    }
}

private actor RecordingTextRecognizer: TextRecognizing {
    let text: String
    private(set) var receivedImages: [Data] = []

    init(text: String) {
        self.text = text
    }

    func recognizeText(in imageData: Data) async throws -> String {
        receivedImages.append(imageData)
        return text
    }
}

final class ScanHandoffTests: XCTestCase {
    private let sampleText = """
    Morgan Reyes
    Senior Designer
    Northwind Traders
    +1 555 010 2233
    morgan.reyes@example.com
    """
    .trimmingCharacters(in: .whitespaces)

    @MainActor
    func testT06OriginalAndCorrectedImagesStayDistinct() async throws {
        let original = ScanFixtureFactory.cardImageData()
        let corrected = ScanFixtureFactory.photoImageData(index: 0)
        let handoff = ScanHandoff(
            detector: FixedCardDetector(corrected: corrected),
            recognizer: FixedTextRecognizer(text: sampleText)
        )

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

        let handoff = ScanHandoff(
            detector: FixedCardDetector(corrected: Data([0x01])),
            recognizer: FixedTextRecognizer(text: sampleText)
        )
        let image = try await handoff.scannedImage(from: ScanFixtureFactory.cardImageData())

        XCTAssertNotNil(image)
        XCTAssertEqual(try repository.fetchAll().count, 0, "The scan hand-off persists nothing")
    }

    @MainActor
    func testT07RecognitionRidesAlongWithTheScannedImage() async throws {
        let handoff = ScanHandoff(
            detector: FixedCardDetector(corrected: ScanFixtureFactory.photoImageData(index: 0)),
            recognizer: FixedTextRecognizer(text: sampleText)
        )

        let scanned = try await handoff.scannedImage(from: ScanFixtureFactory.cardImageData())
        let image = try XCTUnwrap(scanned)

        XCTAssertEqual(image.recognized?.rawText, sampleText)
        XCTAssertEqual(image.recognized?.fields.name, "Morgan Reyes")
        XCTAssertEqual(image.recognized?.fields.jobTitle, "Senior Designer")
        XCTAssertEqual(image.recognized?.fields.company, "Northwind Traders")
        XCTAssertEqual(image.recognized?.fields.email, "morgan.reyes@example.com")
        XCTAssertEqual(image.recognized?.fields.phone, "+1 555 010 2233")
    }

    @MainActor
    func testT12ScanSourceSurvivesDetectionAndRecognition() async throws {
        let handoff = ScanHandoff(
            detector: FixedCardDetector(corrected: ScanFixtureFactory.photoImageData(index: 0)),
            recognizer: FixedTextRecognizer(text: sampleText)
        )

        let camera = try await handoff.scannedImage(from: ScanFixtureFactory.cardImageData())
        let album = try await handoff.scannedImage(
            from: ScanFixtureFactory.cardImageData(),
            source: .album
        )

        XCTAssertEqual(try XCTUnwrap(camera).source, .camera, "Camera is the default source")
        XCTAssertEqual(try XCTUnwrap(album).source, .album)

        let recognizedAgain = await handoff.recognizedImage(try XCTUnwrap(album))
        XCTAssertEqual(recognizedAgain.source, .album, "Recognition keeps the source")
    }

    @MainActor
    func testT07RecognitionRunsOnTheCorrectedImage() async throws {
        let original = Data([0xAA, 0xBB])
        let corrected = Data([0xCC, 0xDD])
        let recognizer = RecordingTextRecognizer(text: sampleText)
        let handoff = ScanHandoff(
            detector: FixedCardDetector(corrected: corrected),
            recognizer: recognizer
        )

        _ = try await handoff.scannedImage(from: original)

        let received = await recognizer.receivedImages
        XCTAssertEqual(received, [corrected], "Recognition uses the corrected image when one exists")
    }

    @MainActor
    func testT07RecognitionFallsBackToTheOriginalImage() async throws {
        let original = Data([0xAA, 0xBB])
        let recognizer = RecordingTextRecognizer(text: sampleText)
        let handoff = ScanHandoff(recognizer: recognizer)

        _ = await handoff.recognizedImage(
            ScannedCardImage(originalImage: original, processedImage: nil)
        )

        let received = await recognizer.receivedImages
        XCTAssertEqual(received, [original], "Recognition uses the original when no corrected image exists")
    }

    @MainActor
    func testT07RecognitionFailureYieldsNilWithoutThrowing() async {
        let handoff = ScanHandoff(recognizer: FailingTextRecognizer())

        let image = await handoff.recognizedImage(
            ScannedCardImage(originalImage: Data([0xAA]), processedImage: nil)
        )

        XCTAssertNil(image.recognized, "A recognition error falls back to an empty card")
    }

    @MainActor
    func testT07EmptyRecognitionTextYieldsNil() async {
        let handoff = ScanHandoff(recognizer: FixedTextRecognizer(text: "  \n  "))

        let image = await handoff.recognizedImage(
            ScannedCardImage(originalImage: Data([0xAA]), processedImage: nil)
        )

        XCTAssertNil(image.recognized, "Whitespace-only text is treated as no recognition")
    }

    @MainActor
    func testT07RecognitionPhaseResetsAfterSuccessAndFailure() async {
        let viewModel = CameraViewModel(
            authorization: StaticCameraAuthorization(state: .authorized)
        )
        await viewModel.resolvePermission()

        let outcomes: [ScanHandoff] = [
            ScanHandoff(recognizer: FixedTextRecognizer(text: sampleText)),
            ScanHandoff(recognizer: FailingTextRecognizer())
        ]

        for handoff in outcomes {
            viewModel.beginRecognition()
            XCTAssertTrue(viewModel.isRecognizing)
            XCTAssertFalse(viewModel.canStartScan, "Recognition blocks a second scan")

            _ = await handoff.recognizedImage(
                ScannedCardImage(originalImage: Data([0xAA]), processedImage: nil)
            )

            viewModel.endRecognition()
            XCTAssertEqual(viewModel.recognitionPhase, .idle)
            XCTAssertTrue(viewModel.canStartScan, "The camera is usable again after recognition")
        }
    }
}
