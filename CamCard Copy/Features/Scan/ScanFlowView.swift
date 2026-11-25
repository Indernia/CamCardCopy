import SwiftUI

enum ScanRoute: Hashable {
    case editCard(ScannedCardImage)
    case cardSaved(CardRecord)
}

struct ScanFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CameraViewModel
    @State private var path: [ScanRoute] = []
    private let configuration: LaunchConfiguration
    private let saver: CardSaver
    private let onDone: () -> Void

    init(
        repository: CardRepository,
        configuration: LaunchConfiguration = .current,
        onDone: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.saver = CardSaver(repository: repository)
        self.onDone = onDone
        let authorization: CameraAuthorizationProviding
        if configuration.forcesCameraDenied {
            authorization = StaticCameraAuthorization(state: .denied)
        } else if configuration.scanFixture != .camera || configuration.recognizedImagePath != nil {
            // Scan fixtures bypass the camera entirely, so report authorized to
            // keep the shutter usable on the no-camera simulator.
            authorization = StaticCameraAuthorization(state: .authorized)
        } else {
            authorization = SystemCameraAuthorization()
        }
        _viewModel = State(initialValue: CameraViewModel(authorization: authorization))
    }

    var body: some View {
        NavigationStack(path: $path) {
            CameraView(
                viewModel: viewModel,
                configuration: configuration,
                onScanned: { image in
                    path.append(.editCard(image))
                },
                onClose: { dismiss() }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ScanRoute.self) { route in
                switch route {
                case let .editCard(image):
                    EditCardView(
                        image: image,
                        saver: saver,
                        onRetake: { path.removeLast() },
                        onSaved: { record in path.append(.cardSaved(record)) }
                    )
                    .toolbar(.visible, for: .navigationBar)
                case let .cardSaved(card):
                    CardSavedView(
                        card: card,
                        onDone: onDone,
                        // Back to the camera for the next card; nothing more is saved.
                        onTakeNext: { path.removeAll() }
                    )
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.visible, for: .navigationBar)
                }
            }
        }
    }
}
