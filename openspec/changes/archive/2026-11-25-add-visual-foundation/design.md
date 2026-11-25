# Design

## Context

See proposal.md, Why. Current state:

- Every screen styles itself with iOS defaults (`.headline`, `.subheadline`, `Color(.systemGroupedBackground)`, `Color.purple`). On iOS 27, `ToolbarItem` buttons get a glass circle automatically (seen on CardHolder's bell and ⊕ and on Edit Card's buttons).
- `RootView` switches between `HomeView`, `CardHolderView`, `ToolsView` and `SettingsView` above a custom `MainTabBar`. CardHolder, Tools and Settings each own a `NavigationStack`; Home has none.
- No shared route list exists. Pushes happen through view-specific `NavigationLink`s (`CardRecord` → `CardDetailView`, Settings → `SettingsGeneralView`).
- Reference screenshots are 620 × 1312 px device mockups of an iPhone 15 (393 pt wide). The screen area is about 604 px wide, about 1.54 px per pt. Colors were sampled and type sizes estimated from cap heights. Expect about ±1 pt on sizes.

## Goals / Non-Goals

**Goals:**

- One set of tokens and building blocks that the three milestone 2 changes and the milestone 3 scan work all use, so every screen matches the others.
- A route list that lets `polish-home-cardholder`, `add-settings-pages` and `add-tools-messages-digital-card` run in parallel worktrees **without editing the same files** (D7).
- Zero behavior change outside the tab bar's look. Existing UI tests pass unedited.

**Non-Goals:**

- Restyling any screen body. Each feature change adopts the components for its own screens.
- Pixel-perfect certainty. Sizes are within about ±1 pt of the estimate; a visual check against the screenshot decides.

## Decisions

### D1 — Tokens live in `Support/Theme/` as plain static values

`CCColor` (an enum of `static let` `Color` values built from hex) and `CCFont` (an enum of `static let` `Font` values) in `CamCard Copy/Support/Theme/CCColor.swift` and `CCFont.swift`. A `Color(hex:)` initializer lives in `CCColor.swift`. `CCColor.hex(_:)` returns each token's hex string so `ThemeTests` can assert the measured values without rendering.

*Alternative:* an asset catalog color set. Rejected: hex values in code are diffable and testable, and dark variants aren't needed (D4).

### D2 — Measured values (source of truth for this change)

| Token | Value | Sampled from |
|---|---|---|
| `headerTint` | `#F3F7F8` | P00-S01, P01-S01 header |
| `sheet` | `#FFFFFF` | P00-S01, P01-S01 sheet |
| `groupedBackground` | `#F0F0F0` | P05-S01 page |
| `groupedCard` | `#FAFAFA` | P10-S01a rows |
| `iconInk` | `#1C3F64` | P00-S01 bell, P01-S01 ⊕, P30-S01 Help |
| `textPrimary` | `#151314` | P01-S01 title |
| `textSecondary` | `#989898` | P01-S01 helper, P05-S01 subtitle |
| `sectionHeader` | `#5F5E5E` | P10-S01a "APP SETTINGS" |
| `separator` | `#EAEAEA` | P06-S01 button border |
| `accent` | `#50A6F8` | P30-S01 underline, P05-S01 "Save" (≈`#5DACF7`) |
| `tabSelected` / `tabUnselected` | `#1E1E1E` / `#989898` | P01-S01 tab bar |
| `scanGradient` | `#534EF6` → `#873EF6`, leading → trailing | P00-S01 scan button |
| `premiumGradient` | `#EF8C44` → `#F4BA47` | P10-S01a "Upgrade +" |
| `premiumCard` | `#FEF4D8` | P10-S01a Premium card |

| Font role | Size / weight | Example |
|---|---|---|
| `pageTitle` | 24 regular | "Tools", "Settings" |
| `navTitle` | 18 regular | "CardHolder", "Edit Card", "Messages" |
| `sectionTitle` | 18 medium | "My Digital Card", "Premium" |
| `rowEmphasis` | 16 medium | "No cards", "Recommend" |
| `row` | 15 regular | "Account and Sync", "Full Name" |
| `sectionHeader` | 14 regular | "APP SETTINGS" |
| `secondary` | 13 regular | helper text, "AI Summary" |
| `tabLabel` | 10 regular | "Home" |

