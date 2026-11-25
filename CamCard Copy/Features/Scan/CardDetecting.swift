import CoreGraphics
import Foundation

/// A card rectangle found in a still image, plus the perspective-corrected image.
nonisolated struct DetectedCard: Equatable, Sendable {
    /// Corners in Vision's normalized coordinates (origin bottom left).
    let normalizedCorners: [CGPoint]
    let correctedImage: Data
}

/// Where the card image came from. Drives the saved card's first Note line.
nonisolated enum ScanSource: Equatable, Hashable, Sendable {
    case camera
    case album

    var notePhrase: String {
        switch self {
        case .camera: "Taking photo"
        case .album: "Importing photo"
        }
    }
}

/// The original capture/import kept separate from the corrected image.
nonisolated struct ScannedCardImage: Hashable, Sendable {
    let originalImage: Data
    let processedImage: Data?
    /// `nil` when recognition failed or returned no text.
    let recognized: RecognizedCard?
    let source: ScanSource

    init(
        originalImage: Data,
        processedImage: Data?,
        recognized: RecognizedCard? = nil,
        source: ScanSource = .camera
    ) {
        self.originalImage = originalImage
        self.processedImage = processedImage
        self.recognized = recognized
        self.source = source
    }
}

nonisolated protocol CardDetecting: Sendable {
    /// Returns `nil` when no card rectangle is found or correction produces no image.
    func detectCard(in imageData: Data) async throws -> DetectedCard?
}
