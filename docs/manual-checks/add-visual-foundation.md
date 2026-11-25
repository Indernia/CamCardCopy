# Manual checks: add-visual-foundation

## Task 2.2 - Pushed-page navigation bar has no glass (D5)

Method: temporary `TempPushHost` in `RootView` (DEBUG scratch code, since removed, not committed) pushed a `CCPlaceholderPage(title: "Messages", stateID: "P31-S01")` on launch. Simulator iPhone 17 (iOS 27).

Screenshot: `add-visual-foundation/placeholder-page.png`

- [x] Plain "‹" chevron in `#1C3F64`, no glass circle or material behind it.
- [x] Title "Messages" centered, no glass behind it.
- [x] Only one back control (system back button hidden).
- [x] "Not built yet" and "P31-S01" shown.

Result: Pass. `.sharedBackgroundVisibility(.hidden)` works on iOS 27, so the D5 custom-header fallback was NOT needed and design.md is unchanged.
(The tab bar in this screenshot is the pre-task-4.1 style.)

## Task 4.2 - Light appearance only (D4)

Method: simulator appearance set to dark (`xcrun simctl ui <udid> appearance dark`), app relaunched with `-uiTestEmptyStore`, screenshot taken, appearance restored to light.

Screenshot: `add-visual-foundation/home-dark-system.png`

- [x] Tab bar background is white, labels use the light-mode colors (selected `#1E1E1E`, unselected `#989898`).
- [x] Home content is light (no dark UI), status bar adapts.
- [x] Scan button shows the violet gradient with a white camera glyph.

Result: Pass. Appearance restored to light afterwards.
