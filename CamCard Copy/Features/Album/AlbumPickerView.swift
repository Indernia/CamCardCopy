import SwiftUI
import UIKit

enum AlbumRoute: Hashable {
    case albumList
    case album(id: String, title: String)
}

struct AlbumPickerView: View {
    static let limitedBannerText = "You did not allow Camcard to access all the pictures in the album,So only show the pictures you selected."

    let library: PhotoLibraryProviding
    let onCancel: () -> Void
    let onDone: (Data) -> Void

    @State private var accessState: PhotoAccessState = .notDetermined
    @State private var albums: [PhotoAlbum] = []
    @State private var selectedAssetID: String?
    @State private var path: [AlbumRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            root
                .navigationDestination(for: AlbumRoute.self) { route in
                    switch route {
                    case .albumList:
                        albumListPage
                    case let .album(id, title):
                        AlbumGridPage(
                            library: library,
                            albumID: id,
                            title: title,
                            accessState: accessState,
                            selectedAssetID: $selectedAssetID,
                            onBack: { path.removeLast() },
                            onCancel: onCancel,
                            onDone: done
                        )
                    }
                }
        }
        .task {
            await resolveAccess()
        }
    }

    @ViewBuilder
    private var root: some View {
        switch accessState {
        case .full, .limited:
            AlbumGridPage(
                library: library,
                albumID: "recents",
                title: "Recents",
                accessState: accessState,
                selectedAssetID: $selectedAssetID,
                onBack: { path.append(.albumList) },
                onCancel: onCancel,
                onDone: done
            )
        case .denied, .restricted:
            deniedPage
        case .notDetermined:
            Color.black.ignoresSafeArea()
        }
    }

    private var albumListPage: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    path.removeLast()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Recents")
                    }
                    .foregroundStyle(.white)
                }
                .accessibilityIdentifier("album.back")
                .accessibilityLabel("Back")

                Spacer()

                Button("Cancel", action: onCancel)
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("album.cancel")
            }
            .padding()

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(albums) { album in
                        Button {
                            path.append(.album(id: album.id, title: album.title))
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "folder")
                                    .foregroundStyle(.white.opacity(0.8))
                                Text(album.title)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 14)
                        }
                        .accessibilityIdentifier("album.list.\(album.id)")
                        Divider().overlay(Color.white.opacity(0.15))
                    }
                }
            }

            bottomBar(showsDone: false)
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var deniedPage: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("album.cancel")
            }
            .padding()

            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "photo.badge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.7))
                Text("Photo access is needed to import business cards.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 24)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("album.openSettings")
            }

            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func bottomBar(showsDone: Bool) -> some View {
        HStack {
            Spacer()
            if showsDone {
                Button("Done", action: done)
                    .font(.headline)
                    .foregroundStyle(selectedAssetID == nil ? Color.white.opacity(0.4) : Color.white)
                    .disabled(selectedAssetID == nil)
                    .accessibilityIdentifier("album.done")
            }
            Spacer()
        }
        .padding()
    }

    private func done() {
        guard let assetID = selectedAssetID else { return }
        Task {
            if let data = await library.imageData(for: assetID) {
                onDone(data)
            }
        }
    }

    private func resolveAccess() async {
        var state = await library.accessState()
        if state == .notDetermined {
            state = await library.requestAccess()
        }
        accessState = state

        if state == .full || state == .limited {
            albums = await library.albums()
        }
    }
}

private struct AlbumGridPage: View {
    let library: PhotoLibraryProviding
    let albumID: String
    let title: String
    let accessState: PhotoAccessState
    @Binding var selectedAssetID: String?
    let onBack: () -> Void
    let onCancel: () -> Void
    let onDone: () -> Void

    @State private var assets: [PhotoAsset] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }
                .accessibilityIdentifier("album.back")
                .accessibilityLabel("Back")

                Spacer()

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                Button("Cancel", action: onCancel)
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("album.cancel")
            }
            .padding()

            if accessState == .limited {
                limitedBanner
            }

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 100), spacing: 2)],
                    spacing: 2
                ) {
                    ForEach(assets) { asset in
                        Button {
                            selectedAssetID = asset.id
                        } label: {
                            thumbnail(for: asset)
                                .overlay {
                                    if selectedAssetID == asset.id {
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(Color.blue, lineWidth: 3)
                                    }
                                }
                        }
                        .accessibilityIdentifier("album.asset.\(asset.id)")
                        .accessibilityValue(selectedAssetID == asset.id ? "Selected" : "Not selected")
                    }
                }
            }

            HStack {
                Spacer()
                Button("Done", action: onDone)
                    .font(.headline)
                    .foregroundStyle(selectedAssetID == nil ? Color.white.opacity(0.4) : Color.white)
                    .disabled(selectedAssetID == nil)
                    .accessibilityIdentifier("album.done")
                Spacer()
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            assets = await library.assets(in: albumID)
        }
    }

    private var limitedBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AlbumPickerView.limitedBannerText)
                .font(.footnote)
                .foregroundStyle(.black.opacity(0.8))

            HStack(spacing: 20) {
                Button("Select more photos") {
                    Task { await library.presentLimitedLibraryPicker() }
                }
                .accessibilityIdentifier("album.selectMorePhotos")

                Button("Allow access to all pictures") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .accessibilityIdentifier("album.allowAll")
            }
            .font(.footnote.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
    }

    @ViewBuilder
    private func thumbnail(for asset: PhotoAsset) -> some View {
        if let image = UIImage(data: asset.thumbnailData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 110, height: 110)
                .clipped()
        } else {
            Color(white: 0.3)
                .frame(width: 110, height: 110)
        }
    }
}
