# Proposal

## Why

The shell tabs (Home, Tools, Settings) still show "Coming soon" or a bare title, so the app looks nothing like CamCard on the screens we already have screenshots for. Later changes (capture, recognition, tools, settings) then have no stable visual frame to fill in, and the layout work keeps accreting into unrelated changes.

This change builds the observed top-level chrome as visible but inert placeholders, once, so later changes only fill behavior in.

## What Changes

- Replace the Home "Coming soon" page with the observed P00-S01 layout: bell, "Search Card Holder" search bar, crown, stats icon, the two promo cards, the "My Digital Card" section with its empty text and "Create New Card" button. Tab bar and center scan button are unchanged.
- Add the missing top-left bell to CardHolder (P01-S01). The list, empty state, ⊕ and existing behavior are unchanged.
- Replace the Tools placeholder with the observed Recommend / Smart sync layout (P30-S01, P30-S02), including the inert Smart sync tiles "Save to Contacts", "Contacts Backup", "Salesforce", "Google Contacts", "Outlook/Office365", "Export to Excel/Vcf".
- Replace the Settings placeholder with the observed P10-S01a/b root rows, and open P11-S01 General as a read-only screen with its observed rows inert.
- Every placeholder is visible and inert, has an accessibility identifier and a `TODO(P##-S##)` comment naming the state it belongs to.
- Entry points to out-of-scope states (login, premium/paywall, messages, biz tips, digital card creation) exist as inert controls.
- New UI test suite T21 asserts each placeholder exists by identifier and that tapping it changes nothing. T01, T02, T03T20 and T18 stay green.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `app-shell`: Home, Tools and Settings tab content changes from placeholders to observed inert chrome; CardHolder gains a bell; new requirements cover the settings General read-only screen and inert entry points. T01 scenarios that asserted "no Home chrome" are replaced.

## Impact

- Code: `Features/Shell/RootView.swift` (wire the new tab content), `Features/CardHolder/CardHolderView.swift` (bell in toolbar), new `Features/Shell/HomeView.swift`, `ToolsView.swift`, `SettingsView.swift`, `SettingsGeneralView.swift`, and shared inert-row helpers. `Features/Shell/PlaceholderView.swift` becomes unused and is removed once `placeholder.home` is carried by the Home view (see design).
- Tests: new `CamCard CopyUITests/T21ShellPlaceholderUITests.swift`; existing `T01EmptyCardHolderUITests`, `T02CameraUITests`, `T03T20CameraDeniedUITests`, `T18PersistenceUITests` must keep passing without edits.
- No changes to models, persistence, capture, recognition, album picker or Edit Card. No new dependencies, no network, no fake data.

## States covered

- P00-S01 Home, P01-S01 CardHolder chrome, P30-S01 Tools › Recommend, P30-S02 Tools › Smart sync, P10-S01a/P10-S01b Settings root, P11-S01 Settings › General (read-only).
- Inert entry points for out-of-scope P20-S01, P21-S01, P31-S01, P32-S01, P33-S01.
- Test IDs: T01, T02, T03T20, T18 (regression only) and new T21.

## Out of scope

- `Features/Scan`, `Features/EditCard`, `Features/Album` and any recognition file — `add-card-recognition` is changing those in parallel. Edit Card's extra P05-S01 controls are a separate follow-up after recognition is archived.
- Home search behavior (P00-S03/T15): the Home search bar is inert.
- Login (P20), paywall (P21), messages (P31), biz tips (P32), digital card creation (P33): entry points only, inert.
- Tools features themselves (save to contacts, sync, backup, export), notifications (P13), system permissions (P15), Help and Feedback (P16), Recommend to Friends (P17), About (P18), Personal Information Collection Checklist (P19), Language (P12), Privacy (P14).
- Any CamCard artwork, logo or icon; any fake data, fake login, paywall or network.
