# Design

## Context

See proposal.md, Why. Current state after add-visual-foundation:

- `ToolsView` owns a `NavigationStack` with `.appRoutes()`, a fixed header (`tools.title`, `tools.help`), a custom selector (`tools.segment.recommend` / `tools.segment.smartSync`) and a 2-column `LazyVGrid` of 150 pt gradient tiles (`tools.recommend.*`, `tools.sync.*`). T21 asserts the identifiers, inertness, and that the title stays fixed while the grid scrolls.
- `messagesDestination(for:)` in `Features/Messages/MessagesRoutes.swift` and `digitalCardDestination(for:)` in `Features/DigitalCard/DigitalCardRoutes.swift` return `CCPlaceholderPage`. Shared and frozen: `AppRoute` (`.messages`, `.bizTips`, `.createCard(step:)`), `CCColor`, `CCFont`, `CCComponents` (`ccPushedNavigationBar`, `CCIconButton`), `MainTabBar`, `RootView`, `LaunchConfiguration`.
- Nothing pushes `.messages` or `.createCard` yet. The Home and CardHolder bells and "Create New Card" belong to `polish-home-cardholder`.
- Measurements: reference mockups are 620 × 1312 px for a 393 pt-wide screen, at 604/393 ≈ 1.537 px per pt. x is measured from the screen's left edge (mockup x = 8), y from the screen top. Font sizes come from cap height ÷ 0.705, so expect about ±1 pt.

## Goals / Non-Goals

**Goals:**

- Tools, Messages, Biz Tips and Create your card match their screenshots within about 1 pt and the measured colors.
- Only this change's files are edited (D1), so it can run in parallel with `add-settings-pages` and `polish-home-cardholder`.
- The new screens are testable before anything else links to them (D10).

**Non-Goals:**

- Copying CamCard artwork: tile photos, the Biz Tips banner illustration, template card designs, the Google "G" logo.
- Any behavior beyond step navigation. Nothing is stored, sent or fetched.

## Decisions

### D1 — Files

| File | Change |
|---|---|
| `Features/Shell/ToolsView.swift` | Restyle (D3). `NavigationStack(path:)` plus the DEBUG route hook (D10). Keeps every identifier. |
| `Features/Messages/MessagesRoutes.swift` | `.messages` → `MessagesView()`, `.bizTips` → `BizTipsView()` |
| `Features/Messages/MessagesView.swift` (new) | P31-S01 (D4) |
| `Features/Messages/BizTipsView.swift` (new) | P32-S01 (D5) |
| `Features/Messages/UITestRouteHook.swift` (new) | DEBUG-only argument parser (D10) |
| `Features/DigitalCard/DigitalCardRoutes.swift` | `.createCard(step:)` → `CreateCardStepView(step:)` |
| `Features/DigitalCard/CreateCardStepView.swift` (new) | P33-S01/S02/S03 bodies (D6–D8) |
| `Features/DigitalCard/CreateCardComponents.swift` (new) | Progress dashes, heading, filled field, capsule buttons (D6) |
| `CamCard CopyTests/UITestRouteHookTests.swift` (new) | D9 |
| `CamCard CopyUITests/T23ToolsMessagesDigitalCardUITests.swift` (new) | D9 |

Unchanged: everything else, including `AppRoute`, the theme files, `MainTabBar`, `RootView`, `LaunchConfiguration` and every existing test.

### D2 — Shared-file dependency: pushed-page chevron color and bar divider (Opus edits `main` before this change starts)

> **Superseded by the prerequisite change `fix-pushed-page-chrome`** (Opus implements it on `main` before this change starts): `navInk` #232323, `navDivider` #F1F1F1, and tab-bar hiding through an observable `TabBarVisibility` counter that `ccPushedNavigationBar` updates. This change depends on it and must not edit those shared files. The text below is kept as the original finding.

Every pushed page in the reference draws its back chevron in **`#232323`**: P31-S01, P32-S01, P33-S01, P12-S01, P20-S01 and P11-S01 all sample `#232323`/`#242424`. `ccPushedNavigationBar` currently uses `CCColor.iconInk` (`#1C3F64`, which is right only for the Home/CardHolder/Tools top-level icons). The pages also show a hairline under the white navigation bar: `#F1F1F1`, about 0.5 pt, at y ≈ 97.6 pt.

Proposed shared edit, which Opus makes on `main` and both this change and `add-settings-pages` inherit:

- Add `CCColor.navInk = #232323` and `CCColor.navDivider = #F1F1F1`, with `ThemeTests` extended.
- `ccPushedNavigationBar` draws the chevron in `navInk`, uses a white toolbar background, and draws a 0.5 pt `navDivider` line under the bar.

