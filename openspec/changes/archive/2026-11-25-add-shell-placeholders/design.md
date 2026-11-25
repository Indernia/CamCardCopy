# Design

## Context

See `proposal.md` — Why. The shell today is three "Coming soon" pages (`PlaceholderView`) plus a working CardHolder and scan flow. `RootView` owns tab selection and the scan cover; `MainTabBar` is custom and stays as-is. The Xcode project uses `PBXFileSystemSynchronizedRootGroup`, so new Swift files are picked up without `project.pbxproj` edits.

Two constraints shape this design:

- Existing UI tests query `app.staticTexts["placeholder.home"]` (`T01EmptyCardHolderUITests`, `T02CameraUITests`, `T03T20CameraDeniedUITests`). They must stay green without edits, so the Home redesign must keep a static text carrying that identifier.
- `add-card-recognition` is editing `Features/Scan`, `Features/EditCard`, `Features/Album` and recognition code in parallel. Nothing in those paths may be touched here.

## Goals / Non-Goals

**Goals:**

- One inert placeholder view per tab content area, matching the observed P00-S01, P30-S01/S02 and P10-S01 layout and text.
- CardHolder gains only the missing bell in its top bar.
- Settings › General opens read-only (P11-S01).
- Stable accessibility identifiers and `TODO(P##-S##)` markers so later changes can fill each placeholder in place.
- New T21 UI tests prove every placeholder exists and is inert; T01, T02, T03T20 and T18 unchanged.

**Non-Goals:**

- No behavior for any placeholder: no search, no messages, no login, no paywall, no digital card, no sync, no export, no contacts.
- No data reads or writes, no network, no fake cards/contacts/accounts.
- No changes to `Features/Scan`, `Features/EditCard`, `Features/Album` or recognition files.
- No CamCard artwork, logos or brand icons; SF Symbols and plain shapes only.
- No "New" badge on the AI Transcription tile: a badge implies feature status and is not worth faking, so the tile shows its label only.

## Decisions

### D1 — Keep `placeholder.home` on the "My Digital Card" heading

`Text("My Digital Card")` carries `.accessibilityIdentifier("placeholder.home")`. T01, T02 and T03T20 keep querying `staticTexts["placeholder.home"]` and stay green; no hidden or fake element is added, and no test is edited. The empty-state copy is one `Text("No cards yet. Create a new one!")` that wraps naturally; it contains no newline character, so the T21 string assertion can match the whole sentence.

Alternatives: keep an invisible zero-size text (hidden elements are not visible placeholders and are brittle in XCUITest); edit the tests (forbidden by project rules); keep the old "Coming soon" page (contradicts the request).

### D2 — One view type per tab, not a configurable placeholder

`HomeView`, `ToolsView`, `SettingsView`, `SettingsGeneralView` are separate `struct`s in `Features/Shell/`, each with its own layout. Later changes replace one body at a time. A data-driven placeholder model was rejected: it would encode three different layouts as configuration and make each follow-up harder, not easier.

### D3 — Inert controls are real buttons with empty actions

Every placeholder control is a `Button` whose action is empty (or a disabled `Toggle` for the two General switches), followed by `// TODO(P##-S##)`. This keeps elements discoverable as `app.buttons[...]` for T21 and guarantees "tapping changes nothing" while still looking enabled like the reference. `.disabled(true)` on the toggles also prevents state changes; keeping them bound to `.constant(false)` means they can never flip.

Alternative: `allowsHitTesting(false)` — XCUITest can still synthesize taps on such views, and other elements may steal them; empty actions are unambiguous.

### D4 — Tools uses a custom Recommend / Smart sync selector

The reference shows two text tabs with a blue underline, not a native segmented `Picker`. `ToolsView` keeps `@State private var pane: ToolsPane` and renders two buttons plus a 2 pt blue underline under the selected label. Selecting a pane only swaps static placeholder content, which is observed navigation (P30-S01 → P30-S02), not a feature. Tiles are laid out as a two-column `LazyVGrid` because P30-S01/S02 show tile grids, not list rows; labels are the observed text and the artwork is a plain rounded card with an SF Symbol.

### D5 — Settings root is a plain `List` with inert rows

