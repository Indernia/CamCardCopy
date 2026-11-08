# App Shell Specification

## Purpose

Provides CamCard's navigation frame and card browsing screens, so later capture, recognition and editing features have a stable shell, a CardHolder list and a read-only card detail to open into.

## Requirements

### Requirement: Tab shell

The app SHALL present a tab bar labelled "Home", "CardHolder", "Tools" and "Settings" with a center scan button. Selecting Home or CardHolder SHALL show that tab; Tools and Settings SHALL open placeholder pages. The center scan button SHALL be a button, not a fifth tab selection.

#### Scenario: T01 — First launch opens the Home tab

- **WHEN** the app launches with an empty store
- **THEN** the Home tab is selected and the Home placeholder is visible

#### Scenario: ASSUMPTION — Tools and Settings open placeholders

- **WHEN** the user selects the Tools or Settings tab
- **THEN** a placeholder page is shown and no CamCard feature content is rendered

### Requirement: Home placeholder

The Home tab SHALL show a minimal placeholder that identifies the tab. It SHALL NOT show the P00-S01 search bar, notification bell, crown, stats icon or "My Digital Card" content, because this change builds Home as a placeholder only and defers the Home search bar to T15.

#### Scenario: ASSUMPTION — Home shows only a placeholder

- **WHEN** the app launches
- **THEN** no "Search Card Holder" field, bell, crown or stats icon is present
- **AND** the Home tab and the center scan button are present

### Requirement: CardHolder empty state

With no saved cards, the CardHolder screen SHALL show the title "CardHolder", a search field with placeholder "Search", the section header "Cards", the text "No cards", and the helper text "You can use the business card recognition function to upload business cards and efficiently manage your contacts". The search field SHALL be visible but SHALL NOT accept input in this change.

#### Scenario: T01 — Empty store shows the CardHolder empty state

- **WHEN** no cards are saved and the user selects the CardHolder tab
- **THEN** "CardHolder", "Search", "Cards", "No cards" and "You can use the business card recognition function to upload business cards and efficiently manage your contacts" are visible

#### Scenario: T01 — Empty-state search is not interactive

- **WHEN** the user taps the "Search" field on the empty CardHolder screen
- **THEN** no keyboard, search input or results appear

#### Scenario: ASSUMPTION — Empty state uses no CamCard artwork

- **WHEN** the empty CardHolder screen is shown
- **THEN** the illustration area contains an SF Symbol or plain placeholder, not CamCard's artwork

### Requirement: CardHolder add control placeholder

The CardHolder screen SHALL show a ⊕ control at the top right. In this change the control SHALL be a placeholder: tapping it SHALL NOT open a menu, screen or action. P01-S08 (what ⊕ opens) has not been captured, so this control is TODO(P01-S08).

#### Scenario: T01 — Empty CardHolder shows an inert ⊕ (ASSUMPTION: P01-S08 not captured)

- **WHEN** the empty CardHolder screen is shown
- **THEN** the ⊕ control is visible at the top right
- **WHEN** the user taps the ⊕ control
- **THEN** no menu or screen appears and "No cards" remains visible

### Requirement: CardHolder list

When at least one card exists, the CardHolder screen SHALL show the "Cards" section with one row per saved card, displaying the card's name and company when present. The empty state SHALL be replaced by the list. Selecting a row SHALL open that card's detail screen.

#### Scenario: T12 — Saved cards appear in CardHolder (ASSUMPTION: P01-S02 not captured)

- **WHEN** the store contains saved cards and the CardHolder tab is selected
- **THEN** one row per card is shown with the stored name
- **AND** "No cards" is not shown

#### Scenario: T13 — Tapping a card row opens its detail (ASSUMPTION: P09-S01 not captured)

- **WHEN** the user taps a card row
- **THEN** the detail screen for that card is shown

### Requirement: Read-only card detail

The card detail screen SHALL display the card image, or a placeholder when no image is stored, and only the fields that have a value among name, company, jobTitle, mobile, phone, email, website, address, groups and notes. It SHALL be read-only and SHALL NOT offer edit, save, delete, share, export or Sync controls.

#### Scenario: T13 — Detail shows stored values and omits empty fields (ASSUMPTION layout)

- **WHEN** a card with a name and no website is opened
- **THEN** the stored name is visible
- **AND** no website label or empty website row is shown

#### Scenario: T13 — Detail offers no editing (ASSUMPTION: P09-S01 not captured)

- **WHEN** the card detail screen is shown
- **THEN** no "Edit", "Save", "Delete", "Export" or "Sync" control is present

#### Scenario: ASSUMPTION — Detail shows groups and notes

- **WHEN** an opened card has groups and notes stored
- **THEN** its group names and each note's text are visible

### Requirement: Scan button opens card capture

The center scan button SHALL open the full-screen card capture flow defined by the `card-capture` capability instead of a placeholder screen. Closing the camera SHALL dismiss the flow and return to the previously selected tab.

#### Scenario: T02 — Scan button opens the camera flow

- **WHEN** the user taps the center scan button
- **THEN** the card capture camera screen appears with Close (X)
- **AND** no placeholder screen is shown

#### Scenario: T02 — Closing the camera returns to the previous tab

- **WHEN** the user taps Close (X) on the camera screen
- **THEN** the capture flow is dismissed
- **AND** the previously selected tab is shown again

#### Scenario: ASSUMPTION — Existing scan open/close path is preserved

- **WHEN** the existing scan open/close UI check taps the center scan button
- **THEN** the camera screen appears
- **AND** tapping Close returns to the Home tab