If Opus declines, this change still works; only the Haiku check reports a chevron-color difference.

### D3 — Tools (P30-S01, P30-S02) measured values

| Element | Value |
|---|---|
| "Tools" | `CCFont.pageTitle` (24 regular), `CCColor.textPrimary`, leading 18 pt, cap top y 67.7 |
| "Help" | 16 regular, `#1C4064`, right edge x 341.6 |
| "?" circle | 20 pt filled circle `#1C4064` with white "?" (`questionmark.circle.fill`), center x 363.7 / y 75.5 (trailing 19 pt) |
| Segments | "Recommend" / "Smart sync" 16 regular, centered at x 99 / 296 (the halves), cap top y 115.8; selected `#1F1F1F`, unselected `#9A9A9A` |
| Underline | 22.8 × 2 pt capsule, `CCColor.accent` (`#50A6F8`), y 146.4, centered under the selected label |
| Divider | 0.5 pt `#F2F2F2` at y ≈ 149.5, full width |
| Grid | margins 16 pt, gutter 12 pt (x 16.3–191.9 and 204.3–379.3), tile 176 × 188 pt, row pitch 200.7 pt, first row top y 167 |
| Tile | `RoundedRectangle(cornerRadius: 12)`. Background: the existing SF-Symbol-on-gradient art, kept because it replaces CamCard photos, plus a bottom 40% black-to-clear scrim at 25% so white titles read like the reference. |
| Tile title | 16 medium, white, light shadow, leading inset 13.6 pt, bottom inset about 12 pt, up to two lines ("Video Conference Card" and "Team Business Card" wrap in the reference) |
| "New" badge | "AI Transcription" only. Capsule 37 × 19.5 pt, `#EB3324`, white "New" 13 medium, top inset 13.7 pt, trailing inset 9.7 pt. Identifier `tools.recommend.aiTranscription.badge`. |

The header (title, Help, selector, divider) stays outside the `ScrollView`, which T21 relies on. Each segment adds `.accessibilityAddTraits(.isSelected)` when selected (T23).

### D4 — Messages (P31-S01) measured values

| Element | Value |
|---|---|
| Navigation | `ccPushedNavigationBar(title: "Messages")`. The title samples 17 pt, `#1E1E1E`; `CCFont.navTitle` (18) is within tolerance, so no shared change. |
| Page | background `#F2F2F2` |
| Row | white, from y 99 to 177 (78 pt tall), full width, bottom hairline `#EEEEEE`. Identifier `messages.row.bizTips`. |
| Avatar | 48.8 pt circle, light peach fill (`#FDEEE5`, ASSUMPTION: sampled through anti-aliasing), leading 17 pt, center y 137.3. Glyph `ellipsis.bubble.fill` about 20 pt in `#F3AF81`. |
| Title | "Biz Tips", 17 regular, `#131213`, leading x 83.3, cap top y 123 |
| Subtitle | "Great business begins with a great first impression", 15 regular, `#9F9F9F`, one line with tail truncation, leading x 82.6, trailing at about 350 pt |
| Date | "Sunday", 13 regular, `#9F9F9F`, trailing inset 14.3 pt, cap top y 124.3 |

The row is a `NavigationLink(value: AppRoute.bizTips)`.

### D5 — Biz Tips (P32-S01) measured values

| Element | Value |
|---|---|
| Navigation | `ccPushedNavigationBar(title: "Biz Tips")` |
| Page | background `#F0F0F0` |
| Date header | "Sunday", 13 regular, `#656565`, centered, cap top y 118.4 |
| Card | white, 1 pt border `#D8D8D8`, corner radius 4 pt, x 9.1–386.5 (insets about 9 pt), y 139.2–379.3. Identifier `bizTips.card`, inert with `TODO(P32-S02)`. |
| Banner | inset 7 pt inside the card (y 147–320, 173 pt tall). Placeholder `LinearGradient` `#3272F5` → `#22458D` (sampled from the banner background), no logo or illustration. |
| Caption band | bottom 29 pt of the banner, `#1D3C8A` at 85% opacity. Text "Great business begins with a great first impression", 16 regular, white, one line with tail truncation, leading x 27.3. |
| Title | "Welcome to CamCard", 16 regular, `#1A1A1A`, leading x 20.2, cap top y 343.5 |

### D6 — Create your card shared parts (P33)

