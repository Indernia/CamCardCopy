# Proposal

## Why

Milestone 2 pixel-matches every captured screen. Tools (P30-S01/S02) works but doesn't look like the reference: large bold title, wide underline, 150 pt tiles, no "New" badge. Messages (P31-S01), Biz Tips (P32-S01) and Create your card (P33-S01/S02/S03) exist only as "Not built yet" route stubs from add-visual-foundation. This change builds those destination screens as inert visual copies, so the bell and "Create New Card" have something real to open once `polish-home-cardholder` wires them.

## What Changes

- Restyle the Tools tab to the measured P30-S01/P30-S02 layout:
  - "Tools" 24 pt at 18 pt leading
  - "Help" 16 pt in `#1C4064` next to a filled 20 pt "?" circle
  - "Recommend" / "Smart sync" at 16 pt, centered in halves; selected `#1F1F1F`, unselected `#9A9A9A`
  - a 23 × 2 pt `#50A6F8` underline under the selected label, and a hairline divider below the selector
  - 2 × 3 grid of 176 × 188 pt tiles, radius 12, 12 pt gutters, 16 pt margins; white 16 pt medium titles at the bottom-left
  - a red "New" badge on "AI Transcription"

  Tile imagery stays SF Symbol plus gradient (CamCard artwork is not copied). Every tile and "Help" stays inert, and the existing identifiers are kept.
- Build Messages (P31-S01): white navigation bar titled "Messages" on a `#F2F2F2` page with one white "Biz Tips" row. The row has a 49 pt peach avatar with an orange speech bubble, "Biz Tips", the subtitle "Great business begins with a great first impression" truncated to one line, and "Sunday". Tapping the row opens Biz Tips.
- Build Biz Tips (P32-S01): "Sunday" date header, then one white bordered card. The card holds a banner placeholder (blue gradient, no CamCard artwork) with the caption "Great business begins with a great first impression" on a dark band, and the title "Welcome to CamCard". The card is inert (TODO(P32-S02): article view not captured).
- Build Create your card steps 1–3 (P33-S01, P33-S02, P33-S03) with the three-dash progress indicator, the blue italic "CREATE YOUR CARD" and the measured buttons and fields:
  - "Continue" (step 1) opens step 2.
  - "Next step" (step 2) opens step 3.
  - Inert: "Sign in" (step 1), "Scan paper cards" (step 2), "Next", the agreement checkbox and links, and the three "Sign in with …" buttons (step 3).
- Add a DEBUG-only UI test hook, `-uiTestOpenRoute <name>`: the Tools tab pushes the named route when it first appears. This keeps the new screens testable without editing shared files or Home/CardHolder.
- **No control outside this change's files is wired.** The Home bell, the CardHolder bell and "Create New Card" stay inert here; `polish-home-cardholder` wires them.

State IDs covered: P30-S01, P30-S02, P31-S01, P32-S01, P33-S01, P33-S02, P33-S03.

Test IDs: T21 (existing Tools scenarios, unchanged), T23 (new: Tools restyle, Messages, Biz Tips and Create your card). T23 is reserved for this change; the other two milestone 2 changes use T24 and T25 so the parallel branches don't collide.

## Out of scope

- Wiring the Home bell, the CardHolder bell or "Create New Card" (`polish-home-cardholder`).
- Settings sub-pages, Login (P20-S01) and Upgrade Plans (P21-S01) (`add-settings-pages`). Step 1's "Sign in" stays inert rather than opening P20-S01: the state diagram has no such edge.
- Real messaging, notification data, article content (P32-S02 not captured), digital-card creation, login, account registration, terms acceptance or any network call.
- CamCard artwork: tile photos, the Biz Tips banner illustration, the template card designs and the Google logo.
- Shared files (`AppRoute.swift`, `Support/Theme/*`, `MainTabBar`, `RootView`, `LaunchConfiguration`). See design.md D2 for the one shared-file dependency, which Opus handles on `main`.

## Capabilities

### New Capabilities

- `messages`: the Messages list reached from the bell (P31-S01) and the Biz Tips feed it opens (P32-S01), as inert visual copies.
- `digital-card-creation`: the three-step "Create your card" flow (P33-S01/S02/S03) as an inert visual copy with working step navigation and no account or card creation.

### Modified Capabilities

- `app-shell`: "Tools tab content" gains the measured P30 layout, the "New" badge and a selected-state trait on the selector. Inertness and identifiers are unchanged.

## Impact

- Modified: `CamCard Copy/Features/Shell/ToolsView.swift`, `Features/Messages/MessagesRoutes.swift`, `Features/DigitalCard/DigitalCardRoutes.swift`.
- New: `Features/Messages/MessagesView.swift`, `Features/Messages/BizTipsView.swift`, `Features/Messages/UITestRouteHook.swift`, `Features/DigitalCard/CreateCardStepView.swift`, `Features/DigitalCard/CreateCardComponents.swift`.
- Tests, new: `CamCard CopyTests/UITestRouteHookTests.swift`, `CamCard CopyUITests/T23ToolsMessagesDigitalCardUITests.swift`. No existing test assertion changes (design D9).
- No model, persistence, recognition or scan code is touched.
