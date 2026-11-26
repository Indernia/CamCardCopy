import SwiftUI

/// P33-S01 / P33-S02 / P33-S03: the three Create your card steps (design D6-D8).
/// Inert visual copy: typed values stay in `@State` and are never saved or sent.
struct CreateCardStepView: View {
    let step: Int

    @State private var fullName = ""
    @State private var company = ""
    @State private var jobTitle = ""
    @State private var email = ""
    @State private var signInEmail = ""
    @State private var selectedTemplate: Int? = 0

    private var clampedStep: Int { min(max(step, 1), 3) }

    var body: some View {
        VStack(spacing: 0) {
            CreateCardProgress(completed: clampedStep)
                .padding(.top, 7)
            CreateCardHeading()
                .padding(.top, 17.8)
            switch clampedStep {
            case 1: stepOne
            case 2: stepTwo
            default: stepThree
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CCColor.sheet.ignoresSafeArea())
        .ccPushedNavigationBar(title: "")
    }

    // MARK: Step 1 (P33-S01)

    private var stepOne: some View {
        VStack(spacing: 0) {
            CreateCardSubtitle(text: "Choose the template you want for your digital business card")
                .padding(.top, 6.9)
            carousel
                .padding(.top, 19.5)
            pageDots
                .padding(.top, 21.6)
            NavigationLink(value: AppRoute.createCard(step: 2)) {
                CreateCardPrimaryLabel(title: "Continue")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 17.6)
            .padding(.top, 27.5)
            .accessibilityIdentifier("createCard.continue")
            HStack(spacing: 8) {
                Text("Already have an account")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(CCColor.textSecondary)
                Button {
                    // TODO(P20-S01): not linked from here in the state diagram
                } label: {
                    Text("Sign in")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(CCColor.sectionHeader)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("createCard.signIn")
            }
            .padding(.top, 18.6)
            .padding(.bottom, 14)
        }
    }

    private var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    CreateCardTemplateCard()
                        .opacity(selectedTemplate == index ? 1 : 0.8)
                        .padding(.top, 8)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 79, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $selectedTemplate)
        .frame(height: 425)
        .accessibilityIdentifier("createCard.carousel")
    }

