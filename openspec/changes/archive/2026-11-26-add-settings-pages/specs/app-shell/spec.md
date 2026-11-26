# Spec Delta

## REMOVED Requirements

### Requirement: Settings root content

**Reason**: Its scenarios "T21 — Sign in and Upgrade are inert" and "T21 — Settings rows other than General are inert" no longer hold: every captured Settings page now exists and its row opens it. A MODIFIED block would have to keep those stale scenarios.

**Migration**: Use the ADDED "Settings root and row navigation" requirement. The root's text, rows, headers and identifiers are unchanged; only the rows' destinations change.

## ADDED Requirements

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

## MODIFIED Requirements

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
