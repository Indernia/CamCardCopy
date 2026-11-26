# Design

## Context

See proposal.md, Why. Current state:

- `HomeView` is a `ScrollView` on `Color(.systemGroupedBackground)` with iOS default fonts. `RootView` (frozen) hosts it in a `NavigationStack` with a hidden bar and `.appRoutes()`. Home has no repository.
- `CardHolderView` owns a `NavigationStack` with `.navigationTitle("CardHolder")`, toolbar bell and ⊕ (glass circles on iOS 27), a non-interactive search pill, a plain `List` with header "Cards", the empty state, and `CardRow` using `originalImage`. It already applies `.appRoutes()`. Rows push `CardRecord` to `CardDetailView`.
- `CardDetailView` shows `originalImage` and labelled values.
- `CardHolderViewModel` loads `repository.fetchAll()`, which is newest first.
- The frozen shared files supply `CCColor`, `CCFont`, `CCTintedHeaderLayout`, `CCIconButton`, `ccPushedNavigationBar(title:)`, `CCPlaceholderPage` (identifier `placeholder.route.<stateID>`, back button `nav.back`) and `AppRoute`.
- Existing UI tests rely on `app.navigationBars["CardHolder"]` (T01, T12, T18), `staticTexts["Search"]` on the empty screen (T01), the identifiers `home.*` and `cardholder.*`, and `staticTexts["No cards yet. Create a new one!"]` (T21).

## Goals / Non-Goals

**Goals:**

- Home and the empty CardHolder within about 2 pt of P00-S01 and P01-S01 at the default text size, using only the shared tokens.
- Wire the three Home routes and the CardHolder bell. Barebones search and ⊕ menu.
- No edits to frozen files. Only the listed test assertions change.

**Non-Goals:**

- Group, select-mode and sort features (milestone 4).
- Building the destination pages.

## Decisions

### D1 — Measured layout (screen points; mockup scale 604 px / 393 pt, screen origin about 7 pt into the mockup)

