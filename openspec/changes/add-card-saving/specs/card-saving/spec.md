# Spec Delta

## Purpose

Defines what happens when a user confirms a business card on Edit Card: the saved card's content, the auto-created first Note, the Card Saved screen and its actions, and how the saved card reaches CardHolder and card detail.

## ADDED Requirements

### Requirement: Save enables persistence from Edit Card

Edit Card SHALL offer an enabled "Save" control for every scanned or imported card, including when all rows are empty (P05-S01 shows an active Save; P05-S09 is not captured, so the empty-field behavior is ASSUMPTION). Tapping "Save" SHALL persist exactly one card through the card repository and then show the Card Saved screen. Every recognized result SHALL still pass through Edit Card before it can be saved.

#### Scenario: T11 — Save is enabled on Edit Card

- **WHEN** the flow reaches Edit Card, with or without recognized values
- **THEN** "Retake", "Edit Card" and "Save" are visible
- **AND** "Save" is enabled

#### Scenario: T11 — Edited values win over the original parse

- **WHEN** the user changes one or more rows on Edit Card and taps "Save"
- **THEN** the stored card holds the values as currently edited on screen
- **AND** the values from the original parse are not stored for the changed rows

#### Scenario: T11 — Every recognized result passes through Edit Card

- **WHEN** recognition produces fields for a captured or imported card
- **THEN** the card is not stored until the user taps "Save" on Edit Card

### Requirement: Saved card content

A saved card SHALL store `originalImage`, `processedImage` when one exists, the raw OCR text unchanged, the eight edited fields, `createdAt`, and exactly one group named "Ungrouped". A field left empty on Edit Card SHALL be stored as nil; storage SHALL NOT substitute an empty string, placeholder text or fabricated value.

#### Scenario: T11 — All edited fields are persisted

- **WHEN** a save completes
- **THEN** `name`, `company`, `jobTitle`, `mobile`, `phone`, `email`, `website` and `address` hold the edited values
- **AND** empty rows are stored as nil

#### Scenario: T11 — Raw OCR text is preserved verbatim

- **WHEN** the user edits one or more rows and saves
- **THEN** the stored raw OCR text equals the recognition result unchanged
- **AND** the edited values do not overwrite the raw OCR text

#### Scenario: T11 — Original and corrected images are stored separately

- **WHEN** the card was captured with a corrected image
- **THEN** the stored `originalImage` is the uncorrected capture
- **AND** the stored `processedImage` is the corrected image
- **WHEN** no corrected image exists
- **THEN** `processedImage` is nil and `originalImage` is the uncropped capture

#### Scenario: T16 — "Ungrouped" is assigned

- **WHEN** a card is saved
- **THEN** the stored card belongs to exactly one group named "Ungrouped"
- **AND** no other group is created or assigned by saving

#### Scenario: T11 — Saving creates exactly one card

- **WHEN** the user taps "Save" once
- **THEN** the repository contains exactly one additional card

#### Scenario: ASSUMPTION — Saving with all fields empty is allowed (P05-S09 not captured)

- **WHEN** all rows are empty and the user taps "Save"
- **THEN** the card is saved with its image and nil fields
- **AND** the stored `name` is nil and no name is fabricated

### Requirement: First Note auto-created on save

A successful save SHALL create exactly one Note entry. Its text SHALL be "Card Saved <yyyy-MM-dd HH:mm>" followed by a source line. For a camera capture the source line SHALL be "From: Taking photo". The note timestamp SHALL equal the card's `createdAt`.

#### Scenario: T12/P08-S01 — Camera save creates the observed first note

- **WHEN** a card captured with the camera is saved
- **THEN** the card has exactly one note whose text is "Card Saved <yyyy-MM-dd HH:mm>" and "From: Taking photo"
- **AND** the note timestamp equals the card's `createdAt`

#### Scenario: ASSUMPTION — Album import source text (P03/P08 album source not captured)

- **WHEN** a card imported from the album is saved
- **THEN** the note's source line reads "From: Importing photo"
- **AND** this string is an ASSUMPTION that may change once the album-sourced Note is captured

