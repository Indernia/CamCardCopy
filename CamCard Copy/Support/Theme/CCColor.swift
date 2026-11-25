import SwiftUI

extension Color {
    /// Builds an sRGB color from a `#RRGGBB` string.
    init(hex: String) {
        let digits = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = UInt32(digits, radix: 16) ?? 0
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: 1
        )
    }
}

/// Colors measured from the reference screenshots (design D2).
enum CCColor {
    enum Token: CaseIterable {
        case headerTint, sheet, groupedBackground, groupedCard, iconInk
        case textPrimary, textSecondary, sectionHeader, separator, accent
        case tabSelected, tabUnselected
        case scanGradientStart, scanGradientEnd
        case premiumGradientStart, premiumGradientEnd, premiumCard
    }

    static func hex(_ token: Token) -> String {
        switch token {
        case .headerTint: "#F3F7F8"
        case .sheet: "#FFFFFF"
        case .groupedBackground: "#F0F0F0"
        case .groupedCard: "#FAFAFA"
        case .iconInk: "#1C3F64"
        case .textPrimary: "#151314"
        case .textSecondary: "#989898"
        case .sectionHeader: "#5F5E5E"
        case .separator: "#EAEAEA"
        case .accent: "#50A6F8"
        case .tabSelected: "#1E1E1E"
        case .tabUnselected: "#989898"
        case .scanGradientStart: "#534EF6"
        case .scanGradientEnd: "#873EF6"
        case .premiumGradientStart: "#EF8C44"
        case .premiumGradientEnd: "#F4BA47"
        case .premiumCard: "#FEF4D8"
        }
    }

    static func color(_ token: Token) -> Color { Color(hex: hex(token)) }

    static let headerTint = color(.headerTint)
    static let sheet = color(.sheet)
    static let groupedBackground = color(.groupedBackground)
    static let groupedCard = color(.groupedCard)
    static let iconInk = color(.iconInk)
    static let textPrimary = color(.textPrimary)
    static let textSecondary = color(.textSecondary)
    static let sectionHeader = color(.sectionHeader)
    static let separator = color(.separator)
    static let accent = color(.accent)
    static let tabSelected = color(.tabSelected)
    static let tabUnselected = color(.tabUnselected)
    static let scanGradient = LinearGradient(
        colors: [color(.scanGradientStart), color(.scanGradientEnd)],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let premiumGradient = LinearGradient(
        colors: [color(.premiumGradientStart), color(.premiumGradientEnd)],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let premiumCard = color(.premiumCard)
}
