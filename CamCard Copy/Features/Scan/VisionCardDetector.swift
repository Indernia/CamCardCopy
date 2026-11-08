import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import UIKit
import Vision

/// Real detection: Vision rectangle detection followed by Core Image perspective correction.
nonisolated final class VisionCardDetector: CardDetecting {
    @concurrent
    func detectCard(in imageData: Data) async throws -> DetectedCard? {
        guard let ciImage = CIImage(data: imageData) else { return nil }

        // Rectangle detection on a full-resolution capture takes seconds on
        // device. Detect on a downscaled copy instead; the corners are
        // normalized, so perspective correction still runs on the original.
        let extent = ciImage.extent
        let scale = min(1, 1600 / max(extent.width, extent.height))
        let detectionImage = scale < 1
            ? ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            : ciImage

        let request = VNDetectRectanglesRequest()
        request.maximumObservations = 1
        request.minimumAspectRatio = 0.3
        request.minimumSize = 0.2
        request.minimumConfidence = 0.5
        request.quadratureTolerance = 25

        let handler = VNImageRequestHandler(ciImage: detectionImage, options: [:])
        try handler.perform([request])

        guard let observation = request.results?.first else { return nil }

        let corners = [
            observation.topLeft,
            observation.topRight,
            observation.bottomRight,
            observation.bottomLeft
        ]
        guard let correctedImage = correctedImageData(for: ciImage, corners: corners) else {
            return nil
        }
        return DetectedCard(normalizedCorners: corners, correctedImage: correctedImage)
    }

    private func correctedImageData(for image: CIImage, corners: [CGPoint]) -> Data? {
        let extent = image.extent
        func imagePoint(_ point: CGPoint) -> CGPoint {
            CGPoint(
                x: extent.origin.x + point.x * extent.width,
                y: extent.origin.y + point.y * extent.height
            )
        }

        let filter = CIFilter.perspectiveCorrection()
        filter.inputImage = image
        filter.topLeft = imagePoint(corners[0])
        filter.topRight = imagePoint(corners[1])
        filter.bottomRight = imagePoint(corners[2])
        filter.bottomLeft = imagePoint(corners[3])

        guard let output = filter.outputImage else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.9)
    }
}
