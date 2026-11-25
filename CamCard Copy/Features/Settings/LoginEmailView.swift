import SwiftUI

/// P20-S01 Login via email. The email box accepts typing that is never saved; every button is inert.
struct LoginEmailView: View {
    @State private var email = ""

    private let socialBorder = Color(hex: "#D3D3D3")

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                form(minHeight: proxy.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.white)
        .ccPushedNavigationBar(title: "")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("settings.page.login")
    }

    private func form(minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Login via email")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(CCColor.textPrimary)
                .padding(.top, 20)
            Text("The Unregistered mailbox will be automatically registered")
                .font(CCFont.row)
                .foregroundStyle(CCColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)

            TextField(
                "",
                text: $email,
                prompt: Text("Please enter email").foregroundStyle(Color(hex: "#C4C4C4"))
            )
            .font(.system(size: 16))
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 14)
            .frame(height: 50)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "#D8D8D8"), lineWidth: 1))
            .padding(.top, 22)
            .accessibilityIdentifier("settings.login.email")

            HStack(spacing: 12) {
                Button {
                    // TODO(P20-S01): the agree box stays unchecked.
                } label: {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(socialBorder, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("settings.login.agree")
                .accessibilityLabel("Agree box")
                .accessibilityValue("Unchecked")
                HStack(spacing: 4) {
                    Text("Agree to")
                    Text("Terms of Service").foregroundStyle(CCColor.accent).underline()
                    Text("and")
                    Text("Privacy Policy").foregroundStyle(CCColor.accent).underline()
                }
                .font(CCFont.row)
                .foregroundStyle(CCColor.textPrimary)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Agree to Terms of Service and Privacy Policy")
            }
            .padding(.top, 20)

            Button {
                // TODO(P20-S01): signing in is out of scope.
            } label: {
                Text("Next")
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Capsule().fill(CCColor.accent))
            }
            .buttonStyle(.plain)
            .padding(.top, 34)
            .accessibilityIdentifier("settings.login.next")
            .accessibilityLabel("Next")

            Color.clear.frame(height: max(24, minHeight - 587))

            HStack(spacing: 14) {
                Rectangle().fill(CCColor.groupedBackground).frame(height: 1)
                Text("Or continue with")
                    .font(CCFont.secondary)
                    .foregroundStyle(CCColor.textSecondary)
                    .fixedSize()
                Rectangle().fill(CCColor.groupedBackground).frame(height: 1)
            }
            .padding(.horizontal, 24)

            VStack(spacing: 8) {
                socialButton("Sign in with phone", id: "phone") { Image(systemName: "iphone").font(.system(size: 24)) }
                socialButton("Sign in with Facebook", id: "facebook") { Text("f").font(.system(size: 26, weight: .bold)) }
                socialButton("Sign in with Linkedin", id: "linkedin") { Text("in").font(.system(size: 24, weight: .bold)) }
                socialButton("Sign in with Google", id: "google") { Text("G").font(.system(size: 24, weight: .bold)) }
                socialButton("Sign in with Apple", id: "apple") { Image(systemName: "apple.logo").font(.system(size: 22)) }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
    }

    private func socialButton<Icon: View>(_ title: String, id: String, @ViewBuilder icon: () -> Icon) -> some View {
        Button {
            // TODO(P20-S01): third-party sign-in is out of scope.
        } label: {
            ZStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundStyle(CCColor.textPrimary)
                HStack {
                    icon()
                        .foregroundStyle(CCColor.textPrimary)
                        .frame(width: 30)
                    Spacer()
                }
                .padding(.leading, 14)
            }
            .frame(height: 46)
            .frame(maxWidth: .infinity)
            .overlay(Capsule().stroke(socialBorder, lineWidth: 1))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("settings.login.\(id)")
        .accessibilityLabel(title)
    }
}
