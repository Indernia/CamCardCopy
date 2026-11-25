import Foundation

/// Deterministic raw text -> card fields.
///
/// The parser uses only generic conventions: contact labels, email/URL/phone
/// shapes, address words, a role lexicon and reading-order position. It contains
/// no names, companies, domains or other literal values from `reference/`.
nonisolated struct CardFieldParser: Sendable {
    func parse(_ rawText: String) -> CardFields {
        var fields = CardFields()
        var pendingLabel: Label?
        var unlabelledPhones: [String] = []
        var textCandidates: [String] = []

        let lines = rawText
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for line in lines {
            let emails = Self.matches(Self.emailPattern, in: line)
            var remaining = line
            for email in emails {
                remaining = remaining.replacingOccurrences(of: email, with: " ")
            }
            let urls = Self.matches(Self.urlPattern, in: remaining)
            for url in urls {
                remaining = remaining.replacingOccurrences(of: url, with: " ")
            }
            let phones = Self.phoneNumbers(in: remaining)
            let hadContact = !emails.isEmpty || !urls.isEmpty || !phones.isEmpty

            if let firstURL = urls.first, fields.website == nil {
                fields.website = firstURL
            }
            for email in emails {
                if fields.email == nil {
                    fields.email = email
                } else {
                    fields.extraEmails.append(email)
                }
            }

            for (index, phone) in phones.enumerated() {
                let prefix = Self.prefix(of: phone, in: remaining)
                let label = index == 0 ? (Self.label(in: prefix) ?? pendingLabel) : Self.label(in: prefix)
                switch label {
                case .mobile:
                    if fields.mobile == nil {
                        fields.mobile = phone
                    } else {
                        fields.extraPhones.append(phone)
                    }
                case .phone:
                    if fields.phone == nil {
                        fields.phone = phone
                    } else {
                        fields.extraPhones.append(phone)
                    }
                case .fax:
                    break
                case .email, .website, .address, .name, .company, .jobTitle, .none:
                    unlabelledPhones.append(phone)
                }
            }

            if hadContact {
                pendingLabel = nil
                continue
            }

            if let label = Self.labelOnly(in: line) {
                pendingLabel = label
                continue
            }

            if Self.isAddress(line) {
                if fields.address == nil {
                    fields.address = Self.strippingAddressLabel(from: line)
                }
                continue
            }

            textCandidates.append(line)
        }

        Self.assignUnlabelledPhones(unlabelledPhones, to: &fields)
        Self.assignTextFields(from: textCandidates, to: &fields)
        return fields
    }
}

// MARK: - Field classification

private extension CardFieldParser {
    enum Label {
        case mobile, phone, fax, email, website, address, name, company, jobTitle
    }

    static func assignUnlabelledPhones(_ phones: [String], to fields: inout CardFields) {
        guard !phones.isEmpty else { return }

        if fields.mobile == nil, fields.phone == nil {
            if phones.count == 1 {
                fields.phone = phones[0]
            } else {
                fields.mobile = phones[0]
                fields.phone = phones[1]
                fields.extraPhones.append(contentsOf: phones.dropFirst(2))
            }
        } else if fields.mobile == nil {
            fields.mobile = phones[0]
            fields.extraPhones.append(contentsOf: phones.dropFirst())
        } else if fields.phone == nil {
            fields.phone = phones[0]
            fields.extraPhones.append(contentsOf: phones.dropFirst())
        } else {
            fields.extraPhones.append(contentsOf: phones)
        }
    }

    static func assignTextFields(from candidates: [String], to fields: inout CardFields) {
        guard !candidates.isEmpty else { return }

        var titleIndex: Int?
        var bestScore = 0
        for (index, line) in candidates.enumerated() {
            let score = roleScore(line)
            if score > bestScore {
                bestScore = score
                titleIndex = index
            }
        }

        var nameIndex: Int?
        if let titleIndex {
            for index in stride(from: titleIndex - 1, through: 0, by: -1) where index >= 0 {
                if looksLikePersonName(candidates[index]) {
                    nameIndex = index
                    break
                }
            }
        }
        if nameIndex == nil {
            nameIndex = candidates.indices.first { looksLikePersonName(candidates[$0]) }
        }

        if let nameIndex {
            fields.name = candidates[nameIndex]
        }
        if let titleIndex {
            fields.jobTitle = candidates[titleIndex]
        }

        let companyLines = candidates.enumerated()
            .filter { $0.offset != nameIndex && $0.offset != titleIndex }
            .map(\.element)
        if !companyLines.isEmpty {
            fields.company = canonicalCompany(companyLines.joined(separator: " "))
        }
    }

    static func roleScore(_ line: String) -> Int {
        let tokens = line.lowercased()
            .split(whereSeparator: { !$0.isLetter && $0 != "-" })
            .map(String.init)
        return tokens.filter(roleWords.contains).count
    }

    static func looksLikePersonName(_ line: String) -> Bool {
        let tokens = line.split(separator: " ").map(String.init)
        guard (2...4).contains(tokens.count) else { return false }
        guard !line.contains(where: \.isNumber) else { return false }
        // All-uppercase lines look like wordmarks or company names, not people.
        guard !tokens.allSatisfy({ token in token.allSatisfy { !$0.isLowercase } }) else {
            return false
        }

        for token in tokens {
            guard let first = token.first, first.isUppercase else { return false }
            let body = token.dropFirst()
            guard body.allSatisfy({ $0.isLetter || $0 == "-" || $0 == "'" || $0 == "’" }) else {
                return false
            }
            let lowered = token.lowercased()
            guard !companySuffixWords.contains(lowered) else { return false }
            guard !roleWords.contains(lowered) else { return false }
        }
        return true
    }

