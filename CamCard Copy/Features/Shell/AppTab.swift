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

    var selectedSystemImage: String {
        switch self {
        case .home: "house.fill"
        case .cardHolder: "person.crop.rectangle.stack.fill"
        case .tools: "folder.fill"
        case .settings: "gearshape.fill"
        }
    }

    var accessibilityIdentifier: String { "tab.\(rawValue)" }
}