| Element | Value |
|---|---|
| Navigation | `ccPushedNavigationBar(title: "")`, so only the chevron shows |
| Progress dashes | three 41 × 2.6 pt capsules at x 125.6, 178.3, 230.3 (12 pt gaps), cap top y 105.4 on steps 1–2. Completed `#50A6F8`, pending `#D9D9D9`. Identifier `createCard.progress` with `accessibilityValue` "1", "2" or "3". |
| Heading | "CREATE YOUR CARD", 26 pt black (`.black`) italic, `#4FA5F7`, centered, cap top y 131.4 (width 252.5 pt) |
| Primary button | capsule `#50A6F8`, white 18 medium text, insets 17.6 pt (width 361 pt), height 50 pt |
| Filled field | `#F0F0F0`, radius 10, insets 25.4 pt (width 345.5 pt), height 49.5 pt. Placeholder 16 regular `#A9A9A9` at leading inset 17 pt. A floating label variant puts a small label (11 regular `#AAAAAA`) 9 pt from the top. |

Step 3 in the capture sits about 13 pt lower (dashes at y 119). ASSUMPTION: that is a capture-state difference, so every step uses step 1's header geometry. The visual check notes it and accepts it.

### D7 — Step 1 (P33-S01) measured values

- Subtitle: "Choose the template you want for your digital business card", 18 regular, `#141414`, centered, two lines, y 168–204.
- Template carousel: centered card x 72.9–322.7 (250 pt wide), y 239–650 (411 pt tall), white, radius 12, soft shadow. Neighbouring cards peek 9 pt (left) and about 38 pt (right) at 80% opacity.
  - **Content is neutral**: a light-blue header block with grey placeholder bars, four rows of a blue round icon (`phone.fill`, `iphone`, `envelope.fill`, `mappin`) plus a grey bar, then "Experience" and "Other information" headings in 11 pt `#8A8A8A` with grey bars. There are no names, companies, numbers or addresses (see Open Questions).
  - Swiping changes the selected dot; it is a paged `TabView` with 9 identical neutral templates.
- Page dots: nine 7 pt dots, pitch 15.8 pt, centered, y 673–679. Selected `#50A6F8`, others `#E7E7E7`.
- "Continue": primary button at y 708–757, identifier `createCard.continue`. It pushes `.createCard(step: 2)`.
- "Already have an account" (16 regular `#9A9A9A`) and "Sign in" (16 medium `#5F5F5F`) on one centered line at y 779–793. "Sign in" is a plain button `createCard.signIn`, inert with `TODO(P20-S01)`.

### D8 — Steps 2 and 3 measured values

Step 2 (P33-S02):

- Subtitle "Complete your information.", 18 regular `#191919`, centered, y 167–184.
- Fields at y 227, 294, 361 and 428 (pitch 67 pt):
  1. Floating label "Full Name" with a red `#E83521` "*"
  2. "Enter company info to display."
  3. "Enter job title info to display."
  4. "Add an email address to be contacted."

  They are real `TextField`s whose values live in `@State` only and are never saved. No auto-focus (ASSUMPTION: the capture shows the keyboard, but focusing on appear would cover the layout in the visual check).
- "Scan paper cards": `camera` symbol plus 15 regular `#626262`, centered, y 498–511. Identifier `createCard.scanPaperCards`, inert with `TODO(P02-S01)`: the scan flow is not linked from here in the state diagram.
- Bottom bar: 0.5 pt `#D8D8D8` divider, then "Next step" (primary button, 47 pt tall), pinned above the safe area. Identifier `createCard.nextStep`. It pushes `.createCard(step: 3)`.

Step 3 (P33-S03), positions relative to the step 1 header:

- Subtitle "Only one step away, Sign in to save your card", 18 regular `#121212`, centered, two lines.
- Note "Unregistered camcard email will be registered automatically", 15 regular `#989898`, leading 25.4 pt, two lines.
- Email field with floating label "Email Number", empty, editable, never saved. The capture's typed "John@google.com" is not copied.
- Checkbox: a 16 pt square with a 1 pt `#A5A5A5` stroke, leading 25.4 pt, identifier `createCard.agree`, inert. Beside it, "Agree to " + "Terms of Service" + " and " + "Privacy Policy" in 15 regular `#1E1E1E`, with the two links in `#50A6F8` underlined and inert (`createCard.terms`, `createCard.privacy`).
- "Next": primary button with insets 25.4 pt, 43.6 pt tall, about 42 pt below the checkbox row. Identifier `createCard.signInNext`, inert.
- "Or continue with": 13 regular `#8A8A8A`, centered, with 0.5 pt `#F4F4F4` hairlines from x 49.5 to 129.5 and mirrored.
- Three outlined capsules, insets 25.4 pt, 48 pt tall, pitch 64 pt, stroke 1 pt `#CECECE`. Each has a leading icon at 22 pt from the edge and centered 16 regular `#161616` text:
  - "Sign in with phone" (`iphone`)
  - "Sign in with Google": a bold "G" letter, matching the existing Settings sign-in row, not Google's logo
  - "Sign in with Apple" (`apple.logo`)

  Identifiers `createCard.signIn.phone`, `.google`, `.apple`, all inert with `TODO(P20-S01)`.

