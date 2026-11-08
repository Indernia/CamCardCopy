import SwiftUI
import UIKit

struct CameraView: View {
    @State private var viewModel: CameraViewModel
    @State private var session = CameraSession()
    @State private var showsAlbumPicker = false
    @State private var showsCardNotFoundAlert = false
    @State private var pendingImage: ScannedCardImage?
    @State private var pendingAlbumData: Data?
    private let configuration: LaunchConfiguration
    private let handoff: ScanHandoff
    private let photoLibrary: PhotoLibraryProviding
    private let onScanned: (ScannedCardImage) -> Void
    private let onClose: () -> Void

    init(
        viewModel: CameraViewModel,
        configuration: LaunchConfiguration = .current,
        handoff: ScanHandoff = ScanHandoff(),
        onScanned: @escaping (ScannedCardImage) -> Void,
        onClose: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.configuration = configuration
        self.handoff = handoff
        self.photoLibrary = configuration.photoAccessOverride
            .map { PhotoFixtureFactory.makeLibrary(accessState: $0) }
            ?? PhotoKitLibrary()
        self.onScanned = onScanned
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                // cardFrame sits outside every conditional at a fixed tuple
                // position, so the alert toggle never rebuilds it or its
                // CameraPreviewView. Only the cheap chrome swaps in and out.
                if !showsCardNotFoundAlert {
                    topBar
                }
                cardFrame
                if !showsCardNotFoundAlert {
                    modeRow
                }
                Spacer(minLength: 0)
                bottomBar
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .task { await viewModel.resolvePermission() }
        .onAppear {
            // Restart the session whenever the camera screen reappears
            // (e.g. popping back from Edit Card or the album picker).
            if viewModel.permissionState == .authorized {
                session.start()
            }
        }
        .onChange(of: viewModel.permissionState) { _, state in
            if state == .authorized {
                session.start()
            }
        }
        .onDisappear {
            session.stop()
        }
        .fullScreenCover(isPresented: $showsAlbumPicker) {
            AlbumPickerView(
                library: photoLibrary,
                onCancel: { showsAlbumPicker = false },
                onDone: { data in
                    pendingAlbumData = data
                    showsAlbumPicker = false
                }
            )
            .onDisappear {
                // Trigger the scan only after the picker has fully dismissed,
                // so the NavigationStack push is not dropped mid-animation.
                guard let data = pendingAlbumData else { return }
                pendingAlbumData = nil
                Task { await handleScan(data) }
            }
        }
        .alert("Card area not found", isPresented: $showsCardNotFoundAlert) {
            Button("Continue saving") {
                continueSaving()
            }
            Button("Cancel saving", role: .cancel) {
                pendingImage = nil
            }
        } message: {
            Text("Move phone closer and rescan")
        }
    }

    private func triggerShutter() {
        guard viewModel.canStartScan else { return }
        Task {
            let data: Data?
            switch configuration.scanFixture {
            case .card:
                data = ScanFixtureFactory.cardImageData()
            case .noCard:
                data = ScanFixtureFactory.noCardImageData()
            case .camera:
                data = await session.capturePhoto()
            }
            guard let data else { return }
            await handleScan(data)
        }
    }

    private func handleScan(_ data: Data) async {
        viewModel.beginProcessing()
        defer { viewModel.endProcessing() }

        do {
            if let image = try await handoff.scannedImage(from: data) {
                onScanned(image)
            } else {
                pendingImage = ScannedCardImage(originalImage: data, processedImage: nil)
                showsCardNotFoundAlert = true
            }
        } catch {
            pendingImage = ScannedCardImage(originalImage: data, processedImage: nil)
            showsCardNotFoundAlert = true
        }
    }

    private func continueSaving() {
        guard let image = pendingImage else { return }
        pendingImage = nil
        onScanned(image)
    }

