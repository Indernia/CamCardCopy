# Spec Delta

## Purpose

Recognizes the text on a captured or imported business card on device and turns it into editable contact fields, so Edit Card arrives pre-filled instead of blank.

## ADDED Requirements

### Requirement: On-device text recognition

After a card image is captured or imported, the system SHALL recognize its text on device using an accurate, English text recognizer, off the main actor. The system SHALL recognize the corrected card image when detection produced one, otherwise the original image.

#### Scenario: T07 — Recognition runs on the corrected image

- **WHEN** a capture produced a perspective-corrected card image
- **THEN** recognition runs on the corrected image and returns the recognized text

#### Scenario: T07 — Recognition falls back to the original image

- **WHEN** the user continued saving without a detected card area
- **THEN** recognition runs on the original, uncropped image and returns the recognized text

#### Scenario: T07 — Recognition never blocks the main actor (manual check 5.2)

- **WHEN** recognition is running
- **THEN** the camera, Edit Card and tab UI remain responsive

### Requirement: Recognition progress state (P04-S02, ASSUMPTION)

While recognition runs, the system SHALL show a progress state instead of appearing frozen. P04-S02 is not captured, so the exact presentation is ASSUMPTION; it SHALL at minimum show a spinner with the text "Recognizing…" (T07).

#### Scenario: T07 — Progress is visible during recognition

- **WHEN** recognition starts after a capture or import
- **THEN** a spinner with "Recognizing…" is shown until recognition completes or fails

### Requirement: Recognition failure state (P04-S03, ASSUMPTION)

When recognition fails or returns no text, the system SHALL open Edit Card with all fields empty and the raw recognized text empty, instead of showing an error or fabricating fields. P04-S03 is not captured, so this fallback behavior is ASSUMPTION (T20).

#### Scenario: T20 — Failure opens an empty Edit Card

- **WHEN** recognition fails or returns no text
- **THEN** Edit Card opens with empty fields and the user is not blocked

### Requirement: Raw recognized text is preserved

The system SHALL keep the raw recognized text, unchanged, alongside the card images. Field parsing SHALL read the raw text but never modify it (project hard rule).

#### Scenario: T07 — Raw text survives parsing

- **WHEN** the parser maps raw text to fields
- **THEN** the raw recognized text remains byte-identical to the recognizer output

### Requirement: Parse recognized text into card fields

The system SHALL parse the raw text into `name`, `company`, `jobTitle`, `mobile`, `phone`, `email`, `website` and `address` using observed business-card layout conventions (T07, T08, T10).

#### Scenario: T07 — Standard fields are parsed

- **WHEN** a card's raw text contains a name, company, job title, one mobile, one phone, one email, one website and one address
- **THEN** each value lands in its matching field

#### Scenario: T08 — Labelled values win over guesses

- **WHEN** a phone number or email carries a label such as "Mobile", "Tel", "Email" or "E-mail"
- **THEN** the labelled value is placed in the labelled field

### Requirement: Never fabricate a field (T09)

The system SHALL NOT fill a field whose value is absent from the raw text, including not deriving a website or company from an email domain. An absent value stays empty.

#### Scenario: T09 — Missing website stays empty

- **WHEN** the raw text has no website line
- **THEN** the website field is empty, even if an email domain exists

#### Scenario: T09 — Missing company stays empty

- **WHEN** the raw text has no company line
- **THEN** the company field is empty and never copied from another field

### Requirement: Multiple phones and emails (T10)

As observed (P05-S05, ASSUMPTION — not captured), the system SHALL keep multiple phone numbers and multiple email addresses from one card. A number labelled as fax SHALL NOT be placed in `mobile` or `phone` (T10).

#### Scenario: T10 — Two emails are kept

- **WHEN** the raw text contains two email addresses
- **THEN** both are kept and the first becomes the primary `email`

#### Scenario: T10 — Fax is excluded

- **WHEN** the raw text contains a number labelled "Fax"
- **THEN** that number appears in neither `mobile` nor `phone`

### Requirement: Edit Card shows recognized fields (P05-S02, ASSUMPTION)

Edit Card SHALL show the recognized fields in place of the empty shell: "Full Name", "Company", "Job Title", "Mobile", "Phone", "Email", "Website", "Address", each with its recognized value or empty when unrecognized. P05-S02 is not captured, so row order beyond "Full Name" first is ASSUMPTION. Save stays disabled.

#### Scenario: T07 — Recognized card pre-fills Edit Card

- **WHEN** recognition parsed values from the card
- **THEN** Edit Card shows each parsed value in its field row and "Full Name" remains the first row

#### Scenario: T09 — Unrecognized values stay empty

- **WHEN** recognition could not parse a value for a field
- **THEN** that row shows its label with an empty value and no placeholder text is invented

### Requirement: Recognized fields are editable (P05-S03, ASSUMPTION)

Each recognized field on Edit Card SHALL be editable in place, including clearing a value back to empty. P05-S03 is not captured, so the exact editing affordance is ASSUMPTION (T11). Editing does not save; Save stays disabled.

#### Scenario: T11 — Edit a recognized value

- **WHEN** the user edits the "Full Name" value on Edit Card
- **THEN** the row shows the edited value

#### Scenario: T11 — Clear a recognized value

- **WHEN** the user clears a field's value
- **THEN** the row shows an empty value and no crash occurs

### Requirement: Recognition test fixtures and hooks

`reference/dataset/*.png` and `*-photo.jpg` with `reference/ground-truth.json` SHALL be the accuracy fixtures for T07–T10. A DEBUG launch hook SHALL feed a chosen dataset image through the real recognizer for UI tests; production code paths stay unchanged and no test touches the network.

#### Scenario: T07/T08/T09/T10 — End-to-end accuracy on the dataset

- **WHEN** the recognizer runs on each dataset image
- **THEN** the parsed fields are compared per field against the ground truth and mismatches are reported

#### Scenario: T07 — UI test uses the recognition hook

- **WHEN** the app launches with the DEBUG recognition hook
- **THEN** the capture flow runs the real recognizer on the hooked dataset image and Edit Card shows its parsed fields
