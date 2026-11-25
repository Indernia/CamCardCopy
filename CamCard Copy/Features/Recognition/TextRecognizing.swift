import Foundation

/// One card field set parsed from recognized text.
///
/// `extraPhones`/`extraEmails` exist only in memory: `BusinessCard` has a single
/// phone and a single email, so the save change decides whether to extend the
/// model or drop these extras.
nonisolated struct CardFields: Hashable, Sendable {
    var name: String? = nil
    var company: String? = nil
    var jobTitle: String? = nil
    var mobile: String? = nil
    var phone: String? = nil
    var email: String? = nil
    var website: String? = nil
    var address: String? = nil
    var extraPhones: [String] = []
    var extraEmails: [String] = []
}

/// The recognizer output plus the fields parsed from it. `rawText` is never mutated.
nonisolated struct RecognizedCard: Hashable, Sendable {
    let rawText: String
    let fields: CardFields
}

/// On-device text recognition. Implementations must not touch the network.
nonisolated protocol TextRecognizing: Sendable {
    func recognizeText(in imageData: Data) async throws -> String
}
