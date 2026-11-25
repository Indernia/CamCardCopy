import Foundation
import Observation

nonisolated enum RecognitionPhase: Equatable, Sendable {
    case idle
    case recognizing
}

@Observable
@MainActor
final class CameraViewModel {
    private(set) var permissionState: CameraPermissionState = .notDetermined
    private(set) var isProcessingCard = false
    private(set) var recognitionPhase: RecognitionPhase = .idle

    var isRecognizing: Bool {
        recognitionPhase == .recognizing
    }

    var isBusy: Bool {
        isProcessingCard || recognitionPhase != .idle
    }

    var canStartScan: Bool {
        permissionState == .authorized && !isBusy
    }

    private let authorization: CameraAuthorizationProviding
    private var hasRequestedAccess = false

    init(authorization: CameraAuthorizationProviding = SystemCameraAuthorization()) {
        self.authorization = authorization
    }

    func resolvePermission() async {
        let state = await authorization.currentState()
        permissionState = state

        guard state == .notDetermined, !hasRequestedAccess else { return }
        hasRequestedAccess = true
        permissionState = await authorization.requestAccess()
    }

    func beginProcessing() {
        isProcessingCard = true
    }

    func endProcessing() {
        isProcessingCard = false
    }

    func beginRecognition() {
        recognitionPhase = .recognizing
    }

    func endRecognition() {
        recognitionPhase = .idle
    }
}
