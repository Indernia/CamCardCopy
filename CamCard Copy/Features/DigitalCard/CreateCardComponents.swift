import SwiftUI

/// Shared parts of the Create your card steps (design D6).

/// Three dashes; `completed` of them are blue. Reads "1", "2" or "3" to accessibility.
struct CreateCardProgress: View {
    let completed: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...3, id: \.self) { index in
                Capsule()
                    .fill(index <= completed ? CCColor.accent : Color(hex: "#D9D9D9"))
                    .frame(width: 41, height: 2.6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("createCard.progress")
        .accessibilityValue("\(completed)")
    }
}

/// "CREATE YOUR CARD" in blue heavy italic.
struct CreateCardHeading: View {
    var body: some View {
        Text("CREATE YOUR CARD")
            .font(.system(size: 26, weight: .black))
            .italic()
            .foregroundStyle(CCColor.accent)
    }
}

/// Subtitle line used under the heading on every step.
struct CreateCardSubtitle: View {
    let text: String
    var ink: Color = CCColor.textPrimary

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(ink)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 25)
    }
}

/// Blue capsule label; wrap it in a Button or NavigationLink.
struct CreateCardPrimaryLabel: View {
    let title: String
    var height: CGFloat = 50

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Capsule().fill(CCColor.accent))
            .contentShape(Capsule())
    }
}

/// Grey rounded field. With `floatingLabel` it shows a small label above the text, optionally with a red star.
struct CreateCardFilledField: View {
    let placeholder: String
    var floatingLabel: String?
    var isRequired = false
    let identifier: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let floatingLabel {
                HStack(spacing: 1) {
                    Text(floatingLabel)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color(hex: "#AAAAAA"))
                    if isRequired {
                        Text("*")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(Color(hex: "#E83521"))
                    }
                }
                .padding(.bottom, 2)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(floatingLabel)
            }
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).foregroundColor(Color(hex: "#A9A9A9"))
            )
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(CCColor.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .accessibilityIdentifier(identifier)
        }
        .padding(.horizontal, 17)
        .frame(height: 49.5, alignment: .center)
        .background(RoundedRectangle(cornerRadius: 10).fill(CCColor.groupedBackground))
    }
}

/// White outlined capsule with a leading icon and centered title (step 3).
struct CreateCardOutlineButton<Icon: View>: View {
    let title: String
    let identifier: String
    let icon: Icon
    let action: () -> Void

    init(
        title: String,
        identifier: String,
        @ViewBuilder icon: () -> Icon,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.identifier = identifier
        self.icon = icon()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color(hex: "#161616"))
                HStack {
                    icon
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color(hex: "#161616"))
                    Spacer()
                }
                .padding(.leading, 22)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .overlay(Capsule().stroke(Color(hex: "#CECECE"), lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(title)
    }
}
