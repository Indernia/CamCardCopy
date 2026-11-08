import XCTest
@testable import CamCard_Copy

private actor FakeCameraAuthorization: CameraAuthorizationProviding {
    private let state: CameraPermissionState
    private let resolvedState: CameraPermissionState
    private(set) var requestCount = 0

    init(state: CameraPermissionState, resolvedState: CameraPermissionState) {
        self.state = state
        self.resolvedState = resolvedState
    }

    func currentState() async -> CameraPermissionState {
        state
    }

    func requestAccess() async -> CameraPermissionState {
        requestCount += 1
        return resolvedState
    }
}

final class CameraPermissionTests: XCTestCase {
    @MainActor
    func testT03NotDeterminedRequestsOnceThenResolves() async {
        let authorization = FakeCameraAuthorization(state: .notDetermined, resolvedState: .authorized)
        let viewModel = CameraViewModel(authorization: authorization)

        await viewModel.resolvePermission()

        XCTAssertEqual(viewModel.permissionState, .authorized)
        let firstCount = await authorization.requestCount
        XCTAssertEqual(firstCount, 1)

        await viewModel.resolvePermission()

        let secondCount = await authorization.requestCount
        XCTAssertEqual(secondCount, 1, "Access is requested only once")
    }

    @MainActor
    func testT03DeniedShowsDeniedState() async {
        let authorization = FakeCameraAuthorization(state: .denied, resolvedState: .denied)
        let viewModel = CameraViewModel(authorization: authorization)

        await viewModel.resolvePermission()

        XCTAssertEqual(viewModel.permissionState, .denied)
        XCTAssertTrue(viewModel.permissionState.isDenied)
    }

    @MainActor
    func testT03RestrictedShowsDeniedState() async {
        let authorization = FakeCameraAuthorization(state: .restricted, resolvedState: .restricted)
        let viewModel = CameraViewModel(authorization: authorization)

        await viewModel.resolvePermission()

        XCTAssertEqual(viewModel.permissionState, .restricted)
        XCTAssertTrue(viewModel.permissionState.isDenied)
    }

    @MainActor
    func testT03NoCameraYieldsUnavailableStateWithoutRequesting() async {
        let authorization = FakeCameraAuthorization(state: .noCamera, resolvedState: .authorized)
        let viewModel = CameraViewModel(authorization: authorization)

        await viewModel.resolvePermission()

        XCTAssertEqual(viewModel.permissionState, .noCamera)
        let requestCount = await authorization.requestCount
        XCTAssertEqual(requestCount, 0, "No camera means no permission request")
    }

    @MainActor
    func testT03CanStartScanRequiresAuthorizedAndIdle() async {
        for state in [CameraPermissionState.denied, .restricted, .noCamera] {
            let viewModel = CameraViewModel(
                authorization: FakeCameraAuthorization(state: state, resolvedState: state)
            )
            await viewModel.resolvePermission()
            XCTAssertFalse(viewModel.canStartScan, "\(state) must not allow scanning")
        }

        let viewModel = CameraViewModel(
            authorization: FakeCameraAuthorization(state: .authorized, resolvedState: .authorized)
        )
        await viewModel.resolvePermission()
        XCTAssertTrue(viewModel.canStartScan, "Authorized and idle can scan")

        viewModel.beginProcessing()
        XCTAssertFalse(viewModel.canStartScan, "Processing blocks a second scan")
        viewModel.endProcessing()
        XCTAssertTrue(viewModel.canStartScan, "Processing flag resets")
    }
}
