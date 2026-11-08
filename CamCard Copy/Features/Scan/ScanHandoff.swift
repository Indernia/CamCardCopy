import Foundation

nonisolated struct ScanHandoff: Sendable {
    let detector: CardDetecting

    init(detector: CardDetecting = VisionCardDetector()) {
        self.detector = detector
    }

    /// Keeps the uncropped original and the corrected image separate.
    /// Returns `nil` when detection or correction cannot produce a card.
    func scannedImage(from originalImage: Data) async throws -> ScannedCardImage? {
        guard let detected = try await detector.detectCard(in: originalImage) else {
            return nil
        }
        return ScannedCardImage(
            originalImage: originalImage,
            processedImage: detected.correctedImage
        )
    }
}
