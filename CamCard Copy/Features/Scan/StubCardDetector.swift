import Foundation

/// Covers cases that cannot occur naturally, such as a correction failure.
/// The UI-test happy path always uses `VisionCardDetector`.
nonisolated final class StubCardDetector: CardDetecting {
    enum Behavior: Sendable {
        /// A rectangle is reported but correction produces no image.
        case correctionFailure
    }

    private let behavior: Behavior

    init(behavior: Behavior = .correctionFailure) {
        self.behavior = behavior
    }

    func detectCard(in imageData: Data) async throws -> DetectedCard? {
        switch behavior {
        case .correctionFailure:
            return nil
        }
    }
}
