import SwiftUI

struct HomeView: View {
    var body: some View {
        CCTintedHeaderLayout {
            VStack(spacing: 0) {
                topBar
                promoRow
                    .padding(.top, 23)
            }
            .padding(.top, 8)
            .padding(.bottom, 17)
        } content: {
            ScrollView {
                digitalCardSection
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.content")
    }

    // MARK: Header

    private var topBar: some View {
        HStack(spacing: 0) {
            NavigationLink(value: AppRoute.messages) {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundStyle(CCColor.iconInk)
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.bell")
            .accessibilityLabel("Notifications")
            .padding(.trailing, 8)

            Button {
                // TODO(P00-S03): opening CardHolder search needs a frozen RootView/AppRoute edit
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                    Text("Search Card Holder")
                        .font(CCFont.row)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(CCColor.textSecondary)
                .padding(.horizontal, 12)
                .frame(height: 31)
                .background(Capsule().fill(CCColor.sheet))
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.search")
            .accessibilityLabel("Search Card Holder")

            NavigationLink(value: AppRoute.paywall) {
                // ASSUMPTION: flat gold; the artwork gradient is not copied.
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: "#F5C518"))
                    .frame(width: 40, height: 34)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.crown")
            .accessibilityLabel("Premium")

            Button {
                // TODO(P00-S01) ASSUMPTION: the stats destination was not captured
            } label: {
                Image(systemName: "chart.bar")
                    .font(.system(size: 20))
                    .foregroundStyle(CCColor.iconInk)
                    .frame(width: 42, height: 34)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.stats")
            .accessibilityLabel("Stats")
        }
        .padding(.leading, 8)
        .padding(.trailing, 5)
    }

    private var promoRow: some View {
        HStack(spacing: 12) {
            promoCard(
                icon: "mic.fill",
                iconBackground: Color(hex: "#EFF7FE"),
                iconColor: CCColor.accent,
                title: "Speech to Text",
                subtitle: "AI Summary",
                identifier: "home.promo.speechToText"
            )
            // TODO(P00-S01)
            promoCard(
                icon: "viewfinder",
                iconBackground: Color(hex: "#F7F2FE"),
                iconColor: Color(hex: "#873EF6"),
                title: "High Accuracy",
                subtitle: "99.99% Accuracy",
                identifier: "home.promo.highAccuracy"
            )
        }
        .padding(.horizontal, 16)
    }

    private func promoCard(
        icon: String,
        iconBackground: Color,
        iconColor: Color,
        title: String,
        subtitle: String,
        identifier: String
    ) -> some View {
        Button {
            // TODO(P00-S01)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(iconBackground)
                    )
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(CCColor.textPrimary)
                    .padding(.top, 14)
                Text(subtitle)
                    .font(CCFont.secondary)
                    .foregroundStyle(CCColor.textSecondary)
                    .padding(.top, 3)
                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 123, maxHeight: 123, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(CCColor.sheet)
            )
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel("\(title), \(subtitle)")
    }

    // MARK: Sheet

    private var digitalCardSection: some View {
        VStack(spacing: 0) {
            Text("My Digital Card")
                .font(CCFont.sectionTitle)
                .foregroundStyle(CCColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("placeholder.home")
                .padding(.top, 18)

            // Illustration is an SF Symbol: CamCard artwork is not copied.
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 64))
                .foregroundStyle(CCColor.textSecondary)
                .padding(.top, 120)

            // Two lines broken after "yet." with one accessibility string (design D4).
            VStack(spacing: 0) {
                Text("No cards yet.")
                Text("Create a new one!")
            }
            .font(CCFont.row)
            .foregroundStyle(CCColor.textSecondary)
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("No cards yet. Create a new one!")
            .accessibilityAddTraits(.isStaticText)
            .padding(.top, 40)

            NavigationLink(value: AppRoute.createCard(step: 1)) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Create New Card")
                }
                .font(.system(size: 17))
                .foregroundStyle(CCColor.textPrimary)
                .frame(width: 198, height: 47)
                .background(
                    Capsule()
                        .fill(CCColor.sheet)
                        .overlay(Capsule().stroke(Color(hex: "#E2E2E2"), lineWidth: 1))
                )
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.digitalCard.create")
            .accessibilityLabel("Create New Card")
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .appRoutes()
    }
}
