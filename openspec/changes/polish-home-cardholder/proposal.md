# Proposal

## Why

Home (P00-S01) and CardHolder (P01-S01) are the first screens a user sees, and the milestone 1 audit found them furthest from the reference. They use iOS default type and backgrounds, glass circles around the CardHolder icons, and no tinted header with a white sheet. Their bells, crown and "Create New Card" are inert even though the screens they lead to are now planned. The list and detail also show the uncropped photo instead of the corrected card (audit bug 4). add-visual-foundation supplies the tokens, components and route list. This change applies them to Home and CardHolder and wires their routes.

## What Changes

- **Home restyle (P00-S01).** Header in the header tint: plain navy bell, a white "Search Card Holder" capsule, a gold crown and a navy stats icon. Two white promo cards on the tint with a tinted icon tile, 15 pt medium title and 13 pt secondary subtitle. A white sheet with rounded top corners holds "My Digital Card" (18 pt medium), an SF Symbol empty image, "No cards yet. Create a new one!" wrapped on two lines exactly as in the screenshot, and an outlined "Create New Card" capsule. Values are measured; see design D2.
- **Home wiring.** The bell pushes "Messages" (P31-S01), the crown pushes "Upgrade Plans" (P21-S01) and "Create New Card" pushes "Create your card" step 1 (P33-S01). Each route still shows the barebones placeholder page until its own change builds it. The search bar, stats icon and both promo cards stay inert with their `TODO(P##-S##)` markers. Home search can't reach CardHolder without a frozen shared-file edit (see design D6).
- **CardHolder restyle (P01-S01).** The navigation bar is in the header tint with a plain navy bell and ⊕ (no glass) and an 18 pt "CardHolder" title. A white full-width "Search" capsule sits on the tint, then a white sheet with rounded top corners with the "Cards" header, the empty state (SF Symbol, "No cards" 16 pt medium, helper text 13 pt secondary, about 272 pt wide) and the list.
- **CardHolder wiring.** The bell pushes "Messages" (P31-S01).
- **CardHolder list (P01-S02, P01-S03 not captured, ASSUMPTION).** Restyled rows: a card-ratio thumbnail, name 16 pt medium, company 13 pt secondary, and an inset `#EAEAEA` separator. Order stays newest first, as stored. Marked `TODO(P01-S02)` / `TODO(P01-S03)`.
- **Search (P01-S04, P01-S05, P01-S06 not captured, ASSUMPTION).** With at least one card, tapping "Search" turns the pill into a focused text field with "Cancel". Typing filters the list on name and company (case-insensitive, substring, trimmed). No match shows "No results". Cancel clears the query and restores the list. With no cards, "Search" stays inert, unchanged from T01.
- **⊕ menu (P01-S08 not captured, ASSUMPTION).** ⊕ opens a barebones menu with inert items "Scan card" and "Import from album", marked `TODO(P01-S08)`.
- **Corrected image (audit bug 4).** CardHolder thumbnails and the card detail show the stored corrected image when there is one, otherwise the original.
- **Card detail (P09-S01 not captured, ASSUMPTION).** The tokens' type and colors and the plain pushed-page back control. The content and order of fields are unchanged.

State IDs: P00-S01, P01-S01. Barebones with TODO: P01-S02, P01-S03, P01-S04, P01-S05, P01-S06, P01-S08, P09-S01. Wired routes: P31-S01, P21-S01, P33-S01 (placeholder pages).

Test IDs: T01, T12, T13 (regression), T15 (search, new), T21 and T22 (changed assertions, below), T24 (new: Home and CardHolder wiring and corrected image).

## Tests that change (needs user approval)

These existing assertions encode "inert" behavior that this change replaces. Nothing else in them changes.

