import SwiftUI

/// P17-S01 Recommend CamCard. Artwork is replaced by SF Symbols (design D7); nothing is shared.
struct SettingsInviteFriendsView: View {
    private let blue = Color(hex: "#3A7CF7")
    private let tiles = [("15 days", "invited 1"), ("30 days", "invited 2"), ("180 days", "invited 12"), ("360 days", "invited 24")]

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                VStack(spacing: 6) {
                    ZStack {
                        Circle().fill(SettingsStyle.premiumCircle)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(CCColor.color(.premiumGradientEnd))
                    }
                    .frame(width: 96, height: 96)
                    Text("Invite Friends")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color(hex: "#F5E27A"))
                    Text("Invite friends & get up to 12 months Premium membership")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                }
                .padding(.top, 30)

                card

                Text("The registration of the same device, the same mobile phone number or the same email address is regarded as a reward. CamCard reserves the right to interpret this event.")
                    .font(CCFont.secondary)
                    .foregroundStyle(Color(hex: "#C9C9C9"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 14)
                    .padding(.bottom, 150)
            }
            .frame(maxWidth: .infinity)
            .background(alignment: .top) {
                blue.frame(height: 259)
            }
        }
        .background(Color.white)
        .safeAreaInset(edge: .bottom, spacing: 0) { shareBar }
        .ccPushedNavigationBar(title: "Recommend CamCard")
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("settings.page.inviteFriends")
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Get a 15-day Premium membership after new user register, up to a maximum of 12 months.")
                .font(CCFont.secondary)
                .foregroundStyle(Color(hex: "#A0A0A0"))
            HStack(spacing: 8) {
                ForEach(tiles, id: \.0) { tile in
                    VStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(CCColor.color(.premiumGradientEnd))
                        Text(tile.0)
                            .font(CCFont.secondary)
                            .foregroundStyle(CCColor.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 78)
                    .background(RoundedRectangle(cornerRadius: 12).fill(CCColor.groupedCard))
                }
            }
            VStack(spacing: 6) {
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "#E7F4FD")).frame(height: 5)
                    Circle()
                        .strokeBorder(CCColor.accent, lineWidth: 4)
                        .background(Circle().fill(.white))
                        .frame(width: 16, height: 16)
                }
                HStack(spacing: 0) {
                    ForEach(tiles, id: \.1) { tile in
                        Text(tile.1)
                            .font(CCFont.secondary)
                            .foregroundStyle(CCColor.textPrimary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            Text("You haven't invited friends yet. Don't miss out on free membership!")
                .font(.system(size: 16))
                .foregroundStyle(CCColor.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Color(hex: "#E7F4FD"))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        )
        .padding(.horizontal, 15)
    }

    private var shareBar: some View {
        HStack(alignment: .top, spacing: 28) {
            shareButton("facebook", id: "facebook") {
                Text("f").font(.system(size: 28, weight: .bold)).foregroundStyle(Color(hex: "#3B5998"))
            }
            shareButton("sms", id: "sms") {
                Image(systemName: "ellipsis.message.fill").font(.system(size: 24)).foregroundStyle(Color(hex: "#6D86E8"))
            }
            shareButton("email", id: "email") {
                Image(systemName: "envelope.fill").font(.system(size: 24)).foregroundStyle(Color(hex: "#F29A4A"))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 18, topTrailingRadius: 18)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 6, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func shareButton<Icon: View>(_ title: String, id: String, @ViewBuilder icon: () -> Icon) -> some View {
        Button {
            // TODO(P17-S01): sharing and invitations are out of scope.
        } label: {
            VStack(spacing: 8) {
                icon()
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(.white))
                    .overlay(Circle().stroke(CCColor.groupedBackground, lineWidth: 1))
                Text(title)
                    .font(CCFont.secondary)
                    .foregroundStyle(CCColor.textPrimary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("settings.invite.\(id)")
        .accessibilityLabel(title)
    }
}
