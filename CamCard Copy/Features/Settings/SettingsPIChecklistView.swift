import SwiftUI

/// P19-S01 Personal information collection checklist: a read-only bordered table.
struct SettingsPIChecklistView: View {
    private let tableTitle = "CamCard App Collect personal information list"
    private let border = Color(hex: "#E1E1E1")
    private let rows: [[String]] = [
        ["Registration and login",
         "Mobile phone number, verification code, email, login password",
         "Used for registration, account creation, and login"],
        ["Third party account login",
         "Third party account",
         "For situations where third-party accounts are used to authorize login"],
        ["One click login",
         "Mobile card number, operator type, WIFI information",
         "Quickly register mobile phone numbers through nearby base stations"],
        ["Business card scanning, storage, reading, and management",
         "Active shooting or selection of business card information and clipboard content",
         "Used to assist you in reading, editing, and managing business cards"],
        ["OCR recognition",
         "User entered business card image",
         "Used for business card content recognition"],
        ["Address book import Network analysis",
         "Address book contact information",
         // TODO(P19-S01): this cell and the rows after it were cut off in the capture.
         "Used to save recognized business card information to contacts and network analysis"]
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 1) {
                Text(tableTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: "#222222"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 12)
                    .background(Color(hex: "#F7F7F7"))
                tableRow(
                    ["Scenario/Business Function", "Types of personal information", "Objective"],
                    bold: true, fill: Color(hex: "#F7F7F7")
                )
                ForEach(rows, id: \.self) { row in
                    tableRow(row, bold: false, fill: .white)
                }
            }
            .padding(1)
            .background(border)
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .ccPushedNavigationBar(title: tableTitle)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("settings.page.piChecklist")
    }

    private func tableRow(_ cells: [String], bold: Bool, fill: Color) -> some View {
        HStack(spacing: 1) {
            ForEach(cells, id: \.self) { cell in
                Text(cell)
                    .font(.system(size: 15, weight: bold ? .bold : .regular))
                    .foregroundStyle(bold ? Color(hex: "#222222") : Color(hex: "#666666"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(fill)
            }
        }
    }
}
