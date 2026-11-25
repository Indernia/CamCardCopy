import SwiftUI
import UIKit

struct EditCardView: View {
    let image: ScannedCardImage
    let saver: CardSaver
    let onRetake: () -> Void
    let onSaved: (CardRecord) -> Void

    @State private var thumbnail: UIImage?
    @State private var isSaving = false
    @State private var showsSaveError = false
    @State private var name: String
    @State private var company: String
    @State private var jobTitle: String
    @State private var mobile: String
    @State private var phone: String
    @State private var email: String
    @State private var website: String
    @State private var address: String
    @State private var extraPhones: [String]
    @State private var extraEmails: [String]

    init(
        image: ScannedCardImage,
        saver: CardSaver,
        onRetake: @escaping () -> Void,
        onSaved: @escaping (CardRecord) -> Void
    ) {
        self.image = image
        self.saver = saver
        self.onRetake = onRetake
        self.onSaved = onSaved

        // Rows are seeded from the recognized fields and then live in local
        // state; editing never writes back to the recognized raw text or store.
        let fields = image.recognized?.fields ?? CardFields()
        _name = State(initialValue: fields.name ?? "")
        _company = State(initialValue: fields.company ?? "")
        _jobTitle = State(initialValue: fields.jobTitle ?? "")
        _mobile = State(initialValue: fields.mobile ?? "")
        _phone = State(initialValue: fields.phone ?? "")
        _email = State(initialValue: fields.email ?? "")
        _website = State(initialValue: fields.website ?? "")
        _address = State(initialValue: fields.address ?? "")
        _extraPhones = State(initialValue: fields.extraPhones)
        _extraEmails = State(initialValue: fields.extraEmails)
    }

    var body: some View {
        VStack(spacing: 16) {
            cardImage
            ScrollView {
                VStack(spacing: 0) {
                    fieldRow("Full Name", text: $name, identifier: "editCard.fullName")
                    rowDivider
                    fieldRow("Company", text: $company, identifier: "editCard.company")
                    rowDivider
                    fieldRow("Job Title", text: $jobTitle, identifier: "editCard.jobTitle")
                    rowDivider
                    fieldRow("Mobile", text: $mobile, identifier: "editCard.mobile")
                    rowDivider
                    fieldRow("Phone", text: $phone, identifier: "editCard.phone")
                    ForEach(extraPhones.indices, id: \.self) { index in
                        rowDivider
                        fieldRow(
                            "Phone",
                            text: extraPhoneBinding(index),
                            identifier: "editCard.extraPhone.\(index)"
                        )
                    }
                    rowDivider
                    fieldRow("Email", text: $email, identifier: "editCard.email")
                    ForEach(extraEmails.indices, id: \.self) { index in
                        rowDivider
                        fieldRow(
                            "Email",
                            text: extraEmailBinding(index),
                            identifier: "editCard.extraEmail.\(index)"
                        )
                    }
                    rowDivider
                    fieldRow("Website", text: $website, identifier: "editCard.website")
                    rowDivider
                    fieldRow("Address", text: $address, identifier: "editCard.address")
                }
            }
        }
        .padding()
        .navigationTitle("Edit Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Retake", action: onRetake)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .disabled(isSaving)
            }
        }
        .alert("Couldn't save card", isPresented: $showsSaveError) {
            Button("OK", role: .cancel) {}
        }
        .task(id: image) {
            // Decode once, off the main actor, at display size. Decoding the
            // full-resolution capture in body blocks the navigation push.
            thumbnail = await CardImageThumbnail.make(
                from: image.processedImage ?? image.originalImage
            )
        }
    }

    private var cardImage: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
            } else {
                Color(white: 0.2)
                    .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var rowDivider: some View {
        Divider()
    }

    private func fieldRow(
        _ label: String,
        text: Binding<String>,
        identifier: String
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 88, alignment: .leading)
            TextField("", text: text)
                .textFieldStyle(.plain)
                .accessibilityIdentifier(identifier)
                .accessibilityLabel(label)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }

    private func extraPhoneBinding(_ index: Int) -> Binding<String> {
        Binding(
            get: { extraPhones[index] },
            set: { extraPhones[index] = $0 }
        )
    }

    private func extraEmailBinding(_ index: Int) -> Binding<String> {
        Binding(
            get: { extraEmails[index] },
            set: { extraEmails[index] = $0 }
        )
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true

        let values = EditedCardValues(
            name: name,
            company: company,
            jobTitle: jobTitle,
            mobile: mobile,
            phone: phone,
            email: email,
            website: website,
            address: address,
            extraPhones: extraPhones,
            extraEmails: extraEmails
        )

        do {
            let record = try saver.save(image: image, values: values)
            isSaving = false
            onSaved(record)
        } catch {
            isSaving = false
            showsSaveError = true
        }
    }
}
