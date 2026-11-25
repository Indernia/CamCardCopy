import SwiftUI

/// P16-S01 Help and Feedback. Questions, categories and Contact Us are inert.
struct SettingsHelpFeedbackView: View {
    private let questions = [
        "How to redeem premium code?",
        "How to reset my login password?",
        "How to set the recognition languages?",
        "How can I get the support if I have problems or questions?",
        "How to add cards to phone contacts?",
        "How to sync cards on the phone to CamCard cloud?",
        "My phone has connected with WiFi. Why I got the message ”Sync failed”?",
        "How to continue the paid version if I changed my phone?",
        "How to transfer my cards to my new phone?"
    ]

    private let categories: [(title: String, symbol: String)] = [
        ("Account Setting", "gearshape.fill"),
        ("CardHolder", "person.text.rectangle.fill"),
        ("Scan", "camera.fill")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                sectionTitle("Most Asked Questions")
                SettingsListSection {
                    ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                        Button {
                            // TODO(P16-S01): the FAQ answer pages were not captured.
                        } label: {
                            HStack(spacing: 8) {
                                Text(question)
                                    .font(CCFont.row)
                                    .foregroundStyle(CCColor.textPrimary)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                SettingsChevron()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("settings.help.question.\(index + 1)")
                        .accessibilityLabel(question)
                    }
                }
                sectionTitle("Question Categories")
                HStack(alignment: .top, spacing: 0) {
                    ForEach(categories, id: \.title) { category in
                        Button {
                            // TODO(P16-S01): category pages were not captured.
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: category.symbol)
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color(hex: "#6F8DA4"))
                                    .frame(height: 36)
                                Text(category.title)
                                    .font(CCFont.secondary)
                                    .foregroundStyle(Color(hex: "#6B6B6B"))
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("settings.help.category.\(category.title)")
                        .accessibilityLabel(category.title)
                    }
                }
                .padding(.vertical, 28)
                .background(Color.white)
            }
        }
        .background(Color.white)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button {
                // TODO(P16-S01): the Contact Us flow was not captured.
            } label: {
                Text("Contact Us")
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Capsule().fill(CCColor.accent))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .accessibilityIdentifier("settings.help.contactUs")
            .accessibilityLabel("Contact Us")
        }
        .ccPushedNavigationBar(title: "Help and Feedback")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("settings.page.helpFeedback")
    }

    private func sectionTitle(_ text: String) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(SettingsStyle.blueTitle)
                .frame(width: 3, height: 18)
            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(SettingsStyle.blueTitle)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(CCColor.groupedBackground)
    }
}
