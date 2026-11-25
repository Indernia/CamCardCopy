# Spec Delta

## REMOVED Requirements

### Requirement: Tab shell

**Reason**: The shell now renders observed inert tab content instead of "Coming soon" pages, so the old "ASSUMPTION — Tools and Settings open placeholders" scenario no longer applies. The requirement is re-expressed as "Tab navigation shell" because a MODIFIED block would have to keep that stale scenario.

**Migration**: Use the ADDED "Tab navigation shell" requirement. The tab labels, tab identifiers, tab selection and center scan button are unchanged.

### Requirement: Home placeholder

**Reason**: Replaced by the observed P00-S01 Home content. The old requirement explicitly forbade the Home search bar, bell, crown and stats icon, which this change must show as inert placeholders.

**Migration**: Use the new "Home tab content" requirement. The Home tab keeps the existing launch check's accessibility identifier so T01, T02 and T03T20 continue to pass without edits.

## ADDED Requirements

### Requirement: Tab navigation shell

The app SHALL present a tab bar labelled "Home", "CardHolder", "Tools" and "Settings" with a center scan button. Selecting Home, CardHolder, Tools or Settings SHALL show that tab's content. The center scan button SHALL be a button, not a fifth tab selection.

#### Scenario: T01 — First launch opens the Home tab

- **WHEN** the app launches with an empty store
- **THEN** the Home tab is selected and the P00-S01 Home content is visible

#### Scenario: T21 — Tools and Settings open their observed tabs

- **WHEN** the user selects the Tools or Settings tab
- **THEN** that tab's inert placeholder content from P30-S01/P30-S02 or P10-S01 is shown
- **AND** no "Coming soon" text is rendered in either tab

### Requirement: Home tab content

The Home tab SHALL render the P00-S01 layout: a bell at the top left, a search bar reading "Search Card Holder", a crown and a stats icon at the top right, a two-card promo row reading "Speech to Text" / "AI Summary" and "High Accuracy" / "99.99% Accuracy", a "My Digital Card" section, the text "No cards yet. Create a new one!", and a "Create New Card" button. The tab bar and center scan button SHALL stay unchanged. Every control in this layout SHALL be inert.

#### Scenario: T21 — Home shows the observed P00-S01 chrome

- **WHEN** the app launches
- **THEN** "Search Card Holder", "Speech to Text", "AI Summary", "High Accuracy", "99.99% Accuracy", "My Digital Card", "No cards yet. Create a new one!" and "Create New Card" are visible

#### Scenario: T21 — Home search is inert

- **WHEN** the user taps the "Search Card Holder" bar
- **THEN** no keyboard appears and no search field or results screen is shown
- **AND** the Home content remains visible

#### Scenario: T21 — Home top-bar icons are inert

- **WHEN** the user taps the bell, the crown or the stats icon
- **THEN** no screen, menu, paywall or message list appears (bell: P31-S01 is out of scope; crown: P21-S01 is out of scope; the stats destination was not captured — ASSUMPTION)
- **AND** the Home content remains visible

#### Scenario: T21 — Home promo cards are inert

- **WHEN** the user taps the "Speech to Text" or "High Accuracy" promo card
- **THEN** no screen or toggle appears
- **AND** the Home content remains visible

#### Scenario: T21 — Create New Card is inert

- **WHEN** the user taps "Create New Card"
- **THEN** no digital card screen appears (P33-S01 is out of scope)
- **AND** the Home content remains visible

#### Scenario: T21 — Home placeholders use no CamCard artwork

- **WHEN** the Home tab is shown
- **THEN** the bell, crown, stats, promo and empty-state images are SF Symbols or plain shapes, not CamCard illustrations, logos or icons

### Requirement: CardHolder top bar

The CardHolder screen SHALL show a bell at the top left in addition to the existing ⊕ at the top right. The bell SHALL be inert. The card list, empty state, ⊕ and T01 behavior SHALL NOT change.

#### Scenario: T21 — CardHolder shows an inert bell

- **WHEN** the CardHolder tab is shown
- **THEN** the bell is visible at the top left
- **WHEN** the user taps the bell
- **THEN** no screen or menu appears (P31-S01 is out of scope)
- **AND** "No cards" or the existing card list remains visible

#### Scenario: T21 — Existing CardHolder behavior is unchanged

- **WHEN** the empty CardHolder screen is shown
- **THEN** "CardHolder", "Search", "Cards", "No cards" and the helper text are still visible
- **AND** the ⊕ still opens nothing

### Requirement: Tools tab content

The Tools tab SHALL show "Tools" with "Help" and a "Recommend" / "Smart sync" selector, with "Recommend" selected initially. The two panes SHALL show the observed P30-S01 and P30-S02 tiles. Every tile and "Help" SHALL be inert.

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

### Requirement: Settings root content

The Settings tab SHALL show the P10-S01 root with a sign-in card, a Premium card, and the three grouped row sections. The Premium card SHALL list the four observed inert items "Unlimited Scan", "Sync CRM", "Export to Excel" and "Back up". Only "General" SHALL open a screen. Sign-in, "Upgrade +" and every other row and item SHALL be inert.

#### Scenario: T21 — Settings shows the observed root rows

- **WHEN** the user selects the Settings tab
- **THEN** "Settings", "Sign in to access more features", "Premium", "Upgrade +", "Unlimited Scan", "Sync CRM", "Export to Excel", "Back up", "APP SETTINGS", "Account and Sync", "General", "Language setting", "Notifications", "Privacy Settings", "System permissions", "Resume In-APP Purchases", "Help and Feedback", "Recommend to Friends", "ABOUT CAMCARD", "About" and "Personal Information Collection Checklist" are visible or reachable by scrolling

#### Scenario: T21 — Sign in and Upgrade are inert

- **WHEN** the user taps "Sign in to access more features" or "Upgrade +"
- **THEN** no login screen (P20-S01) and no paywall (P21-S01) appears
- **AND** the Settings content remains visible

#### Scenario: T21 — Settings rows other than General are inert

- **WHEN** the user taps "Account and Sync", "Language setting", "Notifications", "Privacy Settings", "System permissions", "Resume In-APP Purchases", "Help and Feedback", "Recommend to Friends", "About", "Personal Information Collection Checklist", "Unlimited Scan", "Sync CRM", "Export to Excel" or "Back up"
- **THEN** no screen or menu appears (P12, P13, P14, P15, P16, P17, P18 and P19 are out of scope)
- **AND** the Settings remains the current screen

### Requirement: Settings General read-only screen

Selecting "General" on Settings SHALL open a read-only "General" screen showing the P11-S01 rows with their observed values and two toggles shown off. "Show group settings when saving cards" is shown off because P11-S01 shows off (ASSUMPTION: P07-S01 shows it on). Every row SHALL be inert and no editing SHALL be offered.

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
