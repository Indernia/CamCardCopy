import SwiftUI

enum ScanRoute: Hashable {
    case editCard(ScannedCardImage)
}

struct ScanFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CameraViewModel
    @State private var path: [ScanRoute] = []
    private let configuration: LaunchConfiguration

    init(configuration: LaunchConfiguration = .current) {
        self.configuration = configuration
        let authorization: CameraAuthorizationProviding
        if configuration.forcesCameraDenied {
            authorization = StaticCameraAuthorization(state: .denied)
        } else if configuration.scanFixture != .camera {
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
                    EditCardView(image: image, onRetake: { path.removeLast() })
                        .toolbar(.visible, for: .navigationBar)
                }
            }
        }
    }
}
