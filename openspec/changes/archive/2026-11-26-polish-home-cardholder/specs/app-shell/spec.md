# Spec Delta

## REMOVED Requirements

### Requirement: CardHolder top bar

**Reason**: The bell is no longer inert; it pushes "Messages" (P31-S01). A MODIFIED block would have to keep the stale "CardHolder shows an inert bell" scenario.

**Migration**: Use the ADDED "CardHolder top bar with Messages entry" requirement. The bell and ⊕ positions and identifiers are unchanged.

### Requirement: CardHolder add control placeholder

**Reason**: ⊕ now opens a barebones menu, so the old "opens nothing" scenario no longer holds.

**Migration**: Use the ADDED "CardHolder add menu (P01-S08, ASSUMPTION)" requirement. The ⊕ identifier `cardholder.add` is unchanged.

### Requirement: Home tab content

**Reason**: The bell, crown and "Create New Card" are no longer inert; they push P31-S01, P21-S01 and P33-S01. A MODIFIED block would have to keep the stale "top-bar icons are inert", "promo cards are inert" and "Create New Card is inert" scenarios.

**Migration**: Use the ADDED "Home tab content and entries" requirement. Every Home identifier and visible text is unchanged; the search bar, stats icon and promo cards stay inert.

## MODIFIED Requirements

### Requirement: CardHolder empty state

With no saved cards, the CardHolder screen SHALL show the title "CardHolder", a search capsule with placeholder "Search" on the header tint, then a white sheet with rounded top corners holding the section header "Cards", the text "No cards", and the helper text "You can use the business card recognition function to upload business cards and efficiently manage your contacts". With no saved cards the search capsule SHALL be visible but SHALL NOT accept input.

#### Scenario: T01 — Empty store shows the CardHolder empty state

- **WHEN** no cards are saved and the user selects the CardHolder tab
- **THEN** "CardHolder", "Search", "Cards", "No cards" and "You can use the business card recognition function to upload business cards and efficiently manage your contacts" are visible

#### Scenario: T01 — Empty-state search is not interactive

- **WHEN** the user taps the "Search" field on the empty CardHolder screen
- **THEN** no keyboard, search input or results appear

#### Scenario: ASSUMPTION — Empty state uses no CamCard artwork

- **WHEN** the empty CardHolder screen is shown
- **THEN** the illustration area contains an SF Symbol or plain placeholder, not CamCard's artwork

#### Scenario: T24 — CardHolder matches P01-S01 (visual check)

- **WHEN** the empty CardHolder is compared with P01-S01
- **THEN** the tinted header, white search capsule, sheet top, "Cards" header, empty-state text sizes and helper width are within about 2 pt and the design's measured values

### Requirement: CardHolder list

When at least one card exists, the CardHolder screen SHALL show the "Cards" section with one row per saved card, newest first, showing a card-ratio thumbnail, the card's name and its company when present. The thumbnail SHALL use the stored corrected image when there is one, otherwise the original image, otherwise a placeholder symbol. The empty state SHALL be replaced by the list. Selecting a row SHALL open that card's detail screen. Row layout is ASSUMPTION (P01-S02 and P01-S03 not captured).

#### Scenario: T12 — Saved cards appear in CardHolder (ASSUMPTION: P01-S02 not captured)

- **WHEN** the store contains saved cards and the CardHolder tab is selected
- **THEN** one row per card is shown with the stored name
- **AND** "No cards" is not shown

#### Scenario: T13 — Tapping a card row opens its detail (ASSUMPTION: P09-S01 not captured)

- **WHEN** the user taps a card row
- **THEN** the detail screen for that card is shown

#### Scenario: T24 — Thumbnail prefers the corrected image

- **WHEN** a card has both an original and a corrected image
- **THEN** its row thumbnail is built from the corrected image

### Requirement: Read-only card detail

The card detail screen SHALL display the stored corrected card image when there is one, otherwise the original image, or a placeholder when no image is stored. It SHALL show only the fields that have a value among name, company, jobTitle, mobile, phone, email, website, address, groups and notes. It SHALL show a single plain back control and SHALL be read-only, offering no edit, save, delete, share, export or Sync controls.

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

#### Scenario: T24 — Detail image prefers the corrected image

- **WHEN** a card with both an original and a corrected image is opened
- **THEN** the detail image is built from the corrected image

## ADDED Requirements

