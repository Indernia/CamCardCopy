import SwiftUI
import XCTest

@testable import CamCard_Copy

final class ThemeTests: XCTestCase {
    func testColorTokensEqualMeasuredValues() {
        let expected: [CCColor.Token: String] = [
            .headerTint: "#F3F7F8", .sheet: "#FFFFFF", .groupedBackground: "#F0F0F0",
            .groupedCard: "#FAFAFA", .iconInk: "#1C3F64", .textPrimary: "#151314",
            .textSecondary: "#989898", .sectionHeader: "#5F5E5E", .separator: "#EAEAEA",
            .accent: "#50A6F8", .tabSelected: "#1E1E1E", .tabUnselected: "#989898",
            .scanGradientStart: "#534EF6", .scanGradientEnd: "#873EF6",
            .premiumGradientStart: "#EF8C44", .premiumGradientEnd: "#F4BA47",
            .premiumCard: "#FEF4D8"
        ]
        XCTAssertEqual(expected.count, CCColor.Token.allCases.count)
        for token in CCColor.Token.allCases {
            XCTAssertEqual(CCColor.hex(token), expected[token], "\(token)")
        }
    }

    func testHexInitializerParsesComponents() {
        let resolved = UIColor(Color(hex: "#534EF6"))
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 0x53 / 255, accuracy: 0.01)
        XCTAssertEqual(g, 0x4E / 255, accuracy: 0.01)
        XCTAssertEqual(b, 0xF6 / 255, accuracy: 0.01)
    }

    func testTypeScaleEqualsMeasuredSizes() {
        let expected: [CCFont.Role: (CGFloat, Font.Weight)] = [
            .pageTitle: (24, .regular), .navTitle: (18, .regular),
            .sectionTitle: (18, .medium), .rowEmphasis: (16, .medium),
            .row: (15, .regular), .sectionHeader: (14, .regular),
            .secondary: (13, .regular), .tabLabel: (10, .regular)
        ]
        XCTAssertEqual(expected.count, CCFont.Role.allCases.count)
        for role in CCFont.Role.allCases {
            let spec = CCFont.spec(role)
            XCTAssertEqual(spec.size, expected[role]?.0, "\(role) size")
            XCTAssertEqual(spec.weight, expected[role]?.1, "\(role) weight")
        }
    }
}
