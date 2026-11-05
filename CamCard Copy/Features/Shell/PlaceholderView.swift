import SwiftUI

struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.largeTitle)
                .accessibilityIdentifier("placeholder.\(title.lowercased())")
            Text("Coming soon")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
