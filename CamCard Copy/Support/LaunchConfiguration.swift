import Foundation

struct LaunchConfiguration {
    let resetsStore: Bool
    let seedsCards: Bool

    static var current: LaunchConfiguration {
        let arguments = ProcessInfo.processInfo.arguments
        #if DEBUG
        return LaunchConfiguration(
            resetsStore: arguments.contains("-uiTestEmptyStore"),
            seedsCards: arguments.contains("-uiTestSeedCards")
        )
        #else
        return LaunchConfiguration(resetsStore: false, seedsCards: false)
        #endif
    }
}
