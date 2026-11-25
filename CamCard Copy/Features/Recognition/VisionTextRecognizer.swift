import Foundation
import Vision

/// Real on-device recognizer. Accurate English, no language correction, native
/// resolution.
///
/// Language correction is deliberately off: it rewrites unusual proper names,
/// email local parts and URLs toward dictionary words.
nonisolated final class VisionTextRecognizer: TextRecognizing {
    @concurrent
    func recognizeText(in imageData: Data) async throws -> String {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = false

        let handler = VNImageRequestHandler(data: imageData, options: [:])
        try handler.perform([request])

        // Vision's bounding boxes use a bottom-left origin. Reading order is
        // top to bottom, then left to right within a line.
        let observations = (request.results ?? []).sorted { lhs, rhs in
            if abs(lhs.boundingBox.maxY - rhs.boundingBox.maxY) > 0.01 {
                return lhs.boundingBox.maxY > rhs.boundingBox.maxY
            }
            return lhs.boundingBox.minX < rhs.boundingBox.minX
        }

        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