### D3 — Fixed sizes, not Dynamic Type

`CCFont` uses `Font.system(size:weight:)`. This matches the reference at the default text size, which is the goal.

*Alternative:* scale with `UIFontMetrics`. Rejected for now: it breaks the pixel match at the default size whenever the simulator's size category differs, and CamCard did not appear to scale (ASSUMPTION). Recorded as a known accessibility trade-off (see Risks).

### D4 — Light appearance only

`.preferredColorScheme(.light)` on the `WindowGroup` root in `MyApp.swift`.

*Alternative:* dark variants for every token. Rejected: dark mode was never captured, so any dark palette would be invented.

### D5 — Shared building blocks in `Support/Theme/CCComponents.swift`

- `CCTintedHeaderLayout<Header, Content>`: a `VStack(spacing: 0)` with the header on `headerTint` (extending under the status bar) and the content on a `sheet` background clipped with `UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16)`.
- `CCIconButton(systemName:identifier:label:action:)`: a `.buttonStyle(.plain)` button drawing the symbol at 20 pt in `iconInk`, with a 44 × 44 pt hit area and no background.
- `View.ccPushedNavigationBar(title:)`: hides the system back button (`.navigationBarBackButtonHidden(true)`). It adds a leading `ToolbarItem` holding a `CCIconButton("chevron.left")` that calls `dismiss()`, and a `.principal` `Text(title).font(CCFont.navTitle)`. Both toolbar items use `.sharedBackgroundVisibility(.hidden)` so iOS 27 draws no glass.
- `CCPlaceholderPage(title:stateID:)`: a white page with `ccPushedNavigationBar(title:)`, the text "Not built yet" in `secondary`, and the state ID. Accessibility identifier `placeholder.route.<stateID>`.

*Alternative:* a fully custom header view in place of the system navigation bar. Kept as the fallback if `.sharedBackgroundVisibility(.hidden)` still leaves a glass background on iOS 27. Task 2.2 checks this in the simulator before anything else depends on it.

### D6 — Tab bar restyle in place

`MainTabBar` keeps its structure and identifiers. Changes:

- Background `CCColor.sheet` with a 0.5 pt `separator` line on top.
- Labels `CCFont.tabLabel`. Colors `tabSelected` / `tabUnselected`.
- `AppTab.selectedSystemImage`: `house.fill`, `person.crop.rectangle.stack.fill`, `folder.fill`, `gearshape.fill`.
- Each tab button adds `.accessibilityAddTraits(.isSelected)` when selected (for T22).
- Scan button: 44 pt circle with a `LinearGradient` over `scanGradient`, white `camera.fill` at 18 pt. Tab icons 18 pt with 6 pt spacing to the label. The row is bottom-aligned with 1 pt bottom padding above the safe area, so icons, labels and the button share a bottom edge about 35 pt above the screen bottom. (Corrected 2026-11-25 after the 5.2 visual check: the first version used a 56 pt button, centered, which sat about 11 pt too high. P00-S01 measures a 43 pt button with its center 58 pt and the Home label 41 pt above the screen bottom.)

The CardHolder outline icon stays `person.crop.rectangle.stack`. The reference's folder-with-person glyph is CamCard artwork.

### D7 — Route list and file ownership for the parallel changes

`Features/Shell/AppRoute.swift`:

```swift
enum AppRoute: Hashable {
    case messages, bizTips
    case createCard(step: Int)            // 1...3
    case settings(SettingsPage)           // see below
    case login, paywall
    var title: String { … }               // "Messages", "Upgrade Plans", …
    var stateID: String { … }             // "P31-S01", …
}
enum SettingsPage: CaseIterable, Hashable {
    case accountSync, language, notifications, privacy, permissions,
         helpFeedback, inviteFriends, about, piChecklist
}
extension View { func appRoutes() -> some View }  // .navigationDestination(for: AppRoute.self)
```

`appRoutes()` dispatches each route to a destination function in the feature folder that owns it:

| Route(s) | Destination file (stub created here) | Owned later by |
|---|---|---|
| `messages`, `bizTips` | `Features/Messages/MessagesRoutes.swift` | `add-tools-messages-digital-card` |
| `createCard` | `Features/DigitalCard/DigitalCardRoutes.swift` | `add-tools-messages-digital-card` |
| `settings`, `login`, `paywall` | `Features/Settings/SettingsRoutes.swift` | `add-settings-pages` |

