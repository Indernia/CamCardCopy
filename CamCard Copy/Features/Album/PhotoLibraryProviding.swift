import Foundation
import Photos
import PhotosUI
import UIKit

nonisolated enum PhotoAccessState: Equatable, Sendable {
    case notDetermined
    case full
    case limited
    case denied
    case restricted
}

nonisolated struct PhotoAsset: Identifiable, Equatable, Sendable {
    let id: String
    let thumbnailData: Data
}

nonisolated struct PhotoAlbum: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let isRecents: Bool
}

nonisolated protocol PhotoLibraryProviding: Sendable {
    func accessState() async -> PhotoAccessState
    func requestAccess() async -> PhotoAccessState
    func albums() async -> [PhotoAlbum]
    func assets(in albumID: String?) async -> [PhotoAsset]
    func imageData(for assetID: String) async -> Data?
    func presentLimitedLibraryPicker() async
}

nonisolated final class PhotoKitLibrary: PhotoLibraryProviding {
    func accessState() async -> PhotoAccessState {
        Self.map(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func requestAccess() async -> PhotoAccessState {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return Self.map(status)
    }

    func albums() async -> [PhotoAlbum] {
        [PhotoAlbum(id: "recents", title: "Recents", isRecents: true)]
            + fetchUserAlbums()
    }

    func assets(in albumID: String?) async -> [PhotoAsset] {
        let assets = fetchAssets(in: albumID)
        var result: [PhotoAsset] = []
        for asset in assets {
            let thumbnail = await imageData(forAsset: asset)
            result.append(PhotoAsset(id: asset.localIdentifier, thumbnailData: thumbnail ?? Data()))
        }
        return result
    }

    func imageData(for assetID: String) async -> Data? {
        let fetch = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
        guard let asset = fetch.firstObject else { return nil }
        return await imageData(forAsset: asset)
    }

    func presentLimitedLibraryPicker() async {
        await MainActor.run {
            guard
                let scene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first,
                let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
            else { return }

            var top = root
            while let presented = top.presentedViewController {
                top = presented
            }
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: top)
        }
    }

    private func fetchUserAlbums() -> [PhotoAlbum] {
        let collections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: nil
        )
        var result: [PhotoAlbum] = []
        collections.enumerateObjects { collection, _, _ in
            result.append(
                PhotoAlbum(
                    id: collection.localIdentifier,
                    title: collection.localizedTitle ?? "",
                    isRecents: false
                )
            )
        }
        return result
    }

    private func fetchAssets(in albumID: String?) -> [PHAsset] {
        if let albumID, albumID != "recents" {
            let collections = PHAssetCollection.fetchAssetCollections(
                withLocalIdentifiers: [albumID],
                options: nil
            )
            if let collection = collections.firstObject {
                let fetch = PHAsset.fetchAssets(in: collection, options: nil)
                return Self.array(from: fetch)
            }
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetch = PHAsset.fetchAssets(with: .image, options: options)
        return Self.array(from: fetch)
    }

    private func imageData(forAsset asset: PHAsset) async -> Data? {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { data, _, _, _ in
                continuation.resume(returning: data)
            }
        }
    }

    private static func array(from fetch: PHFetchResult<PHAsset>) -> [PHAsset] {
        var result: [PHAsset] = []
        fetch.enumerateObjects { asset, _, _ in
            result.append(asset)
        }
        return result
    }

    private static func map(_ status: PHAuthorizationStatus) -> PhotoAccessState {
        switch status {
        case .authorized: return .full
        case .limited: return .limited
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .notDetermined
        @unknown default: return .denied
        }
    }
}

/// Deterministic in-memory library used by unit tests and DEBUG UI tests.
nonisolated final class FakePhotoLibrary: PhotoLibraryProviding, @unchecked Sendable {
    private let lock = NSLock()
    private let initialState: PhotoAccessState
    private let resolvedState: PhotoAccessState
    private var requestCount = 0

    private let fixtureAlbums: [PhotoAlbum]
    private let fixtureAssets: [PhotoAsset]
    private let fixtureImageData: [String: Data]

    init(
        accessState: PhotoAccessState,
        resolvedState: PhotoAccessState? = nil,
        albums: [PhotoAlbum] = [PhotoAlbum(id: "recents", title: "Recents", isRecents: true)],
        assets: [PhotoAsset],
        imageData: [String: Data]
    ) {
        self.initialState = accessState
        self.resolvedState = resolvedState ?? accessState
        self.fixtureAlbums = albums
        self.fixtureAssets = assets
        self.fixtureImageData = imageData
    }

    func accessState() async -> PhotoAccessState {
        lock.withLock { requestCount > 0 ? resolvedState : initialState }
    }

    func requestAccess() async -> PhotoAccessState {
        lock.withLock {
            requestCount += 1
            return resolvedState
        }
    }

    func albums() async -> [PhotoAlbum] {
        fixtureAlbums
    }

    func assets(in albumID: String?) async -> [PhotoAsset] {
        fixtureAssets
    }

    func imageData(for assetID: String) async -> Data? {
        fixtureImageData[assetID]
    }

    func presentLimitedLibraryPicker() async {}
}
