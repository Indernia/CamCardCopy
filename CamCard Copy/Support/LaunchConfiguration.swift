import Foundation

enum ScanFixtureSource: Equatable {
    case camera
    case card
    case noCard
}

struct LaunchConfiguration {
    let resetsStore: Bool
    let seedsCards: Bool
    let scanFixture: ScanFixtureSource
    let forcesCameraDenied: Bool
    let photoAccessOverride: PhotoAccessState?
    let recognizedImagePath: String?

    init(
        resetsStore: Bool,
        seedsCards: Bool,
        scanFixture: ScanFixtureSource = .camera,
        forcesCameraDenied: Bool = false,
        photoAccessOverride: PhotoAccessState? = nil,
        recognizedImagePath: String? = nil
    ) {
        self.resetsStore = resetsStore
        self.seedsCards = seedsCards
        self.scanFixture = scanFixture
        self.forcesCameraDenied = forcesCameraDenied
        self.photoAccessOverride = photoAccessOverride
        self.recognizedImagePath = recognizedImagePath
    }

    static var current: LaunchConfiguration {
        LaunchConfiguration(arguments: ProcessInfo.processInfo.arguments)
    }

    init(arguments: [String]) {
        #if DEBUG
        self.init(
            resetsStore: arguments.contains("-uiTestEmptyStore"),
            seedsCards: arguments.contains("-uiTestSeedCards"),
            scanFixture: Self.scanFixture(from: arguments),
            forcesCameraDenied: arguments.contains("-uiTestScanStubCameraDenied"),
            photoAccessOverride: Self.photoAccessState(from: arguments),
            recognizedImagePath: Self.recognizedImagePath(from: arguments)
        )
        #else
        self.init(resetsStore: false, seedsCards: false)
        #endif
    }

    #if DEBUG
    private static func scanFixture(from arguments: [String]) -> ScanFixtureSource {
        if arguments.contains("-uiTestScanStubCard") { return .card }
        if arguments.contains("-uiTestScanStubNoCard") { return .noCard }
        return .camera
    }

    private static func recognizedImagePath(from arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: "-uiTestRecognizeDatasetImage"),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private static func photoAccessState(from arguments: [String]) -> PhotoAccessState? {
        if arguments.contains("-uiTestPhotoLibraryFullAccess") { return .full }
        if arguments.contains("-uiTestPhotoLibraryLimited") { return .limited }
        if arguments.contains("-uiTestPhotoLibraryDenied") { return .denied }
        if arguments.contains("-uiTestPhotoLibraryNotDetermined") { return .notDetermined }
        return nil
    }
    #endif
}
