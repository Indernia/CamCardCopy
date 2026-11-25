import SwiftUI

/// P12-S01 Language setting. Inert: "System Default" stays checked.
struct SettingsLanguageView: View {
    private let languages = [
        "System Default", "Simplified Chinese", "Traditional Chinese",
        "English", "Japanese", "Korean"
    ]

    var body: some View {
        SettingsPageScaffold(title: "Language setting", identifier: "settings.page.language") {
            SettingsListSection {
                ForEach(languages, id: \.self) { language in
                    let selected = language == "System Default"
                    Button {
                        // TODO(P12-S01): switching languages is out of scope; the check stays on System Default.
                    } label: {
                        HStack {
                            Text(language)
                                .font(CCFont.row)
                                .foregroundStyle(CCColor.textPrimary)
                            Spacer(minLength: 8)
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundStyle(CCColor.accent)
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(minHeight: 50)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings.language.\(language)")
                    .accessibilityLabel(language)
                    .accessibilityValue(selected ? "Selected" : "")
                }
            }
        }
    }
}