### D9 — Tests

- `UITestRouteHookTests` (unit):
  - "messages" → `.messages`
  - "bizTips" → `.bizTips`
  - "createCard1", "createCard2", "createCard3" → `.createCard(step: 1)`, `.createCard(step: 2)`, `.createCard(step: 3)`
  - an unknown name or a missing value → `nil`
- `T23ToolsMessagesDigitalCardUITests` (UI), each launched with `-uiTestEmptyStore`:
  1. `testT23ToolsBadgeAndSelectorState`: the "New" badge exists only on AI Transcription, and the selector's `isSelected` flips between the segments.
  2. `testT23MessagesToBizTipsAndBack`: launch with `-uiTestOpenRoute messages` and tap the Tools tab. Messages texts appear. Tap `messages.row.bizTips`: Biz Tips texts appear. Tap `bizTips.card`: still on Biz Tips. Back twice: Tools is visible again (`tools.title`).
  3. `testT23CreateCardStepsForwardAndBack`: launch with `-uiTestOpenRoute createCard1` and tap Tools. Step 1 texts appear, `createCard.progress` reads "1", and "Sign in" is inert. Continue: step 2 fields and texts, progress "2", "Scan paper cards" inert. Next step: step 3 texts, progress "3", and every step 3 control is inert. Back three times returns to Tools.
- **No existing test assertion changes.** I checked T21 `testToolsPlaceholdersExistAndAreInert`: every identifier it uses is kept, tiles and Help stay inert, Smart sync still replaces the Recommend tiles, and the title stays outside the scroll view, so its frame-stability assertion still holds. T22 doesn't touch Tools.
- Visual check (Haiku, on the agent's simulator): screenshot each of P30-S01, P30-S02, P31-S01, P32-S01 and P33-S01/S02/S03 through the hook. Compare against the D3–D8 tables, and against the reference by sampled colors and positions in pt. Flow check against `reference/state-diagram.md`: P30-S01 → P30-S02 (Smart sync), P31-S01 → P32-S01 (Biz Tips), P33-S01 → P33-S02 (Continue) → P33-S03 (Next step).

### D10 — DEBUG route hook without shared edits

`Features/Messages/UITestRouteHook.swift`:

```swift
enum UITestRouteHook {
    static func route(from arguments: [String]) -> AppRoute?   // "-uiTestOpenRoute <name>"
}
```

It returns `nil` in release builds (`#if DEBUG`). `ToolsView` switches to `NavigationStack(path: $path)` with `@State private var path: [AppRoute] = []`. In its first `.onAppear`, guarded by a `@State` flag, it appends `UITestRouteHook.route(from: ProcessInfo.processInfo.arguments)` when non-nil. Release builds and normal launches behave as before.

*Alternative:* add the hook to `LaunchConfiguration` and push from `RootView`'s Home stack. That reads more naturally ("opens from Home") but edits two frozen shared files, so this change uses the owned-file hook. Opus can move it to `LaunchConfiguration` later if other changes need the same hook.

*Why the Tools tab:* it is the only navigation stack this change owns. The hosting tab doesn't affect what is tested, which is the destination screens and their in-flow navigation.

## Risks / Trade-offs

- [The iOS 27 system navigation bar on pushed pages is about 15 pt taller than the reference (our divider at 116 pt, the reference's at 150 px), with the chevron and title about 4 pt lower, and the title ink is `#151314` where the reference is `#1E1E1E`] → Accepted by the user (2026-11-25): the system bar stays as is. P31/P32/P33 content is matched relative to the divider, not to the screen top.
- [The chevron color stays `#1C3F64` if D2 isn't applied] → The Haiku check flags it. It's a one-line shared fix on `main`.
- [Real `TextField`s on P33 could look like data entry that does something] → Values are never read outside the view, and step 3 sends nothing. Covered by the inert scenarios.
- [The paged `TabView` carousel might not show neighbouring cards peeking the way the reference does] → Fallback: a horizontal `ScrollView` with `.scrollTargetBehavior(.viewAligned)` and the 250 pt card width. The visual check decides.
- [Tile gradients differ from CamCard photos] → Accepted (artwork rule). Geometry and titles still match.
- [Test hook in `ToolsView`] → DEBUG-only, and unit-tested for parsing.

## Migration Plan

UI only. Rollback means reverting the commit.

## Open Questions

- DECIDED at approval (2026-11-25): P33 fields accept typing and save nothing; neutral template bars; fixed "Sunday".
