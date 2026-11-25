import SwiftUI

/// P21-S01 Upgrade Plans. Selection is fixed; nothing is purchased.
struct UpgradePlansView: View {
    private struct Plan: Identifiable {
        let id: String
        let amount: String
        let unit: String
        let perMonth: String
        let price: String
        var trial: String?
        var selected = false
    }

    private let plans = [
        Plan(id: "1", amount: "1", unit: "Month", perMonth: "$9.99/mo", price: "$9.99"),
        Plan(id: "12", amount: "12", unit: "Months", perMonth: "$4.17/mo", price: "$49.99",
             trial: "3-day Free Trial", selected: true),
        Plan(id: "36", amount: "36", unit: "Months", perMonth: "$3.05/mo", price: "$109.99")
    ]

    private let orange = Color(hex: "#F1A86E")
    private let proPurple = Color(hex: "#AF71F1")
    private let premiumBrown = Color(hex: "#A76B40")

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                tabs
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        ForEach(plans) { planTile($0) }
                    }
                    .padding(.top, 14)
                    Text("Free for 3 days,then $49.99 per year.Cancel anytime.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(hex: "#A8A8A8"))
                    featureTable
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 110)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#F7F5F5"))
            }
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "#FDF5DC"), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .safeAreaInset(edge: .bottom, spacing: 0) { continueBar }
        .ccPushedNavigationBar(title: "")
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Upgrade Plans")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CCColor.textPrimary)
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("settings.page.paywall")
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Business Card Scanner")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(CCColor.textPrimary)
                Text("Unlimited paper business card transcriptions")
                    .font(.system(size: 17))
                    .foregroundStyle(CCColor.textSecondary)
            }
            .padding(.top, 62)
            .frame(maxWidth: .infinity, alignment: .leading)
            phoneMockup
        }
        .padding(.leading, 15)
        .frame(height: 230, alignment: .top)
        .clipped()
    }

    /// D7 stand-in for the phone artwork: a dark rounded rectangle with a white card shape.
    private var phoneMockup: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 26).fill(Color(hex: "#2B2B2B"))
            RoundedRectangle(cornerRadius: 6)
                .fill(.white)
                .frame(width: 112, height: 70)
                .padding(.top, 70)
            HStack(spacing: 6) {
                Capsule().fill(.white).frame(width: 16, height: 6)
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6)
                }
            }
            .padding(.top, 170)
        }
        .frame(width: 150, height: 300)
        .padding(.top, 36)
        .padding(.trailing, 30)
    }

    private var tabs: some View {
        HStack(spacing: 0) {
            Button {
                // TODO(P21-S01): tab switching is out of scope; Premium stays selected.
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill").font(.system(size: 18))
                    Text("PRO").font(.system(size: 24, weight: .bold))
                }
                .foregroundStyle(proPurple)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "#F4EFFB"))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings.paywall.tab.pro")
            .accessibilityLabel("PRO")
            Button {
                // TODO(P21-S01): tab switching is out of scope.
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill").font(.system(size: 18))
                    Text("Premium").font(.system(size: 26, weight: .bold))
                }
                .foregroundStyle(premiumBrown)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "#F7F5F5"))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings.paywall.tab.premium")
            .accessibilityLabel("Premium")
            .accessibilityValue("Selected")
        }
    }

    private func planTile(_ plan: Plan) -> some View {
        Button {
            // TODO(P21-S01): plan selection is out of scope; the 12 Months plan stays selected.
        } label: {
            VStack(spacing: 0) {
                if let trial = plan.trial {
                    Text(trial)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 22)
                        .background(orange)
                } else {
                    Spacer().frame(height: 0)
                }
                VStack(spacing: 2) {
                    Text(plan.amount).font(.system(size: 26, weight: .bold))
                    Text(plan.unit).font(.system(size: 17))
                    Text(plan.perMonth)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#ABABAB"))
                        .padding(.top, 6)
                    Text(plan.price).font(.system(size: 20, weight: .bold)).padding(.top, 8)
                }
                .foregroundStyle(CCColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: plan.trial == nil ? 140 : 118)
            }
            .frame(maxWidth: .infinity)
            .background(
                plan.selected
                    ? AnyShapeStyle(LinearGradient(colors: [.white, Color(hex: "#FDEBD3")], startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(Color.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(plan.selected ? orange : Color.clear, lineWidth: 2)
            )
            .padding(.top, plan.trial == nil ? 0 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("settings.paywall.plan.\(plan.id)")
        .accessibilityLabel(
            ["\(plan.amount) \(plan.unit)", plan.perMonth, plan.price, plan.trial]
                .compactMap { $0 }
                .joined(separator: ", ")
        )
        .accessibilityValue(plan.selected ? "Selected" : "")
    }

    private var featureTable: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("Feature")
                    .font(CCFont.row)
                    .foregroundStyle(Color(hex: "#7A7A7A"))
                    .padding(.leading, 18)
                    .frame(width: 140, alignment: .leading)
                    .frame(maxHeight: .infinity)
                    .background(Color.white)
                HStack(spacing: 6) {
                    Image(systemName: "diamond.fill").font(.system(size: 14))
                    Text("Pro").font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(proPurple)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#F3E9FC"))
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill").font(.system(size: 14))
                    Text("Premium").font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(Color(hex: "#8A6420"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#FDF1D2"))
            }
            .frame(height: 64)
            Text("AI Scanner")
                .font(CCFont.row)
                .foregroundStyle(CCColor.textPrimary)
                .padding(.leading, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 62)
                .background(Color.white)
                .overlay(alignment: .top) { Rectangle().fill(Color(hex: "#EFEFEF")).frame(height: 1) }
            // TODO(P21-S01): rows and columns below and right of the captured area were not captured.
            HStack(spacing: 0) {
                Text("Business Card Scanner")
                    .font(CCFont.secondary)
                    .foregroundStyle(Color(hex: "#7A7A7A"))
                    .padding(.leading, 18)
                    .frame(width: 140, alignment: .leading)
                    .frame(maxHeight: .infinity)
                    .background(Color.white)
                Text("Unlimited")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(proPurple)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "#F3E9FC"))
                Text("Unlimited")
                    .font(CCFont.row)
                    .foregroundStyle(Color(hex: "#7A7A7A"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(hex: "#FDF1D2"))
            }
            .frame(height: 62)
            .overlay(alignment: .top) { Rectangle().fill(Color(hex: "#EFEFEF")).frame(height: 1) }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var continueBar: some View {
        Button {
            // TODO(P21-S01): purchasing is out of scope.
        } label: {
            Text("Continue")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [Color(hex: "#F8D894"), Color(hex: "#D59137")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 15)
        .padding(.top, 16)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                .fill(.white)
                .ignoresSafeArea(edges: .bottom)
        )
        .accessibilityIdentifier("settings.paywall.continue")
        .accessibilityLabel("Continue")
    }
}