| Element | P00-S01 Home | Notes |
|---|---|---|
| Bell | center x ≈ 25, center y ≈ 69, 20 pt, `iconInk` | `CCIconButton` |
| Search capsule | x 50–306, y 53–84 (h ≈ 31), white, placeholder 15 pt `textSecondary` with magnifier | full capsule |
| Crown | center x ≈ 326, `crown.fill` 20 pt, gold `#F5C518` (ASSUMPTION: the artwork gradient isn't copied) | |
| Stats | center x ≈ 367, `chart.bar` 20 pt, `iconInk` | the reference glyph is CamCard artwork |
| Promo cards | y 107–230 (h ≈ 123), x 16–191 and 203–377 (gap 12), white, radius 14 | |
| Promo icon tile | 40 × 40, radius 10, tint `#EFF7FE` (speech) / `#F7F2FE` (accuracy), symbol 20 pt blue / purple | sampled |
| Promo title / subtitle | 15 pt medium `textPrimary` / 13 pt `textSecondary`, 16 pt inset | |
| Sheet | top y ≈ 247, radius 16, white to the tab bar | `CCTintedHeaderLayout` |
| "My Digital Card" | x 16, center y ≈ 276, `sectionTitle` (18 medium) | |
| Empty symbol | `rectangle.on.rectangle` 64 pt `textSecondary`, center y ≈ 455 | no artwork |
| "No cards yet." / "Create a new one!" | two centered lines, center y ≈ 551 / 571, 15 pt `textSecondary` | D4 |
| "Create New Card" | 198 × 47 capsule, top y ≈ 605, 1 pt `#E2E2E2` stroke, white fill, `plus` + 17 pt regular `textPrimary` | |

| Element | P01-S01 CardHolder | Notes |
|---|---|---|
| Bar | header tint, title "CardHolder" center y ≈ 69, `navTitle` 18 regular | D3 |
| Bell / ⊕ | plain `iconInk` 20 pt, leading / trailing 16 pt inset | `CCIconButton`, `plus.circle` |
| Search capsule | x 16–377, y 107–146 (h ≈ 38), white, placeholder "Search" 15 pt `textSecondary` | |
| Sheet | top y ≈ 163, radius 16 | |
| "Cards" | x 16, center y ≈ 188, 16 regular `textPrimary` | not a grey list header |
| Empty symbol | `person.crop.rectangle.stack` 56 pt `textSecondary`, centered around y ≈ 290 | no artwork |
| "No cards" | center y ≈ 371, `rowEmphasis` (16 medium) | |
| Helper text | center y ≈ 419, 13 pt `textSecondary`, centered, max width 272 | wraps to 3 lines like the reference |

**Fix round 1 corrections (re-measured with y_pt = y_px / 1.537 + 3.1, x_pt = (x_px - 8) / 1.537).** The first-pass y values above were about 10 pt too high for the top-anchored items. Corrected: Home bell, search and icons centre y ≈ 78 (bell 16 pt, stats 15 pt, crown 20 pt; the crown and stats are right-anchored because iPhone 17 is 402 pt wide, not 393); promo title text top ≈ 190; sheet top ≈ 257; "My Digital Card" text top ≈ 278; empty text lines top ≈ 556 and ≈ 575; "Create New Card" capsule top ≈ 615. CardHolder: bar glyphs and title centre y ≈ 78 (bell 13 pt and ⊕ 16.5 pt in the toolbar, which renders symbols larger than a plain view; ⊕ right-anchored), search capsule top ≈ 117, sheet top ≈ 173, "Cards" text top ≈ 192, "No cards" text top ≈ 375, helper text top ≈ 404. The SF Symbol empty illustrations are smaller than the CamCard artwork, so they are centred on the artwork's centre and the text below is placed at the reference's absolute y rather than at the reference's distance from the symbol.

The Haiku visual check (task 5.2) confirms the values. Adjustments stay local to this change's files.

### D2 — Home layout structure

`HomeView` becomes `CCTintedHeaderLayout { header + promo row } content: { ScrollView { digital card section } }`. Every existing identifier and accessibility label is kept: `home.content`, `home.bell`, `home.search`, `home.crown`, `home.stats`, `home.promo.*`, `home.digitalCard.create`, and `placeholder.home` on the "My Digital Card" text.

### D3 — CardHolder keeps the system navigation bar, restyled

T01, T12 and T18 find `app.navigationBars["CardHolder"]`, so the bar stays. Approach:

- `.navigationTitle("CardHolder")` keeps the accessibility identity.
- `.toolbarBackground(CCColor.headerTint, for: .navigationBar)` with `.toolbarBackgroundVisibility(.visible, for: .navigationBar)`.
- A `.principal` `Text("CardHolder").font(CCFont.navTitle)`.
- Leading and trailing `ToolbarItem`s hold `CCIconButton`s with `.sharedBackgroundVisibility(.hidden)`.

Below the bar, `CCTintedHeaderLayout` holds the search capsule as its header and the sheet as content. The sheet has a custom "Cards" header plus a `List(.plain)` with `.scrollContentBackground(.hidden)`.

*Alternative:* hide the system bar and draw a custom header. Rejected: it would break three suites' `navigationBars["CardHolder"]` assertions.

### D4 — Two-line "No cards yet." text with the single accessibility string

A `VStack` of `Text("No cards yet.")` and `Text("Create a new one!")` with `.accessibilityElement(children: .ignore)`, `.accessibilityLabel("No cards yet. Create a new one!")` and `.accessibilityAddTraits(.isStaticText)`. T21's `staticTexts["No cards yet. Create a new one!"]` keeps matching.

*Alternative:* one `Text` with `\n`. Rejected: its label would include the newline and break T21.

### D5 — Wiring with `NavigationLink(value:)`

Home bell → `AppRoute.messages`, crown → `.paywall`, "Create New Card" → `.createCard(step: 1)`, CardHolder bell → `.messages`. Each uses `NavigationLink(value:)` with `.buttonStyle(.plain)` and the same label views, identifiers and accessibility labels as before. The stacks' existing `.appRoutes()` resolves them. For the CardHolder bell inside a `ToolbarItem`, a `NavigationLink(value:)` labelled with the bell image.

### D6 — Home search stays inert

Opening CardHolder search from Home needs either a tab switch (owned by frozen `RootView`) or a search route (frozen `AppRoute`) plus a repository, which Home doesn't have. It stays inert with `TODO(P00-S03)`. Opus can add a route between merges later if wanted.

### D7 — Search (`cardholder-search`)

- A pure, testable `CardHolderSearch.filter(_ cards: [CardRecord], query: String) -> [CardRecord]` in `CardHolderSearchBar.swift`. It trims the query, uses `localizedCaseInsensitiveContains` on `name` and `company`, keeps the input order, and returns everything for an empty query.
- `CardHolderViewModel` gains `var query = ""`, `var isSearching = false` and `var visibleCards: [CardRecord]` (filtered `cards`).
- `CardHolderSearchBar` shows the capsule. It's tappable only when `!cards.isEmpty`. When searching, a `TextField("Search", text:)` with `@FocusState`, identifier `cardholder.search.field`, plus a "Cancel" button (`cardholder.search.cancel`). The capsule keeps identifier `cardholder.search` and its "Search" static text when not searching.
- No match: `Text("No results")` (identifier `cardholder.search.noResults`, `TODO(P01-S06)`).

### D8 — ⊕ menu

`Menu` labelled with the plain ⊕ (`cardholder.add`), containing `Button("Scan card") {}` and `Button("Import from album") {}`, both `// TODO(P01-S08)`.

*Risk:* an open menu might intercept T01's next tap. See proposal "Expected to stay unchanged". The agent stops if it does.

### D9 — Corrected image first, decoded off main

`CardHolderRow.swift` adds `func cardDisplayImageData(_ card: CardRecord) -> Data?` (`processedImage ?? originalImage`) and the restyled row:

- 64 × 40 thumbnail, radius 6, decoded with the existing `CardImageThumbnail.make(from:maxPixelSize: 200)` in `.task(id: card.id)`
- name 16 medium, company 13 secondary
- separator inset 92 pt, `#EAEAEA`
- identifier `card.row` kept on the `NavigationLink`

`CardDetailView` uses the same helper with `maxPixelSize: 1500` and `.ccPushedNavigationBar(title: "")`. Its field labels use 13 pt secondary and its values 15 pt primary.

### D10 — Tests

- `CardHolderSearchTests` (unit):
  - the filter on name, company, case, whitespace-only and no match, with order preserved
  - `cardDisplayImageData` prefers processed, then original, then nil
- `T15SearchUITests` (UI, `-uiTestEmptyStore -uiTestSeedCards`):
  - opening search
  - "ortiz" → only Blair Ortiz
  - "FABRI" → only Casey Lund
  - "zzqx" → "No results"
  - Cancel restores all 3
- `T24HomeCardHolderUITests` (UI):
  - Home bell / crown / Create New Card each push a page: assert `nav.back` exists and `placeholder.home` is gone, then `nav.back` returns to Home. Do NOT assert `placeholder.route.*` identifiers: the real Messages, Upgrade Plans and Create Card pages from the parallel changes replace those placeholders, and the test must pass either way
  - CardHolder bell pushes P31-S01 and back returns
  - ⊕ menu shows both items and tapping one opens nothing
- Changed assertions in T21 and T22 exactly as listed in the proposal.
- Visual check (Haiku): Home vs P00-S01 and empty CardHolder vs P01-S01 using the D1 table. Flow check against `reference/state-diagram.md` (P00_S01 → P01_S01 tab, P00_S01 → P31_S01 bell, P00_S01 → P33_S01 Create New Card).

### Unchanged interfaces

`CardRepository`, `CardRecord`, `AppRoute`, `CCColor` / `CCFont` / `CCComponents`, `MainTabBar`, `RootView`, `CardImageThumbnail`, and every existing identifier on Home and CardHolder.

## Risks / Trade-offs

- [The tinted system bar might show a hairline or blur that differs from the reference] → Use `.toolbarBackground` with the solid tint. If a hairline remains, accept it and note it in the visual check.
- [An open ⊕ menu blocks T01's next tap] → Stop and report. Don't edit T01 without approval.
- [Search active only with cards differs from CamCard (unknown)] → ASSUMPTION, recorded. It keeps T01 and its spec unchanged.
- [Shared-file edit needed] → Stop and escalate (add-visual-foundation D7 rule).
