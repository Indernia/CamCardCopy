import Foundation
import SwiftData

enum ModelContainerFactory {
    static var storeURL: URL {
        URL.applicationSupportDirectory.appending(path: "CamCard.store")
    }

    static func makeContainer(at url: URL = ModelContainerFactory.storeURL) throws -> ModelContainer {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let schema = Schema([BusinessCard.self, Note.self, CardGroup.self])
        let configuration = ModelConfiguration(url: url)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func resetStore(at url: URL) throws {
        let fileManager = FileManager.default
        let storePaths = [
            url.path,
            url.path + "-shm",
            url.path + "-wal"
        ]

        for path in storePaths where fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }

        let supportDirectory = url
            .deletingLastPathComponent()
            .appending(
                path: ".\(url.deletingPathExtension().lastPathComponent)_SUPPORT",
                directoryHint: .isDirectory
            )

        if fileManager.fileExists(atPath: supportDirectory.path) {
            try fileManager.removeItem(at: supportDirectory)
        }
    }
}