    static func canonicalCompany(_ line: String) -> String {
        collapse(line)
            .split(separator: " ")
            .map { token -> String in
                let string = String(token)
                // Wordmarks are often printed in all caps; canonicalize those to
                // title case so they compare with normal company names.
                guard string.count >= 4, string.allSatisfy({ !$0.isLowercase }) else {
                    return string
                }
                return String(string.prefix(1)) + string.dropFirst().lowercased()
            }
            .joined(separator: " ")
    }
}

// MARK: - Labels and line shapes

private extension CardFieldParser {
    static func label(in prefix: String) -> Label? {
        let tokens = prefix.lowercased()
            .split(whereSeparator: { !$0.isLetter && $0 != "-" })
            .map(String.init)
        for token in tokens.reversed() {
            switch token {
            case "mobile", "cell", "m":
                return .mobile
            case "tel", "telephone", "phone", "office", "work", "t", "o", "p":
                return .phone
            case "fax", "f":
                return .fax
            case "email", "e-mail", "e":
                return .email
            case "website", "web", "url", "w":
                return .website
            case "address", "addr":
                return .address
            case "name":
                return .name
            case "company":
                return .company
            case "title", "job":
                return .jobTitle
            default:
                continue
            }
        }
        return nil
    }

    static func labelOnly(in line: String) -> Label? {
        let pattern = #"(?i)^\s*(mobile|cell|telephone|tel|phone|office|work|fax|email|e-mail|website|web|url|address|addr|name|company|job\s+title|title|m|t|o|p|f|e|w)\s*[:：]?\s*$"#
        guard !matches(pattern, in: line).isEmpty else { return nil }
        return label(in: line)
    }

    static func isAddress(_ line: String) -> Bool {
        let tokens = line.lowercased()
            .split(whereSeparator: { !$0.isLetter })
            .map(String.init)
        if tokens.contains(where: addressKeywords.contains) {
            return true
        }
        if line.range(of: #"\b\d{5}(-\d{4})?\b"#, options: .regularExpression) != nil {
            return true
        }
        if line.range(of: #"\b[A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{2}\b"#, options: .regularExpression) != nil {
            return true
        }
        return false
    }

    static func strippingAddressLabel(from line: String) -> String {
        let collapsed = collapse(line)
        if let range = collapsed.range(
            of: #"^\s*(address|addr)\s*[:：]\s*"#,
            options: [.regularExpression, .caseInsensitive]
        ) {
            return String(collapsed[range.upperBound...])
        }
        return collapsed
    }
}

// MARK: - Text helpers

private extension CardFieldParser {
    static let emailPattern = #"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}"#
    static let urlPattern = #"(?i)(?:https?://)?(?:www\.)?[a-z0-9](?:[a-z0-9\-]*[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9\-]*[a-z0-9])?)+"#
    static let phonePattern = #"(?:\+?\d[\d\-().\s]{6,}\d)"#

    static func matches(_ pattern: String, in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            Range(match.range, in: text).map { String(text[$0]) }
        }
    }

    static func phoneNumbers(in text: String) -> [String] {
        matches(phonePattern, in: text).filter { $0.filter(\.isNumber).count >= 8 }
    }

    static func prefix(of value: String, in text: String) -> String {
        guard let range = text.range(of: value) else { return "" }
        return String(text[..<range.lowerBound])
    }

    static func collapse(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }

    static let roleWords: Set<String> = [
        "designer", "electrician", "procurement", "officer", "photographer",
        "manager", "director", "engineer", "consultant", "specialist",
        "coordinator", "analyst", "technician", "executive", "assistant",
        "representative", "supervisor", "advisor", "architect", "accountant",
        "attorney", "developer", "scientist", "president", "founder", "partner",
        "administrator", "strategist", "producer", "editor", "writer", "artist",
        "chef", "therapist", "realtor", "broker", "surveyor", "inspector",
        "estimator", "buyer", "planner", "recruiter", "marketer", "nurse",
        "teacher", "professor", "head", "chief", "agent"
    ]

    static let companySuffixWords: Set<String> = [
        "ltd", "llc", "inc", "corp", "co", "company", "group", "studio", "studios",
        "agency", "analytics", "partners", "consulting", "solutions", "services",
        "technologies", "technology", "systems", "holdings", "enterprises",
        "industries", "associates", "ventures", "labs", "media", "creative",
        "productions", "logistics", "freight", "electric", "electricians",
        "plumbing", "construction", "engineering", "accounting", "marketing",
        "law", "legal", "capital", "finance", "insurance", "realty", "properties",
        "clinic", "medical", "dental", "care", "hospital", "university", "college",
        "school", "institute", "foundation", "association", "council",
        "department", "bureau", "center", "centre", "restaurant", "hotel",
        "travel", "fitness", "salon", "spa", "gallery", "design", "architecture",
        "surveying", "printing", "publishing", "shipping", "supply", "trading",
        "imports", "exports", "manufacturing", "distribution", "transport",
        "security", "builders", "contractors"
    ]

    static let addressKeywords: Set<String> = [
        "street", "road", "avenue", "lane", "way", "boulevard", "drive", "court",
        "place", "plaza", "terrace", "highway", "parkway", "square", "suite",
        "building", "unit", "floor", "apt", "apartment"
    ]
}