    private var topBar: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
            }
            .accessibilityIdentifier("scan.close")
            .accessibilityLabel("Close")

            Spacer()

            HStack(spacing: 12) {
                Text("Basic")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                // TODO(P02-S02): High Accuracy capture is not built.
                Text("High Accuracy")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(Color.white.opacity(0.14)))

            Spacer()

            // TODO(P02-S06): the ••• menu content is not captured, so this is inert.
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
            }
            .accessibilityIdentifier("scan.more")
            .accessibilityLabel("More")
        }
    }

    private var cardFrame: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.75), lineWidth: 2)

            frameContent
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if viewModel.isProcessingCard {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .accessibilityIdentifier("scan.processing")
            }

            VStack {
                Spacer()
                Button {
                    session.toggleTorch()
                } label: {
                    Text("Tap to light up")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.black.opacity(0.45)))
                }
                .accessibilityIdentifier("scan.torch")
                .padding(.bottom, 12)
            }
        }
        .aspectRatio(1.58, contentMode: .fit)
    }

    @ViewBuilder
    private var frameContent: some View {
        switch viewModel.permissionState {
        case .authorized:
            CameraPreviewView(session: session.session)
        case .noCamera:
            explanation(
                icon: "camera.slash",
                message: "Camera is not available on this device."
            )
        case .denied, .restricted:
            explanation(
                icon: "camera.badge.ellipsis",
                message: "Camera access is needed to photograph business cards.",
                showsSettingsButton: true
            )
        case .notDetermined:
            Color.black
        }
    }

    private func explanation(
        icon: String,
        message: String,
        showsSettingsButton: Bool = false
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.7))
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 24)
            if showsSettingsButton {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("scan.openSettings")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.12))
    }

    private var modeRow: some View {
        HStack(spacing: 26) {
            modeLabel("Batch", selected: false)
            modeLabel("Multiple", selected: false)
            modeLabel("Single", selected: true)
            modeLabel("QR Code", selected: false)
        }
        .frame(maxWidth: .infinity)
    }

    private func modeLabel(_ title: String, selected: Bool) -> some View {
        // TODO(P02-S02/P02-S05): only Single is built; these labels are inert.
        Text(title)
            .font(.subheadline)
            .foregroundStyle(selected ? Color.white : Color.white.opacity(0.5))
            .underline(selected, color: .white)
            .accessibilityIdentifier("scan.mode.\(title.lowercased().replacingOccurrences(of: " ", with: ""))")
            .accessibilityValue(selected ? "Selected" : "Inactive")
    }

    private var bottomBar: some View {
        HStack {
            // Album never touches the camera, so it stays available without
            // camera access; only detection in progress disables it. The
            // alert state swaps it for an empty slot to keep the shutter
            // centered while removing Album from the accessibility tree.
            if showsCardNotFoundAlert {
                Color.clear.frame(width: 44, height: 44)
            } else {
                Button {
                    showsAlbumPicker = true
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .disabled(viewModel.isProcessingCard)
                .opacity(viewModel.isProcessingCard ? 0.4 : 1)
                .accessibilityIdentifier("scan.album")
                .accessibilityLabel("Album")
            }

            Spacer()

            shutterButton(
                greyed: showsCardNotFoundAlert,
                disabled: showsCardNotFoundAlert || !viewModel.canStartScan
            )
            .opacity(showsCardNotFoundAlert || !viewModel.canStartScan ? 0.5 : 1)

            Spacer()

            // TODO(P02-S06): the "5" counter is unconfirmed, so the slot stays empty.
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.bottom, 8)
    }

    private func shutterButton(greyed: Bool, disabled: Bool) -> some View {
        Button(action: triggerShutter) {
            Circle()
                .fill(greyed ? Color.white.opacity(0.35) : Color.white)
                .frame(width: 70, height: 70)
                .overlay(
                    Circle().stroke(
                        Color.white.opacity(greyed ? 0.3 : 0.6),
                        lineWidth: 4
                    )
                )
        }
        .disabled(disabled)
        .accessibilityIdentifier("scan.shutter")
        .accessibilityLabel("Shutter")
    }
}
