import SwiftUI

/// Fixed type scale measured from the reference screenshots (design D2, D3).
enum CCFont {
    enum Role: CaseIterable {
        case pageTitle, navTitle, sectionTitle, rowEmphasis, row
        case sectionHeader, secondary, tabLabel
    }

    struct Spec: Equatable {
        let size: CGFloat
        let weight: Font.Weight
    }

    static func spec(_ role: Role) -> Spec {
        switch role {
        case .pageTitle: Spec(size: 24, weight: .regular)
        case .navTitle: Spec(size: 18, weight: .regular)
        case .sectionTitle: Spec(size: 18, weight: .medium)
        case .rowEmphasis: Spec(size: 16, weight: .medium)
        case .row: Spec(size: 15, weight: .regular)
        case .sectionHeader: Spec(size: 14, weight: .regular)
        case .secondary: Spec(size: 13, weight: .regular)
        case .tabLabel: Spec(size: 10, weight: .regular)
        }
    }

    static func font(_ role: Role) -> Font {
        let s = spec(role)
        return .system(size: s.size, weight: s.weight)
    }

    static let pageTitle = font(.pageTitle)
    static let navTitle = font(.navTitle)
    static let sectionTitle = font(.sectionTitle)
    static let rowEmphasis = font(.rowEmphasis)
    static let row = font(.row)
    static let sectionHeader = font(.sectionHeader)
    static let secondary = font(.secondary)
    static let tabLabel = font(.tabLabel)
}