Each stub returns `CCPlaceholderPage(title: route.title, stateID: route.stateID)` with a `TODO(P##-S##)` marker.

`.appRoutes()` is applied once inside each existing `NavigationStack`: CardHolder, Tools and Settings. `RootView` wraps `HomeView` in a new `NavigationStack` with `.toolbar(.hidden, for: .navigationBar)` on Home's root, so Home looks unchanged. **No control pushes a route in this change.**

File ownership in milestone 2, after this change merges:

| Change | Files it may edit |
|---|---|
| `polish-home-cardholder` | `HomeView`, `CardHolderView`, `CardHolderViewModel`, `CardDetailView` |
| `add-settings-pages` | `SettingsView`, `SettingsGeneralView`, `Features/Settings/*` |
| `add-tools-messages-digital-card` | `ToolsView`, `Features/Messages/*`, `Features/DigitalCard/*` |

Shared files (`AppRoute.swift`, `Support/Theme/*`, `MainTabBar`, `RootView`) are frozen for milestone 2. A change that needs one edited stops and tells Opus, who makes the edit on `main` between merges.

*Alternative:* one `AppRouteDestination` switch that all three changes edit. Rejected: guaranteed merge conflicts.

### D8 — `openspec/config.yaml`

Quote the second `rules.tasks` item. Replace the hard rule "Out of scope: login, premium/paywall, digital card creation, Tools tab features, AI assistant, sync, messages. Tabs may exist as placeholders." with: "Screens observed in reference/screenshots are replicated visually. Those marked Out or Reference in observations.md are inert visual copies: they never simulate login, payment, sync, AI answers or network calls." The artwork rule stays.

### D9 — Tests

- `ThemeTests` (unit): every `CCColor.hex` token equals D2. Every `CCFont` role reports the D2 size and weight, through a parallel `CCFont.spec` table of `(size, weight)` that the fonts are built from.
- `AppRouteTests` (unit): all routes (`messages`, `bizTips`, `createCard(1...3)`, every `SettingsPage`, `login`, `paywall`) have a non-empty title and a state ID matching `^P\d{2}-S\d{2}$`. Titles equal the reference text: "Messages", "Biz Tips", "Create your card", "Account and Sync", "Language setting", "Notifications", "Privacy Settings", "System permissions", "Help and Feedback", "Recommend to Friends", "About", "Personal Information Collection Checklist", "Login via email", "Upgrade Plans".
- `T22VisualFoundationUITests` (UI):
  1. Selecting each tab marks only that tab button selected, and all four labels stay.
  2. The scan button opens the camera with Close.
  3. The Home bell, "Create New Card", the CardHolder bell and the Settings "Language setting" row still open nothing. This guards "no control is wired".
- Visual check (Haiku, in the simulator): compare the tab bar with the bottom 120 px of P00-S01, and record results in `docs/manual-checks/add-visual-foundation.md`. The barebones page and pushed-page bar can't be reached from the UI in this change. They get their visual check in the first feature change that wires a route.

Existing files that stay unchanged: every model, repository, recognition, scan, album, Edit Card and Card Saved file, plus `HomeView`, `ToolsView` and `SettingsView` apart from their single `.appRoutes()` line.

## Risks / Trade-offs

- [`.sharedBackgroundVisibility(.hidden)` might not remove the iOS 27 glass on every toolbar placement] → Task 2.2 checks it in the simulator first. The fallback is D5's custom header, decided before the other tasks start.
- [Fixed sizes ignore the user's text size setting, an accessibility regression] → Recorded as ASSUMPTION/trade-off. It can be revisited after the pixel-match milestones by scaling the `CCFont` table with `UIFontMetrics`.
- [Estimated sizes are off by about 1 pt] → The visual check compares against the screenshot. Adjusting a size changes only the `CCFont.spec` table and its test.
- [Wrapping Home in a `NavigationStack` could shift its layout] → The hidden navigation bar plus the T21 Home test and the visual check catch it.
- [Parallel changes need a shared-file edit] → The D7 rule: stop and escalate to Opus. Never edit a shared file in a worktree.

## Migration Plan

UI only. No data migration. Rollback means reverting the commit.
