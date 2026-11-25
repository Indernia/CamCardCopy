# Spec Delta

## MODIFIED Requirements

### Requirement: Card record fields

A saved card SHALL store originalImage, processedImage, rawOCRText, name, company, jobTitle, mobile, phone, email, website, address, extraPhones, extraEmails, groups, notes and createdAt, plus a stable identifier. groups SHALL reference stored group records. Nullable text fields SHALL round-trip nil as nil; storage SHALL NOT turn nil into an empty string, placeholder text or default value. extraPhones and extraEmails SHALL round-trip as ordered collections that default to empty. rawOCRText SHALL be preserved verbatim as separate data.

#### Scenario: T18-U1 — Create stores every field

- **WHEN** a card is created with image data, raw OCR text, parsed values, additional phones and emails, and group records
- **THEN** fetching it by identifier returns the same values

#### Scenario: T18-U1 — Absent fields stay nil

- **WHEN** a card is created without a website or address
- **THEN** the fetched card has nil for those fields
- **AND** storage substitutes no empty string, placeholder text or default value

#### Scenario: T10 — Additional phones and emails round-trip in order

- **WHEN** a card is created with more than one phone and more than one email
- **THEN** the fetched card returns the additional values as separate collections in their original order
- **AND** the primary mobile/phone and email remain distinct from the additional values

#### Scenario: T10 — Additional values are empty when none exist

- **WHEN** a card is created with only primary contact values
- **THEN** the fetched card's additional phone and email collections are empty
- **AND** no value is fabricated to fill them

#### Scenario: T18-U1 — Existing stored cards read back with empty collections

- **WHEN** a card stored before this model change is fetched
- **THEN** its additional phone and email collections are empty
- **AND** its existing fields and images are unchanged
- **AND** the migration-safe default creates no duplicate card