    private var pageDots: some View {
        HStack(spacing: 8.8) {
            ForEach(0..<9, id: \.self) { index in
                Circle()
                    .fill(index == (selectedTemplate ?? 0) ? CCColor.accent : Color(hex: "#E7E7E7"))
                    .frame(width: 7, height: 7)
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: Step 2 (P33-S02)

    private var stepTwo: some View {
        VStack(spacing: 0) {
            CreateCardSubtitle(text: "Complete your information.", ink: Color(hex: "#191919"))
                .padding(.top, 6.9)
            VStack(spacing: 17.5) {
                CreateCardFilledField(
                    placeholder: "",
                    floatingLabel: "Full Name",
                    isRequired: true,
                    identifier: "createCard.field.fullName",
                    text: $fullName
                )
                CreateCardFilledField(
                    placeholder: "Enter company info to display.",
                    identifier: "createCard.field.company",
                    text: $company
                )
                CreateCardFilledField(
                    placeholder: "Enter job title info to display.",
                    identifier: "createCard.field.jobTitle",
                    text: $jobTitle
                )
                CreateCardFilledField(
                    placeholder: "Add an email address to be contacted.",
                    identifier: "createCard.field.email",
                    text: $email
                )
            }
            .padding(.horizontal, 25.4)
            .padding(.top, 42)
            Button {
                // TODO(P02-S01): the scan flow is not linked from here in the state diagram
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "camera")
                    Text("Scan paper cards")
                }
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(CCColor.sectionHeader)
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
            .accessibilityIdentifier("createCard.scanPaperCards")
            .accessibilityLabel("Scan paper cards")
            Spacer(minLength: 0)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Rectangle().fill(Color(hex: "#D8D8D8")).frame(height: 0.5)
                NavigationLink(value: AppRoute.createCard(step: 3)) {
                    CreateCardPrimaryLabel(title: "Next step", height: 47)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 17.6)
                .padding(.vertical, 10)
                .accessibilityIdentifier("createCard.nextStep")
            }
            .background(CCColor.sheet)
        }
    }

    // MARK: Step 3 (P33-S03)

    private var stepThree: some View {
        ScrollView {
            VStack(spacing: 0) {
                CreateCardSubtitle(
                    text: "Only one step away, Sign in to save your card",
                    ink: Color(hex: "#121212")
                )
                .padding(.top, 6.9)
                Text("Unregistered camcard email will be registered automatically")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(CCColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25.4)
                    .padding(.top, 31.2)
                CreateCardFilledField(
                    placeholder: "",
                    floatingLabel: "Email Number",
                    identifier: "createCard.field.signInEmail",
                    text: $signInEmail
                )
                .padding(.horizontal, 25.4)
                .padding(.top, 13.9)
                agreementRow
                    .padding(.horizontal, 25.4)
                    .padding(.top, 15.9)
                Button {
                    // TODO(P20-S01): sign-in is not built; nothing is sent
                } label: {
                    CreateCardPrimaryLabel(title: "Next", height: 43.6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 25.4)
                .padding(.top, 40.1)
                .accessibilityIdentifier("createCard.signInNext")
                .accessibilityLabel("Next")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                orContinueWith
                VStack(spacing: 16) {
                    CreateCardOutlineButton(
                        title: "Sign in with phone",
                        identifier: "createCard.signIn.phone",
                        icon: { Image(systemName: "iphone").font(.system(size: 20)) },
                        action: { /* TODO(P20-S01) */ }
                    )
                    CreateCardOutlineButton(
                        title: "Sign in with Google",
                        identifier: "createCard.signIn.google",
                        icon: { Text("G").font(.system(size: 20, weight: .bold)) },
                        action: { /* TODO(P20-S01) */ }
                    )
                    CreateCardOutlineButton(
                        title: "Sign in with Apple",
                        identifier: "createCard.signIn.apple",
                        icon: { Image(systemName: "apple.logo").font(.system(size: 20)) },
                        action: { /* TODO(P20-S01) */ }
                    )
                }
                .padding(.horizontal, 25.4)
                .padding(.top, 20)
                .padding(.bottom, 3.6)
            }
            .background(CCColor.sheet)
        }
    }

    private var agreementRow: some View {
        HStack(spacing: 8) {
            Button {
                // TODO(P20-S01): terms acceptance is not built; the box stays unchecked
            } label: {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(hex: "#A5A5A5"), lineWidth: 1)
                    .frame(width: 16, height: 16)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("createCard.agree")
            .accessibilityLabel("Agree to terms")
            HStack(spacing: 0) {
                Text("Agree to ")
                    .foregroundStyle(CCColor.tabSelected)
                Button {
                    // TODO(P20-S01): no web page is opened
                } label: {
                    Text("Terms of Service").underline().foregroundStyle(CCColor.accent)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("createCard.terms")
                Text(" and ")
                    .foregroundStyle(CCColor.tabSelected)
                Button {
                    // TODO(P20-S01): no web page is opened
                } label: {
                    Text("Privacy Policy").underline().foregroundStyle(CCColor.accent)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("createCard.privacy")
            }
            .font(.system(size: 15, weight: .regular))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            Spacer(minLength: 0)
        }
    }

    private var orContinueWith: some View {
        HStack(spacing: 0) {
            Rectangle().fill(Color(hex: "#F4F4F4")).frame(height: 0.5)
                .padding(.leading, 49.5)
                .padding(.trailing, 12)
            Text("Or continue with")
                .font(CCFont.secondary)
                .foregroundStyle(Color(hex: "#8A8A8A"))
                .fixedSize()
            Rectangle().fill(Color(hex: "#F4F4F4")).frame(height: 0.5)
                .padding(.leading, 12)
                .padding(.trailing, 49.5)
        }
    }
}

/// Neutral placeholder template: grey bars and blue icons, no names, numbers or addresses (design D7).
private struct CreateCardTemplateCard: View {
    private static let bar = Color(hex: "#E6E6E6")
    private static let heading = Color(hex: "#8A8A8A")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                Color(hex: "#EAF3FC")
                VStack(alignment: .leading, spacing: 8) {
                    bar(width: 70, height: 12)
                    bar(width: 110, height: 7)
                    bar(width: 90, height: 7)
                }
                .padding(.leading, 14)
                .padding(.top, 14)
            }
            .frame(height: 100)
            VStack(alignment: .leading, spacing: 14) {
                ForEach(["phone.fill", "iphone", "envelope.fill", "mappin"], id: \.self) { symbol in
                    HStack(spacing: 12) {
                        Image(systemName: symbol)
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(Circle().fill(CCColor.accent))
                        bar(width: 120, height: 9)
                    }
                }
                Text("Experience")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Self.heading)
                    .padding(.top, 6)
                bar(width: 150, height: 9)
                bar(width: 190, height: 6)
                Rectangle().fill(Color(hex: "#EDEDED")).frame(height: 0.5)
                Text("Other information")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Self.heading)
            }
            .padding(.horizontal, 15)
            .padding(.top, 18)
            Spacer(minLength: 0)
        }
        .frame(width: 244, height: 405)
        .background(CCColor.sheet)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        .accessibilityHidden(true)
    }

    private func bar(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Self.bar)
            .frame(width: width, height: height)
    }
}