### Requirement: Home tab content and entries

The Home tab SHALL render the P00-S01 layout: a bell at the top left, a search bar reading "Search Card Holder", a crown and a stats icon at the top right, a two-card promo row reading "Speech to Text" / "AI Summary" and "High Accuracy" / "99.99% Accuracy", a "My Digital Card" section, the text "No cards yet. Create a new one!" shown on two lines broken after "yet.", and a "Create New Card" button. The header and promo row SHALL sit on the header tint and the "My Digital Card" section on a white sheet with rounded top corners, using the shared color and type tokens. The bell SHALL push "Messages" (P31-S01), the crown SHALL push "Upgrade Plans" (P21-S01) and "Create New Card" SHALL push "Create your card" step 1 (P33-S01). The search bar, the stats icon and both promo cards SHALL stay inert.

#### Scenario: T21 — Home shows the observed P00-S01 chrome

- **WHEN** the app launches
- **THEN** "Search Card Holder", "Speech to Text", "AI Summary", "High Accuracy", "99.99% Accuracy", "My Digital Card", "No cards yet. Create a new one!" and "Create New Card" are visible

#### Scenario: T21 — Home search is inert

- **WHEN** the user taps the "Search Card Holder" bar
- **THEN** no keyboard appears and no search field or results screen is shown
- **AND** the Home content remains visible

#### Scenario: T21 — Home stats icon and promo cards are inert

- **WHEN** the user taps the stats icon, the "Speech to Text" promo card or the "High Accuracy" promo card
- **THEN** no screen, menu, sheet or toggle appears (the stats destination was not captured — ASSUMPTION)
- **AND** the Home content remains visible

#### Scenario: T24 — Home bell opens Messages

- **WHEN** the user taps the Home bell
- **THEN** the "Messages" page (P31-S01) is pushed with a plain back control
- **WHEN** the user taps the back control
- **THEN** the Home content is visible again

#### Scenario: T24 — Crown opens Upgrade Plans

- **WHEN** the user taps the crown
- **THEN** the "Upgrade Plans" page (P21-S01) is pushed
- **AND** back returns to Home

#### Scenario: T24 — Create New Card opens step 1

- **WHEN** the user taps "Create New Card"
- **THEN** the "Create your card" page (P33-S01) is pushed
- **AND** back returns to Home

#### Scenario: T21 — Home placeholders use no CamCard artwork

- **WHEN** the Home tab is shown
- **THEN** the bell, crown, stats, promo and empty-state images are SF Symbols or plain shapes, not CamCard illustrations, logos or icons

#### Scenario: T24 — Home matches P00-S01 (visual check)

- **WHEN** Home is compared with P00-S01
- **THEN** the header tint, white sheet, card and pill positions, type sizes and colors are within about 2 pt and the design's measured values

### Requirement: CardHolder top bar with Messages entry

The CardHolder screen SHALL show a bell at the top left and a ⊕ at the top right as plain navy icons with no glass background, and the title "CardHolder" centered in the navigation title style, on the header tint. Tapping the bell SHALL push "Messages" (P31-S01).

#### Scenario: T24 — CardHolder bell opens Messages

- **WHEN** the user taps the CardHolder bell
- **THEN** the "Messages" page (P31-S01) is pushed
- **WHEN** the user taps the back control
- **THEN** CardHolder is shown again with its empty state or list

#### Scenario: T21 — Existing CardHolder behavior is unchanged

- **WHEN** the empty CardHolder screen is shown
- **THEN** "CardHolder", "Search", "Cards", "No cards" and the helper text are still visible

### Requirement: CardHolder add menu (P01-S08, ASSUMPTION)

The CardHolder screen SHALL show a ⊕ control at the top right. Tapping it SHALL open a barebones menu with the items "Scan card" and "Import from album". The items SHALL be inert. P01-S08 has not been captured, so the menu is ASSUMPTION and marked TODO(P01-S08).

#### Scenario: T01 — Empty CardHolder shows ⊕ and the empty state stays (ASSUMPTION: P01-S08 not captured)

- **WHEN** the empty CardHolder screen is shown
- **THEN** the ⊕ control is visible at the top right
- **WHEN** the user taps the ⊕ control
- **THEN** a menu with "Scan card" and "Import from album" appears and "No cards" remains visible behind it
- **WHEN** the user taps a menu item
- **THEN** no screen opens
