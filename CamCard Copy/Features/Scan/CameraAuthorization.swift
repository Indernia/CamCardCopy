import AVFoundation
import Foundation

nonisolated enum CameraPermissionState: Equatable, Sendable {
    case authorized
    case notDetermined
    case denied
    case restricted
    case noCamera

    /// Both `.denied` and `.restricted` use the explanation plus "Open Settings" state.
    var isDenied: Bool {
        self == .denied || self == .restricted
    }
}

nonisolated protocol CameraAuthorizationProviding: Sendable {
    func currentState() async -> CameraPermissionState
    func requestAccess() async -> CameraPermissionState
}

nonisolated final class SystemCameraAuthorization: CameraAuthorizationProviding {
    func currentState() async -> CameraPermissionState {
        guard AVCaptureDevice.default(for: .video) != nil else { return .noCamera }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    func requestAccess() async -> CameraPermissionState {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .authorized : .denied
    }
}

/// DEBUG launch-hook authorization that never touches the real camera.
nonisolated struct StaticCameraAuthorization: CameraAuthorizationProviding {
    let state: CameraPermissionState

    func currentState() async -> CameraPermissionState {
        state
    }

    func requestAccess() async -> CameraPermissionState {
        state
    }
}