`SettingsView` wraps `List` in a `NavigationStack`, with the "Settings" title inline. Sign-in and Premium are custom rounded cards at the top, `APP SETTINGS` / `Help and Feedback` / `ABOUT CAMCARD` are section headers marked `.textCase(nil)` so "Help and Feedback" keeps its observed mixed case while the other two are written in capitals as observed, and every row is a `Button` row with a trailing chevron except "General", which is the only `NavigationLink` (destination `SettingsGeneralView`). `Resume In-APP Purchases` sits in its own section, as observed. The Premium card carries the four observed inert feature items "Unlimited Scan", "Sync CRM", "Export to Excel" and "Back up" beside "Premium" and "Upgrade +".

The sign-in card's provider row is decorative and not tappable on its own (the card's "Sign in to access more features" control is the inert target). Because brand marks are forbidden, each of the six observed icons gets a substitute: envelope for mail, `iphone` for phone, a rounded square containing the letter "G" for Google, `person.crop.circle` for the Apple logo, a rounded square containing "in" for LinkedIn, and a rounded square containing "f" for Facebook.

### D6 — General is a read-only mirror of P11-S01

`SettingsGeneralView` uses a `List` with the observed grouped sections, right-side values ("Off", "First, Last", "Not logged in") and two disabled off toggles. "Show group settings when saving cards" is shown off to mirror P11-S01; `reference/observations.md` notes it is on in P07-S01, so showing it off is an ASSUMPTION. The default back button is kept; no edit controls exist. Footer text is a section footer.

### D7 — Identifiers and TODO markers

| Control | Identifier | TODO |
|---|---|---|
| Home search bar | `home.search` | P00-S03 |
| Home bell | `home.bell` | P31-S01 |
| Home crown | `home.crown` | P21-S01 |
| Home stats | `home.stats` | P00-S01 (ASSUMPTION — destination not captured) |
| Home promo "Speech to Text" | `home.promo.speechToText` | P00-S01 |
| Home promo "High Accuracy" | `home.promo.highAccuracy` | P00-S01 |
| Home "Create New Card" | `home.digitalCard.create` | P33-S01 |
| Home "My Digital Card" text | `placeholder.home` (kept for T01/T02/T03T20) | — |
| CardHolder bell | `cardholder.bell` | P31-S01 |
| Tools Help | `tools.help` | P16-S01 |
| Tools selector "Recommend" | `tools.segment.recommend` | P30-S01 |
| Tools selector "Smart sync" | `tools.segment.smartSync` | P30-S02 |
| Recommend tiles | `tools.recommend.aiTranscription`, `.emailSignatures`, `.videoConferenceCard`, `.dashboard`, `.highAccuracy`, `.teamBusinessCard` | P30-S01 |
| Smart sync tiles | `tools.sync.saveToContacts`, `.contactsBackup`, `.salesforce`, `.googleContacts`, `.outlookOffice365`, `.exportExcelVcf` | P30-S02 |
| Settings sign-in | `settings.signIn` | P20-S01 |
| Settings Upgrade | `settings.premium.upgrade` | P21-S01 |
| Premium feature items | `settings.premium.unlimitedScan`, `.syncCRM`, `.exportExcel`, `.backUp` | P21-S01 |
| Settings rows | `settings.row.accountAndSync`, `.general`, `.languageSetting`, `.notifications`, `.privacySettings`, `.systemPermissions`, `.resumePurchases`, `.helpFeedback`, `.recommendFriends`, `.about`, `.personalInfoChecklist` | P10-S01 / P12 / P13 / P14 / P15 / P16 / P17 / P18 / P19 |
| General rows | `settings.general.newCardsAutosaved`, `.fontSize`, `.recognitionLanguages`, `.showGroupSettings`, `.saveCardImage`, `.sortOrder`, `.displayOrder`, `.clearYourSpace`, `.appLock` | P11-S01 |
| General toggles | `settings.general.showGroupSettings.toggle`, `settings.general.saveCardImage.toggle` | P11-S01 |

The `TODO(P##-S##)` comment sits directly above each empty action so the next change can find it by state ID.

### D8 — Files touched

