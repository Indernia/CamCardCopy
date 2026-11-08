import Foundation
import Observation

@Observable
@MainActor
final class CameraViewModel {
    private(set) var permissionState: CameraPermissionState = .notDetermined
    private(set) var isProcessingCard = false

    var canStartScan: Bool {
        permissionState == .authorized && !isProcessingCard
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
}