1. `CamCard CopyUITests/T21ShellPlaceholderUITests.swift`, `testHomePlaceholdersExistAndAreInert`, the loop `for element in [search, bell, crown, stats, speech, accuracy, create] { element.tap(); assertStillOnHome(app) }`. It becomes a loop over `[search, stats, speech, accuracy]` only. For `bell`, `crown` and `create`, it taps, asserts a page was pushed (`nav.back` exists and `placeholder.home` is gone), taps `nav.back` and calls `assertStillOnHome(app)`.
2. `T21ShellPlaceholderUITests.testCardHolderBellIsInert`, after `bell.tap()`: `XCTAssertEqual(app.sheets.count, 0, "No sheet should open")`, `XCTAssertTrue(app.staticTexts["No cards"].exists, "CardHolder content should stay visible")` and `XCTAssertTrue(app.buttons["tab.cardHolder"].exists, …)`. These become: a page was pushed (`nav.back` exists and "No cards" is gone), tap `nav.back`, then "No cards" exists. The test is renamed `testCardHolderBellOpensMessages`.
3. `CamCard CopyUITests/T22VisualFoundationUITests.swift`, `testT22InertControlsStayInert`: the three blocks for `home.bell`, `home.digitalCard.create` and `cardholder.bell` (each asserts `placeholder.home` / "No cards" still visible and `XCTAssertFalse(app.buttons["nav.back"].exists)`). These three blocks are removed; T24 covers them. The "Language setting" block stays unchanged here. add-settings-pages removes that block; whichever of the two merges second deletes the then-empty test (Opus resolves it at merge).

Expected to stay unchanged, but checked first: `T01EmptyCardHolderUITests` lines 32–35. Tapping ⊕ now opens a menu, and "No cards" and the "CardHolder" navigation bar should still exist behind it. If the open menu blocks the next step (tapping "Search", line 37), the agent stops and reports rather than editing T01.

## Out of scope

- Group list, group filter and group delete (P01-S07, P01-S09, P01-S10) and select mode (P01-S11): milestone 4.
- Home search opening CardHolder search (P00-S03): needs a `RootView` or `AppRoute` edit, which are frozen during milestone 2 (design D6).
- Building Messages, Upgrade Plans and Create your card. Those belong to `add-tools-messages-digital-card` and `add-settings-pages`.
- Sorting options, section index and Sort/Display Order settings (P11-S01 is Reference).
- CamCard artwork (illustrations, the folder-with-person glyph). SF Symbols only.

## Capabilities

### New Capabilities

- `cardholder-search`: searching saved cards from CardHolder: entering and leaving search, matching on name and company, and the no-results state.

### Modified Capabilities

- `app-shell`: "Home tab content", "CardHolder top bar" and "CardHolder add control placeholder" are replaced (REMOVED + ADDED, because their "inert" scenarios no longer hold) by "Home tab content and entries", "CardHolder top bar with Messages entry" and "CardHolder add menu (P01-S08, ASSUMPTION)". Modified: "CardHolder empty state" (look; search inert only when empty), "CardHolder list" (row look, corrected-image thumbnail, order), "Read-only card detail" (corrected image, plain back control).

## Impact

- Modified: `CamCard Copy/Features/Shell/HomeView.swift`, `Features/CardHolder/CardHolderView.swift`, `Features/CardHolder/CardHolderViewModel.swift`, `Features/CardDetail/CardDetailView.swift`.
- New: `Features/CardHolder/CardHolderRow.swift`, `Features/CardHolder/CardHolderSearchBar.swift`.
- Tests: new `CamCard CopyTests/CardHolderSearchTests.swift`, `CamCard CopyUITests/T15SearchUITests.swift`, `CamCard CopyUITests/T24HomeCardHolderUITests.swift`. Changed: `T21ShellPlaceholderUITests.swift` and `T22VisualFoundationUITests.swift`, only the assertions listed above.
- Frozen and untouched: `AppRoute.swift`, `Support/Theme/*`, `MainTabBar.swift`, `RootView.swift`, the repository, models, and the scan and Settings/Tools files.
