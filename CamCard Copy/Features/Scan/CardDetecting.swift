import CoreGraphics
import Foundation

/// A card rectangle found in a still image, plus the perspective-corrected image.
nonisolated struct DetectedCard: Equatable, Sendable {
    /// Corners in Vision's normalized coordinates (origin bottom left).
    let normalizedCorners: [CGPoint]
    let correctedImage: Data
}

/// The original capture/import kept separate from the corrected image.
nonisolated struct ScannedCardImage: Hashable, Sendable {
    let originalImage: Data
    let processedImage: Data?
}

nonisolated protocol CardDetecting: Sendable {
    /// Returns `nil` when no card rectangle is found or correction produces no image.
    func detectCard(in imageData: Data) async throws -> DetectedCard?
}
