# App Shell Specification

## Purpose

Provides CamCard's navigation frame and card browsing screens, so later capture, recognition and editing features have a stable shell, a CardHolder list and a read-only card detail to open into.

## Requirements

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

### Requirement: Tab navigation shell

The app SHALL present a tab bar labelled "Home", "CardHolder", "Tools" and "Settings" with a center scan button. Selecting Home, CardHolder, Tools or Settings SHALL show that tab's content. The center scan button SHALL be a button, not a fifth tab selection.

The tab bar SHALL match P00-S01: a white background, 10 pt labels, the selected tab's icon and label in `#1E1E1E` with a filled icon, unselected tabs in `#989898` with an outline icon, and a 44 pt round center scan button filled with the `#534EF6` to `#873EF6` gradient and a white camera symbol. Icons, labels and the scan button SHALL share a bottom edge about 35 pt above the screen bottom, as measured on P00-S01. Tab labels, accessibility identifiers and selection behavior SHALL NOT change.

#### Scenario: T01 — First launch opens the Home tab

- **WHEN** the app launches with an empty store
- **THEN** the Home tab is selected and the P00-S01 Home content is visible

#### Scenario: T21 — Tools and Settings open their observed tabs

- **WHEN** the user selects the Tools or Settings tab
- **THEN** that tab's inert placeholder content from P30-S01/P30-S02 or P10-S01 is shown
- **AND** no "Coming soon" text is rendered in either tab

#### Scenario: T22 — Selected tab is marked and the others are not

- **WHEN** the user selects each of Home, CardHolder, Tools and Settings in turn
- **THEN** only the selected tab button reports the selected state
- **AND** the labels "Home", "CardHolder", "Tools" and "Settings" stay visible

#### Scenario: T22 — Scan button keeps opening the camera

- **WHEN** the user taps the restyled center scan button
- **THEN** the card capture camera screen appears with Close (X)

#### Scenario: T22 — Tab bar matches P00-S01 (visual check)

- **WHEN** the tab bar is compared with P00-S01
- **THEN** the background is white, labels use the measured colors and size, the selected icon is filled, and the scan button shows the violet gradient

### Requirement: Tools tab content

The Tools tab SHALL show "Tools" with "Help" and a "Recommend" / "Smart sync" selector, with "Recommend" selected initially. The two panes SHALL show the observed P30-S01 and P30-S02 tiles. Every tile and "Help" SHALL be inert.

The layout SHALL match P30-S01/P30-S02 within about 1 pt:

- "Tools" in the page title style at the top left.
- "Help" in `#1C4064` followed by a filled "?" circle at the top right.
- The selector labels are centered in the left and right halves. The selected label is in `#1F1F1F` with a short `#50A6F8` underline; the other is in `#9A9A9A`.
- A hairline divider sits below the selector.
- A two-column grid of rounded tiles has each tile's title in white at its bottom left.
- "AI Transcription" carries a red "New" badge at its top right.

CamCard's tile photographs SHALL NOT be copied.

#### Scenario: T21 — Tools opens on Recommend

- **WHEN** the user selects the Tools tab
- **THEN** "Recommend" and "Smart sync" are visible
- **AND** "AI Transcription", "Email Signatures", "Video Conference Card", "Dashboard", "High Accuracy" and "Team Business Card" are visible

#### Scenario: T21 — Smart sync shows the observed tiles

- **WHEN** the user selects "Smart sync"
- **THEN** "Save to Contacts", "Contacts Backup", "Salesforce", "Google Contacts", "Outlook/Office365" and "Export to Excel/Vcf" are visible
- **AND** the Recommend tiles are no longer shown

#### Scenario: T21 — Tools tiles are inert

- **WHEN** the user taps any Recommend or Smart sync tile
- **THEN** no screen, sheet or menu appears
- **AND** no card list, selection count or sync operation is shown
- **AND** the current Tools pane remains selected

#### Scenario: T21 — Tools Help is inert

- **WHEN** the user taps "Help"
- **THEN** no screen or menu appears (P16-S01 is out of scope)

#### Scenario: T23 — AI Transcription shows the "New" badge

- **WHEN** the Recommend pane is shown
- **THEN** a "New" badge is visible on the "AI Transcription" tile
- **AND** no other tile shows a badge

#### Scenario: T23 — Selector marks the selected pane

- **WHEN** the user selects "Recommend" and then "Smart sync"
- **THEN** only the selected segment reports the selected state each time

#### Scenario: T23 — Tools matches P30-S01 and P30-S02 (visual check)

- **WHEN** the Recommend and Smart sync panes are compared with P30-S01 and P30-S02
- **THEN** the title, Help, selector, underline, divider, tile sizes, gutters, corner radius, title placement and "New" badge are within about 1 pt and match the measured colors in design.md D3

### Requirement: Settings General read-only screen

Selecting "General" on Settings SHALL open a read-only "General" screen styled as P11-S01. It shows the observed rows and values on a light grey page with white rows, and two toggles shown off. "Show group settings when saving cards" is shown off because P11-S01 shows off (ASSUMPTION: P07-S01 shows it on). Every row SHALL be inert and no editing SHALL be offered. The tab bar SHALL be hidden while General is shown.

#### Scenario: T21 — General opens read-only with the observed rows

