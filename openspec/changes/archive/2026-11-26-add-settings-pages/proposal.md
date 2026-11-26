# Proposal

## Why

Settings is the largest group of screenshots still built as unstyled iOS lists. The root (P10-S01) and General (P11-S01) use default type and system grouped colors, and the ten screens behind its rows (P12–P21) don't exist. Every row except General opens nothing. Under the agreed scope, every observed screen gets an inert visual copy, and add-visual-foundation now provides the tokens, the pushed-page bar and the `.settings` / `.login` / `.paywall` routes, so these pages can be built.

## What Changes

- Restyle the Settings root to match P10-S01a/b:
  - a pinned 24 pt "Settings" header that stays while the list scrolls under it
  - a `#FAFAFA` sign-in card with six 41 pt provider tiles
  - a `#FEF4D8` Premium card with an orange-gradient "Upgrade +" and four items on `#FCE8AD` circles
  - `#FAFAFA` grouped rows about 50 pt tall with 16 pt insets
  - the section headers "APP SETTINGS", "Help and Feedback" and "ABOUT CAMCARD" in `#5F5E5E`
- Restyle General (P11-S01): a `#F0F0F0` page, white rows, grey values `#A0A0A0`, the plain "‹" bar and a centered "General" title. Rows, values and toggles stay read-only and inert.
- Wire every Settings row to its page: "Account and Sync", "Language setting", "Notifications", "Privacy Settings", "System permissions", "Help and Feedback", "Recommend to Friends", "About" and "Personal Information Collection Checklist". "Sign in to access more features" opens Login via email (P20-S01). "Upgrade +" and the four Premium items open Upgrade Plans (P21-S01; reaching it from Settings is an ASSUMPTION, since P21 was captured from Card Saved). "Resume In-APP Purchases" stays inert: it is a purchase action and has no captured screen.
- Build inert visual copies of P12 Language setting, P13 Notifications, P14 Privacy Settings, P15 System permissions, P16 Help and Feedback, P17 Recommend CamCard, P18 About, P19 the collection checklist, P20 Login via email and P21 Upgrade Plans. Each uses the exact observed text. "Account and Sync" was not captured, so it keeps the barebones "Not built yet" page with `TODO(P10-S01)`.
- Pushed Settings pages hide the tab bar, as every reference screenshot of a pushed page does. **This needs one edit to frozen shared files (`CCComponents.swift`, `RootView.swift`), which Opus makes on `main` before this change is applied** (design D2).

State IDs covered: P10-S01 (a, b), P11-S01, P12-S01, P13-S01, P14-S01, P15-S01, P16-S01, P17-S01, P18-S01, P19-S01, P20-S01, P21-S01. Test IDs: T21 (Settings tests, updated), T22 (Language-setting assertion, updated), T25 (new: Settings pages).

## Tests that change (needs user approval)

These existing assertions encode "every Settings row is inert". This change makes the rows open their pages, so the assertions must change. No other assertion in those files changes.

1. `T21ShellPlaceholderUITests.testSettingsPlaceholdersExistAndAreInert`, the loop
   `for element in [signIn, upgrade] + premiumItems { element.tap(); XCTAssertEqual(app.sheets.count, 0, "No sheet should open"); XCTAssertTrue(signIn.exists, "Settings content should stay visible") }`
   becomes: tap each element, assert its page appears (`settings.page.login` for sign-in, `settings.page.paywall` for Upgrade and the four Premium items), tap `nav.back`, then assert `signIn` exists again.
2. The same test's lower-row loop
   `for row in lowerRows { row.tap(); XCTAssertEqual(app.sheets.count, 0, "No sheet should open"); XCTAssertTrue(app.buttons["tab.settings"].exists, "Settings should stay the current screen") }`
   becomes: `resumePurchases` keeps both assertions unchanged. Each other lower row asserts its page identifier, taps `nav.back`, and asserts `tab.settings` exists again. The tab bar is hidden on pushed pages, so the old assertion would fail while the page is open.
3. The test name `testSettingsPlaceholdersExistAndAreInert` is renamed `testSettingsRowsExistAndOpenTheirPages`.
4. `T22VisualFoundationUITests.testT22InertControlsStayInert`: the last block (tap `settings.row.languageSetting`, `XCTAssertTrue(app.buttons["settings.signIn"].exists, "Language setting opens nothing")`, `XCTAssertFalse(app.buttons["nav.back"].exists)`) is deleted. T25 covers the Language setting page instead. The Home and CardHolder blocks in that function are left for their own changes.

`testSettingsGeneralIsReadOnlyAndInert` is expected to pass unchanged. General keeps `.navigationTitle("General")` so `app.navigationBars["General"]` still resolves, and "‹" is the bar's first button. If it fails, the agent stops and reports.

## Out of scope

- Any working setting: language switching, notification or AI consent toggles, ad tracking, app lock, autosave to Contacts. Toggles show their observed state and ignore taps (design D4).
- Login, registration, third-party sign-in, payments, plan selection, restoring purchases, sharing invitations, rating the app, links and network calls. Their controls are inert.
- CamCard artwork: the coin, the phone mockup, the help category icons and brand logos. SF Symbols, letters and plain shapes stand in.
- The FAQ answer pages behind the P16 questions and the "Contact Us" flow (not captured).
- Home, CardHolder, Tools, Messages and the scan flow.

## Capabilities

### New Capabilities

- `settings-pages`: the inert visual copies of the screens opened from Settings (P12–P21) and their navigation back to Settings.

### Modified Capabilities

- `app-shell`: "Settings root content" (rows now open their pages; restyled per P10-S01) and "Settings General read-only screen" (restyled per P11-S01; still read-only).

## Impact

- **Modified:** `CamCard Copy/Features/Shell/SettingsView.swift`, `CamCard Copy/Features/Shell/SettingsGeneralView.swift`, `CamCard Copy/Features/Settings/SettingsRoutes.swift`.
- **New:** `CamCard Copy/Features/Settings/` page files (design D5), `CamCard CopyUITests/T25SettingsPagesUITests.swift`.
- **Tests edited (with approval):** `T21ShellPlaceholderUITests.swift` (Settings test only) and `T22VisualFoundationUITests.swift` (Language block only).
- **Prerequisite on `main` before apply (Opus, shared files):** `CCComponents.swift` and `RootView.swift` tab-bar hiding (design D2).
- No model, persistence, recognition or scan code is touched.
