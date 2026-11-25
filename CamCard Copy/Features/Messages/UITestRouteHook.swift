import Foundation

/// DEBUG-only hook: `-uiTestOpenRoute <name>` makes the Tools tab push that route on first appear
/// (design D10). Release builds always return nil.
enum UITestRouteHook {
    static func route(from arguments: [String]) -> AppRoute? {
        #if DEBUG
        guard let index = arguments.firstIndex(of: "-uiTestOpenRoute"),
              arguments.indices.contains(index + 1) else { return nil }
        switch arguments[index + 1] {
        case "messages": return .messages
        case "bizTips": return .bizTips
        case "createCard1": return .createCard(step: 1)
        case "createCard2": return .createCard(step: 2)
        case "createCard3": return .createCard(step: 3)
        default: return nil
        }
        #else
        return nil
        #endif
    }
}