- **WHEN** the user taps "General"
- **THEN** the "General" screen is shown with "New cards autosaved to Contacts", "Off", "Font Size", "Recognition Languages", "Show group settings when saving cards", "Save Card Image", "Sort Order", "First, Last", "Display Order", "Clear your space", "Not logged in", "App Lock" and "Once enabled, a password will be required to open the app"

#### Scenario: T21 — General toggles and rows are inert

- **WHEN** the user taps any General row or the two toggles
- **THEN** no screen appears and no toggle changes state
- **AND** the "General" screen remains visible

#### Scenario: T21 — General returns to Settings

- **WHEN** the user taps the back control on "General"
- **THEN** the Settings root is shown again

### Requirement: Inert placeholder contract

Every placeholder added by this change SHALL be visible, SHALL carry an accessibility identifier, and SHALL be accompanied by a `TODO(P##-S##)` marker naming the state it belongs to. Placeholders SHALL NOT fetch data, simulate login, show a paywall, use the network, or invent card, contact or account data. Placeholders SHALL use SF Symbols instead of CamCard artwork.

#### Scenario: T21 — Every placeholder is identifiable and inert

- **WHEN** the UI test walks the Home, Tools, Settings and CardHolder placeholder controls by accessibility identifier
- **THEN** each identifier resolves to a visible element
- **AND** tapping each element leaves the current screen and visible text unchanged
- **AND** no fake card, contact or account data is shown

### Requirement: Shared route list for pushed pages

The app SHALL keep one list of pushable destinations: "Messages" (P31-S01), "Biz Tips" (P32-S01), "Create your card" steps 1–3 (P33-S01, P33-S02, P33-S03), the Settings sub-pages "Account and Sync" (P10-S01, ASSUMPTION: not captured), "Language setting" (P12-S01), "Notifications" (P13-S01), "Privacy Settings" (P14-S01), "System permissions" (P15-S01), "Help and Feedback" (P16-S01), "Recommend to Friends" (P17-S01), "About" (P18-S01), "Personal Information Collection Checklist" (P19-S01), "Login via email" (P20-S01) and "Upgrade Plans" (P21-S01). Home, CardHolder, Tools and Settings SHALL each be able to push any of them. In this change no control pushes a route; every control that was inert stays inert.

#### Scenario: T22 — Routes exist without changing inert controls

- **WHEN** the app runs after this change
- **THEN** every route in the list resolves to a page
- **AND** the Home bell, "Create New Card", the CardHolder bell and every Settings row except "General" still open nothing

### Requirement: Settings root and row navigation

The Settings tab SHALL show the P10-S01 root: a pinned "Settings" header, a sign-in card, a Premium card, and the grouped row sections "APP SETTINGS", "Resume In-APP Purchases", "Help and Feedback" and "ABOUT CAMCARD". The Premium card SHALL list "Unlimited Scan", "Sync CRM", "Export to Excel" and "Back up". "General" SHALL open General. "Sign in to access more features" SHALL open "Login via email". "Upgrade +" and the four Premium items SHALL open "Upgrade Plans" (ASSUMPTION: P21-S01 was captured from Card Saved, not Settings). Every other row except "Resume In-APP Purchases" SHALL open its page from the `settings-pages` capability. "Resume In-APP Purchases" SHALL stay inert.

#### Scenario: T21 — Settings shows the observed root rows

- **WHEN** the user selects the Settings tab
- **THEN** "Settings", "Sign in to access more features", "Premium", "Upgrade +", "Unlimited Scan", "Sync CRM", "Export to Excel", "Back up", "APP SETTINGS", "Account and Sync", "General", "Language setting", "Notifications", "Privacy Settings", "System permissions", "Resume In-APP Purchases", "Help and Feedback", "Recommend to Friends", "ABOUT CAMCARD", "About" and "Personal Information Collection Checklist" are visible or reachable by scrolling

#### Scenario: T21 — Sign in opens Login via email

- **WHEN** the user taps "Sign in to access more features"
- **THEN** the "Login via email" page (P20-S01) is shown
- **WHEN** the user taps "‹"
- **THEN** the Settings root is shown again

#### Scenario: T21 — Upgrade and Premium items open Upgrade Plans (ASSUMPTION)

- **WHEN** the user taps "Upgrade +", "Unlimited Scan", "Sync CRM", "Export to Excel" or "Back up"
- **THEN** the "Upgrade Plans" page (P21-S01) is shown
- **AND** tapping "‹" returns to the Settings root

#### Scenario: T21 — Each Settings row opens its page

- **WHEN** the user taps "Account and Sync", "Language setting", "Notifications", "Privacy Settings", "System permissions", "Help and Feedback", "Recommend to Friends", "About" or "Personal Information Collection Checklist"
- **THEN** that row's page is shown with the tab bar hidden
- **AND** tapping "‹" returns to the Settings root with the tab bar visible

#### Scenario: T21 — Resume In-APP Purchases stays inert

- **WHEN** the user taps "Resume In-APP Purchases"
- **THEN** no screen, sheet or purchase prompt appears and the Settings root stays current

#### Scenario: T25 — Settings root matches P10-S01 (visual check)

- **WHEN** the Settings root is compared with P10-S01a and, after scrolling, P10-S01b
- **THEN** the header stays pinned while the rows scroll, the cards and rows use the measured colors, insets and heights, and "Help and Feedback" is written in mixed case while "APP SETTINGS" and "ABOUT CAMCARD" are capitals

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
