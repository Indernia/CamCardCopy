import Foundation

nonisolated struct ScanHandoff: Sendable {
    let detector: CardDetecting
    let recognizer: TextRecognizing
    let parser: CardFieldParser

    init(
        detector: CardDetecting = VisionCardDetector(),
        recognizer: TextRecognizing = VisionTextRecognizer(),
        parser: CardFieldParser = CardFieldParser()
    ) {
        self.detector = detector
        self.recognizer = recognizer
        self.parser = parser
    }

    /// Detection only: keeps the uncropped original and the corrected image separate.
    /// Returns `nil` when detection or correction cannot produce a card.
    func detectedImage(from originalImage: Data, source: ScanSource = .camera) async throws -> ScannedCardImage? {
        guard let detected = try await detector.detectCard(in: originalImage) else {
            return nil
        }
        return ScannedCardImage(
            originalImage: originalImage,
            processedImage: detected.correctedImage,
            source: source
        )
    }

    /// Detection then recognition on the corrected image (or the original when
    /// detection did not produce one).
    func scannedImage(from originalImage: Data, source: ScanSource = .camera) async throws -> ScannedCardImage? {
        guard let image = try await detectedImage(from: originalImage, source: source) else {
            return nil
        }
        return await recognizedImage(image)
    }

    /// Runs recognition on `processedImage ?? originalImage`.
    ///
    /// Returns a copy whose `recognized` is `nil` when recognition fails or yields
    /// no text, so the caller can fall back to an empty Edit Card (P04-S03).
    func recognizedImage(_ image: ScannedCardImage) async -> ScannedCardImage {
        let source = image.processedImage ?? image.originalImage
        let recognized: RecognizedCard?

        do {
            let rawText = try await recognizer.recognizeText(in: source)
            if rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                recognized = nil
            } else {
                recognized = RecognizedCard(rawText: rawText, fields: parser.parse(rawText))
            }
        } catch {
            recognized = nil
        }

        return ScannedCardImage(
            originalImage: image.originalImage,
            processedImage: image.processedImage,
            recognized: recognized,
            source: image.source
        )
    }
}
