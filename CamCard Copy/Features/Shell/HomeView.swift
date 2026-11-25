import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                topBar
                promoRow
                digitalCardSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .accessibilityIdentifier("home.content")
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                // TODO(P31-S01)
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.bell")
            .accessibilityLabel("Notifications")

            Button {
                // TODO(P00-S03)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    Text("Search Card Holder")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.search")
            .accessibilityLabel("Search Card Holder")

            Button {
                // TODO(P21-S01)
            } label: {
                Image(systemName: "crown.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.yellow)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.crown")
            .accessibilityLabel("Premium")

            Button {
                // TODO(P00-S01) ASSUMPTION: the stats destination was not captured
            } label: {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.stats")
            .accessibilityLabel("Stats")
        }
    }

    private var promoRow: some View {
        HStack(spacing: 12) {
            promoCard(
                icon: "mic.fill",
                iconBackground: Color.blue.opacity(0.15),
                iconColor: .blue,
                title: "Speech to Text",
                subtitle: "AI Summary",
                identifier: "home.promo.speechToText"
            )
            // TODO(P00-S01)
            promoCard(
                icon: "viewfinder",
                iconBackground: Color.purple.opacity(0.15),
                iconColor: .purple,
                title: "High Accuracy",
                subtitle: "99.99% Accuracy",
                identifier: "home.promo.highAccuracy"
            )
        }
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
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(iconBackground)
                    )
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel("\(title), \(subtitle)")
    }

    private var digitalCardSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("My Digital Card")
                .font(.headline)
                .foregroundStyle(.primary)
                .accessibilityIdentifier("placeholder.home")
                .padding(.top, 12)

            VStack(spacing: 16) {
                Image(systemName: "rectangle.on.rectangle")
                    .font(.system(size: 64, weight: .regular))
                    .foregroundStyle(.secondary)

                Text("No cards yet. Create a new one!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    // TODO(P33-S01)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Create New Card")
                    }
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(Color(.separator), lineWidth: 1)
                            .background(Capsule().fill(Color(.systemBackground)))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.digitalCard.create")
                .accessibilityLabel("Create New Card")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
}

#Preview {
    HomeView()
}