- `CamCard Copy/Features/Shell/RootView.swift` (modified) — switch cases return `HomeView`, `ToolsView`, `SettingsView`; CardHolder case unchanged.
- `CamCard Copy/Features/Shell/HomeView.swift` (new) — P00-S01 chrome.
- `CamCard Copy/Features/Shell/ToolsView.swift` (new) — P30-S01/S02 panes and tiles.
- `CamCard Copy/Features/Shell/SettingsView.swift` (new) — P10-S01 root; also holds the private inert row/premium/sign-in card types.
- `CamCard Copy/Features/Shell/SettingsGeneralView.swift` (new) — P11-S01 read-only screen.
- `CamCard Copy/Features/Shell/PlaceholderView.swift` (deleted) — no remaining references after `RootView` stops using it.
- `CamCard Copy/Features/CardHolder/CardHolderView.swift` (modified) — one `.topBarLeading` bell toolbar item; list, empty state, search pill and ⊕ untouched.
- `CamCard CopyUITests/T21ShellPlaceholderUITests.swift` (new) — placeholder presence and inertness tests.
- `openspec/changes/add-shell-placeholders/*` (planning artifacts) and `docs/ai-log.md` (append after archive, per project rules).

`project.pbxproj`, `Info.plist`, `AppTab`, `MainTabBar`, `BusinessCard`, `CardRecord`, `CardRepository`, `CardHolderViewModel`, `CardDetailView`, persistence, scan, EditCard, album and recognition files are **not** touched.

### D9 — Interfaces that stay unchanged

- `RootView(repository:)` signature and ownership of `selectedTab` / `isScanPresented`.
- `MainTabBar` identifiers `tab.home`, `tab.cardHolder`, `tab.scan`, `tab.tools`, `tab.settings` and the scan cover behavior.
- `CardRepository`, `CardRecord`, `CardHolderViewModel`, `CardDetailView`, `LaunchConfiguration`, `StoreBootstrap`, `SeedData`.
- Capture, detection, album and Edit Card types.

### D10 — Test approach

`T21ShellPlaceholderUITests` launches with `-uiTestEmptyStore` and, per screen, asserts button-like controls with `app.buttons[id].waitForExistence` and the two General toggles with `app.switches[id]`, taps them, then asserts the screen is unchanged (same nav bar / same placeholder text / no `sheet`). Use `app.staticTexts[...]` only for plain `Text` such as section headers, values and footers: text inside a `Button` label is usually not exposed as a static text, so control labels are matched through the owning button identifier. Settings root rows below the fold are reached with `app.swipeUp()` before asserting, and "Help and Feedback" is always tapped by `settings.row.helpFeedback`, never by text, because it is both a section header and a row. Toggles assert they exist and that tapping leaves their value unchanged.

Run the project's exact test command, adding `-only-testing:<target>/<suite>` for targeted runs, writing output to `build/test-output.log`, and reading results from that file:

```
xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17"
```

Require `** TEST SUCCEEDED **` in the output before calling a run green.

## Risks / Trade-offs

- [T01, T02 or T03T20 break on `placeholder.home`] → Keep the identifier on the visible "My Digital Card" text (D1); run those three suites first after wiring Home.
- [Reference uses artwork that we cannot reproduce] → Match layout, spacing and exact text only; all visuals are SF Symbols or plain shapes; record this in the T21 artwork scenario.
- [Settings root content is taller than one screen] → T21 scrolls before asserting lower sections; identifiers are used rather than coordinates.
- [Tapping an inert row could still pop navigation via `List` selection] → Inert rows are `Button`s with empty actions, not `NavigationLink`s; only "General" is a link.
- [Parallel `add-card-recognition` changes] → No file overlap by design (see D8); if a merge conflict appears in `RootView` or `CardHolderView`, resolve by keeping both changes' edits side by side, and stop if anything outside D8 is touched.
- [General keeps the custom tab bar and shows a "Settings" back title] → Accepted deviations: P11-S01 shows no tab bar and a bare back chevron, but `MainTabBar` lives in `RootView` outside the navigation stack and SwiftUI's default back button is titled "Settings". Do not change `RootView` or `MainTabBar` for this; record both deviations in the manual check. The "General returns to Settings" scenario still holds.
- [`PlaceholderView` deletion] → Confirm no other references with a search before deleting; if a reference appears, keep the type and report instead of deleting.

## Open Questions

None. The two unreadable details in the references are handled as follows: the third Smart sync tile label reads "Salesforce" after closer inspection (the trailing marks are the underlying photo, not text), and the provider icon row uses SF Symbols because brand icons are forbidden.
