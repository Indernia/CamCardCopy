import AVFoundation
import Foundation

/// Owns the capture session, photo output and torch. All blocking AVFoundation work
/// runs on its own serial queue, off the main actor.
nonisolated final class CameraSession: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    let session = AVCaptureSession()

    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "camcard.camera.session")
    private var isConfigured = false
    private var photoContinuation: CheckedContinuation<Data?, Never>?

    func start() {
        queue.async { [self] in
            guard configureIfNeeded() else { return }
            if !session.isRunning {
                session.startRunning()
            }
        }
    }

    func stop() {
        queue.async { [self] in
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    func capturePhoto() async -> Data? {
        await withCheckedContinuation { continuation in
            queue.async { [self] in
                // Never call capturePhoto without an active video connection:
                // it throws NSInvalidArgumentException and crashes the app.
                guard session.isRunning,
                      let connection = output.connection(with: .video),
                      connection.isActive
                else {
                    continuation.resume(returning: nil)
                    return
                }
                photoContinuation = continuation
                output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
    }

    /// Returns the new torch state. A device without a torch is a no-op.
    @discardableResult
    func toggleTorch() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return false }
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .on ? .off : .on
            let isOn = device.torchMode == .on
            device.unlockForConfiguration()
            return isOn
        } catch {
            return false
        }
    }

    private func configureIfNeeded() -> Bool {
        guard !isConfigured else { return true }
        guard let device = AVCaptureDevice.default(for: .video) else { return false }

        session.beginConfiguration()
        session.sessionPreset = .photo

        defer { session.commitConfiguration() }

        guard
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input),
            session.canAddOutput(output)
        else {
            return false
        }

        session.addInput(input)
        session.addOutput(output)
        isConfigured = true
        return true
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let data = error == nil ? photo.fileDataRepresentation() : nil
        if let continuation = photoContinuation {
            photoContinuation = nil
            continuation.resume(returning: data)
        }
    }
}
