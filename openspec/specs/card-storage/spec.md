# Card Storage Specification

## Purpose

Owns the saved business card record, its groups and timestamped notes, and the single repository contract used to create, read, update and delete cards, including on-device persistence and launch-time test configuration.

## Requirements

### Requirement: Card record fields

A saved card SHALL store originalImage, processedImage, rawOCRText, name, company, jobTitle, mobile, phone, email, website, address, groups, notes and createdAt, plus a stable identifier. groups SHALL reference stored group records. Nullable text fields SHALL round-trip nil as nil; storage SHALL NOT turn nil into an empty string, placeholder text or default value. rawOCRText SHALL be preserved verbatim as separate data.

#### Scenario: T18-U1 — Create stores every field

- **WHEN** a card is created with image data, raw OCR text, parsed values and group records
- **THEN** fetching it by identifier returns the same values

#### Scenario: T18-U1 — Absent fields stay nil

- **WHEN** a card is created without a website or address
- **THEN** the fetched card has nil for those fields
- **AND** storage substitutes no empty string, placeholder text or default value

### Requirement: Note timeline

A card SHALL own zero or more notes. Each note SHALL store its text, a timestamp and a stable identifier. Notes SHALL be returned ordered by timestamp, oldest first, so a card detail can render a timeline.

#### Scenario: T18-U2 — Notes round-trip with timestamps (ASSUMPTION ordering)

- **WHEN** a card is created with two notes added out of chronological order
- **THEN** both notes are returned with their text and timestamps
- **AND** the older note is returned first

### Requirement: Note cascade deletion

Deleting a card SHALL delete its notes. No note SHALL remain after its card is deleted.

#### Scenario: T18-U4 — Delete removes the card and its notes

- **WHEN** a card with notes is deleted
- **THEN** fetch-by-identifier returns nothing and fetch-all no longer contains the card
- **AND** no note for that card remains in the store

### Requirement: Group records

Cards and groups SHALL form a many-to-many relationship. Each group SHALL have a stable identifier and a unique name. Deleting a card SHALL NOT delete any group.

#### Scenario: T18-U5 — Card groups round-trip

- **WHEN** a card is created with group records
- **THEN** fetching the card returns the same group identifiers and names

#### Scenario: T18-U5 — Deleting a card keeps its groups

- **WHEN** a card that belongs to groups is deleted
- **THEN** the same groups are still returned by the store

### Requirement: Default "Ungrouped" group

Every store SHALL contain exactly one group named "Ungrouped". The group SHALL be ensured on every launch, including normal non-debug launches, and ensuring it again SHALL NOT create a duplicate. Group management UI, including creating and renaming groups (T16), is out of scope.

#### Scenario: T16 — "Ungrouped" exists on every launch (foundation only)

- **WHEN** the app launches against an existing store
- **THEN** exactly one group named "Ungrouped" is stored
- **WHEN** the app launches again
- **THEN** still exactly one group named "Ungrouped" is stored

### Requirement: Repository CRUD contract

All card reads and writes SHALL go through a repository contract that supports create, fetch all, fetch one by identifier, update and delete. Repository failures SHALL be reported to the caller as errors and SHALL NOT be silently discarded.

#### Scenario: T18-U1 — Create then fetch

- **WHEN** a card is created
- **THEN** fetch-all and fetch-by-identifier both return it

#### Scenario: T18-U2 — Fetching an unknown identifier returns nothing

- **WHEN** no card exists with the requested identifier
- **THEN** the repository returns no card and reports no fabricated record

#### Scenario: T18-U3 — Update persists

- **WHEN** a stored card's name is changed and updated
- **THEN** a subsequent fetch returns the new name

#### Scenario: T18-U4 — Delete removes the card

- **WHEN** a stored card is deleted
- **THEN** fetch-by-identifier returns nothing and fetch-all no longer contains it

### Requirement: Persistence across launch

Saved cards SHALL remain available after the app is terminated and launched again, using storage on the device.

#### Scenario: T18 — Saved cards survive relaunch (ASSUMPTION: list state not captured)

- **WHEN** cards exist and the app is terminated and relaunched without any reset argument
- **THEN** the same cards are available in the CardHolder list

### Requirement: Launch-time test configuration

The app SHALL accept an empty-store launch argument that removes the persistent store and any external image storage beside it, and a seed argument that inserts deterministic mock cards and groups. Seeding SHALL be idempotent: relaunching with the seed argument SHALL NOT duplicate cards or groups. Launch arguments SHALL have no effect on a normal launch.

#### Scenario: T01 — Empty-store launch argument yields an empty CardHolder

- **WHEN** the app launches with the empty-store argument after cards existed previously
- **THEN** the CardHolder screen shows "No cards"

#### Scenario: T01 — Empty-store reset removes external image storage

- **WHEN** a previous store held card images in external storage
- **THEN** launching with the empty-store argument leaves no card data and no externally stored image data behind

#### Scenario: T18 — Seed argument is idempotent across relaunch

- **WHEN** the app launches twice with the seed argument
- **THEN** the number of cards and groups is unchanged between launches
