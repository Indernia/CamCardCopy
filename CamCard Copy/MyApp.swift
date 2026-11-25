import SwiftData
import SwiftUI

@main
struct MyApp: App {
    private let container: ModelContainer
    private let repository: SwiftDataCardRepository

    init() {
        let configuration = LaunchConfiguration.current

        #if DEBUG
        if configuration.resetsStore {
            do {
                try ModelContainerFactory.resetStore(at: ModelContainerFactory.storeURL)
            } catch {
                fatalError("Unable to reset the CamCard store: \(error)")
            }
        }
        #endif

        let container: ModelContainer
        do {
            container = try ModelContainerFactory.makeContainer()
        } catch {
            fatalError("Unable to open the CamCard store: \(error)")
        }

        let repository = SwiftDataCardRepository(context: ModelContext(container))
        do {
            try StoreBootstrap.prepare(repository: repository, seed: configuration.seedsCards)
        } catch {
            fatalError("Unable to prepare the CamCard store: \(error)")
        }

        self.container = container
        self.repository = repository
    }

    var body: some Scene {
        WindowGroup {
            RootView(repository: repository)
                .preferredColorScheme(.light)
        }
        .modelContainer(container)
    }
}