#### Scenario: T11 — Saving creates no user memo

- **WHEN** a save completes
- **THEN** no user-authored memo is created
- **AND** the Note screen (P08) is not shown

### Requirement: Card Saved screen

After a successful save the app SHALL show a screen titled "Card Saved" with "Done", the saved card's thumbnail, and the actions "Group", "Note", "Sync", "Export" and "Take the next", matching P06-S01. "Group" and "Note" SHALL be inert placeholders for later changes. "Sync" and "Export" SHALL be inert premium actions that open no paywall. The CC AI assistant panel SHALL NOT be rendered.

#### Scenario: T12 — Card Saved shows the observed text and thumbnail

- **WHEN** a save completes
- **THEN** "Card Saved" is visible with "Done"
- **AND** the saved card's thumbnail is visible
- **AND** "Group", "Note", "Sync", "Export" and "Take the next" are visible

#### Scenario: T20 — "Group" and "Note" are inert placeholders

- **WHEN** the user taps "Group" or "Note" on Card Saved
- **THEN** no screen, sheet or menu opens
- **AND** the Card Saved screen stays visible

#### Scenario: T20 — "Sync" and "Export" are inert premium actions

- **WHEN** the user taps "Sync" or "Export" on Card Saved
- **THEN** no paywall and no sync or export flow opens
- **AND** the Card Saved screen stays visible

#### Scenario: T20 — The AI assistant panel is absent

- **WHEN** the Card Saved screen is shown
- **THEN** no assistant panel, assistant prompt list or assistant input field is rendered

### Requirement: Leaving Card Saved

"Take the next" SHALL return to the camera screen (P02-S01) ready for a new capture, without saving another card. "Done" SHALL dismiss the scan flow and show CardHolder with the new card.

#### Scenario: T12 — "Take the next" returns to the camera

- **WHEN** the user taps "Take the next"
- **THEN** the camera screen is shown with its observed chrome
- **AND** no additional card is saved

#### Scenario: ASSUMPTION — "Done" shows CardHolder with the new card (P01-S02 not captured)

- **WHEN** the user taps "Done"
- **THEN** the scan flow is dismissed
- **AND** the CardHolder tab is shown with the newly saved card in the list

### Requirement: Save failure is reported

When the repository cannot store the card, the app SHALL not show Card Saved, SHALL stay on Edit Card, and SHALL report the failure to the user. It SHALL NOT fabricate or partially store a card.

#### Scenario: ASSUMPTION — A failed save stays on Edit Card (not captured)

- **WHEN** the repository create call fails
- **THEN** Card Saved is not shown and Edit Card remains visible
- **AND** an error message is shown
- **AND** no card record is added

### Requirement: Saved card appears in CardHolder and card detail

The CardHolder list (T12) and the card detail screen (T13) SHALL render the saved card using the existing views: the card image, the stored fields, the "Ungrouped" group and the auto-created note. A card with a nil name SHALL show a placeholder label, not an invented name.

#### Scenario: T12 — CardHolder lists the saved card

- **WHEN** the user opens CardHolder after saving
- **THEN** the saved card appears in the list with its image thumbnail
- **AND** its stored name and company are shown when present

#### Scenario: ASSUMPTION — An image-only card has no invented name (P01-S02 not captured)

- **WHEN** a saved card has a nil name
- **THEN** CardHolder shows a placeholder label for it
- **AND** no name is displayed or stored

#### Scenario: T13 — Card detail shows the saved card

- **WHEN** the user opens the saved card from CardHolder
- **THEN** the card image and each non-empty stored primary field are shown
- **AND** "Ungrouped" and the auto-created first note are shown

### Requirement: Saved card survives relaunch

A card saved through the save action SHALL remain available after the app is terminated and launched again without a store reset, independent of seed data.

#### Scenario: T18 — A real saved card survives relaunch

- **WHEN** a card is saved, the app is terminated, and the app is launched again without the empty-store argument
- **THEN** the card is still in the CardHolder list
- **AND** its stored fields and image are unchanged
