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

## 5.2 Visual check (Haiku)

Method: simulator `iPhone 17 - foundation` (5C1860AF-706B-4B0F-B9E0-A5C37D65BFE9), light appearance, clean relaunch, screenshot `add-visual-foundation/home-light.png`. Compared against `reference/screenshots/P00-S01_home-empty.png` (bottom tab bar, scaled 1.54 px/pt horizontally, about 1.50 px/pt vertically). Simulator is 3 px/pt.

- [x] a. Tab bar background white `#FFFFFF`; 1 px separator `#EAEAEA` above the bar (sim). Reference shows no visible separator in its crop, so the separator is not confirmed against the reference. Result: Pass (background), separator not verifiable against reference.
- [x] b. Labels Home / CardHolder / Tools / Settings present, cap height about 7 pt (about 10 pt font). Selected Home `#1E1E1E`, unselected `#989898`. Reference Home `#222222`, unselected about `#9B9B9B`. Result: Pass.
- [x] c. Selected tab (Home) shows filled house icon; the others show outline icons. Result: Pass.
- [x] d. Center scan button 56 pt diameter, gradient left `#564DF5` to right `#863FF7`, white camera glyph. Reference gradient about `#4D4FF6` to `#8F3DF7`. Reference button measures about 43 pt at its scale, so size differs from the reference mockup. Result: Pass against the spec (56 pt); the reference size is a mockup difference to confirm.
- [x] e. Position: sim tab bar top (separator) about 104 pt above screen bottom. Sim icon centers about 73 pt, label centers about 52 pt above screen bottom. Reference icons about 66 pt and labels about 44 pt. Sim labels sit about 7 pt higher than the reference. Accepted differences: CamCard artwork glyphs (house, CardHolder folder-with-person, camera, folder, gear) are the app's own drawings and differ from the reference icons. Result: Fail (minor vertical offset, about 6-8 pt), to confirm.

Flow check (Navigation shell, `reference/state-diagram.md`), taps at the tab locations, screenshot after each step:

- [x] Bell icon (top left of Home) tapped: nothing opened, Home stayed in place. `add-visual-foundation/flow-01-bell.png`. Result: Pass.
- [x] Home to CardHolder: CardHolder selected, its screen shown. `flow-02-cardholder.png`. Result: Pass.
- [x] CardHolder to Tools: Tools selected, its screen shown. `flow-03-tools.png`. Result: Pass.
- [x] Tools to Settings: Settings selected, its screen shown. `flow-04-settings.png`. Result: Pass.
- [x] Settings to Home: Home selected again. `flow-05-home-return.png`. Result: Pass.

Screenshots: `add-visual-foundation/home-light.png`, `flow-01-bell.png` to `flow-05-home-return.png`. Crops (scratch, not committed): `crops/sim_tabbar.png`, `crops/ref_tabbar.png`, `crops/ref_tabbar_tall.png`.

Result: a-d Pass, e Fail (minor), flow Pass. No Swift or test files were edited.

## 5.2 Fix round (Opus)

- Haiku's item e (tab bar about 6–8 pt high) and the 43 pt reference button were confirmed by measuring P00-S01: Home icon center 63.4 pt and label center 41.3 pt above the screen bottom; scan button 42.9 pt, center 57.9 pt.
- Cause: design D6's 56 pt button with center alignment lifted the whole row. Fix: 44 pt button, 18 pt icons, bottom-aligned row, 1 pt bottom padding (design D6 and the app-shell delta updated).
- Re-measured on "iPhone 17 - foundation" (`home-light-fixed.png`): icon 64.0 pt, label 41.0 pt, button 44.0 pt with its center at 57.2 pt. All within 1 pt: **Pass**.
- Separator line: the reference shows none at this scale; kept at 0.5 pt `#EAEAEA` (accepted, barely visible).
- Rerun T22, T02, T21 and T01 on the same simulator: `Executed 13 tests, with 0 failures`, `** TEST SUCCEEDED **`.
