import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case cardHolder
    case tools
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .cardHolder: "CardHolder"
        case .tools: "Tools"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .cardHolder: "person.crop.rectangle.stack"
        case .tools: "folder"
        case .settings: "gearshape"
        }
    }

    var accessibilityIdentifier: String { "tab.\(rawValue)" }
}
