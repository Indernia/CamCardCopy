# Tasks

Every test run adds `-collect-test-diagnostics never` (project rule). Targeted runs use:

```
xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" -collect-test-diagnostics never -only-testing:"<target>/<suite>" > build/test-output.log 2>&1
```

Read `build/test-output.log` and require `** TEST SUCCEEDED **` before checking a task.

## 1. Project config

- [x] 1.1 Update `openspec/config.yaml` per design D8: quote the second `rules.tasks` item and replace the "Out of scope" hard rule with the inert-visual-copy rule. Verification: `openspec instructions tasks --change add-visual-foundation --json` prints no "Rules for 'tasks' must be an array of strings" warning, and `openspec validate add-visual-foundation` passes.

## 2. Tokens and building blocks

- [x] 2.1 Add `CamCard Copy/Support/Theme/CCColor.swift` (tokens, `Color(hex:)`, `CCColor.hex(_:)`) and `CCFont.swift` (`CCFont.spec` table and `Font` values) with the D2 values. Add `CamCard CopyTests/ThemeTests.swift` asserting every hex and every size/weight in D2. Verification: `-only-testing:"CamCard CopyTests/ThemeTests"` passes.
- [x] 2.2 Add `CamCard Copy/Support/Theme/CCComponents.swift` with `CCTintedHeaderLayout`, `CCIconButton`, `View.ccPushedNavigationBar(title:)` and `CCPlaceholderPage` per D5. Before going on, push a `CCPlaceholderPage` from a temporary `#Preview` or a throwaway local navigation in the simulator and screenshot it. Confirm the "‹" and title show no glass circle. If the glass remains, switch to D5's custom-header fallback and update design.md before task 3. Remove any temporary navigation code. Verification: a simulator screenshot attached to `docs/manual-checks/add-visual-foundation.md` showing the plain chevron, and the app target builds.

## 3. Routes

- [x] 3.1 Add `CamCard Copy/Features/Shell/AppRoute.swift` (`AppRoute`, `SettingsPage`, `title`, `stateID`, `View.appRoutes()`) and the three stub files `Features/Messages/MessagesRoutes.swift`, `Features/Settings/SettingsRoutes.swift` and `Features/DigitalCard/DigitalCardRoutes.swift` per D7, each returning `CCPlaceholderPage` with its `TODO(P##-S##)` marker. Add `CamCard CopyTests/AppRouteTests.swift` with the D9 title and state ID assertions. Verification: `-only-testing:"CamCard CopyTests/AppRouteTests"` passes.
- [x] 3.2 Apply `.appRoutes()` inside the existing `NavigationStack` of `CardHolderView`, `ToolsView` and `SettingsView`. In `RootView`, wrap `HomeView()` in a `NavigationStack` with `.appRoutes()` and a hidden navigation bar on Home's root. Wire no control. Verification: `-only-testing:"CamCard CopyUITests/T21ShellPlaceholderUITests" -only-testing:"CamCard CopyUITests/T01EmptyCardHolderUITests"` passes with no test edits.

## 4. Tab bar and appearance

- [x] 4.1 Restyle `MainTabBar` and add `AppTab.selectedSystemImage` per D6, including the `.isSelected` trait. Keep every identifier. Verification: `-only-testing:"CamCard CopyUITests/T02CameraUITests"` passes with no test edits.
- [x] 4.2 Add `.preferredColorScheme(.light)` in `MyApp.swift` per D4. Verification: with the simulator in dark appearance (`xcrun simctl ui <udid> appearance dark`), a screenshot shows the white tab bar. Record it in `docs/manual-checks/add-visual-foundation.md`, then restore light appearance.

## 5. Tests and visual check

- [x] 5.1 Add `CamCard CopyUITests/T22VisualFoundationUITests.swift` with the three D9 UI tests: tab selection trait, scan button opens the camera, and wired-nothing guard for the Home bell, "Create New Card", CardHolder bell and "Language setting". Verification: `-only-testing:"CamCard CopyUITests/T22VisualFoundationUITests"` passes.
- [ ] 5.2 Haiku visual check: launch the app on the agent's simulator and screenshot Home. Compare the tab bar region with `reference/screenshots/P00-S01_home-empty.png` (background, label size and colors, filled selected icon, scan gradient). Write findings and the screenshot path to `docs/manual-checks/add-visual-foundation.md`. Fix any measurable mismatch in the tokens (task 2.1's test changes with it). Verification: the checklist shows Pass, or lists only accepted differences (CamCard artwork glyphs).

## 6. Full suite

- [ ] 6.1 Run the full suite on `main` after merge: `xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" -collect-test-diagnostics never -parallel-testing-worker-count 3 > build/test-output.log 2>&1` (drop the worker cap once the Mac is back on power, per the project rule). Verification: `build/test-output.log` shows `** TEST SUCCEEDED **` with 0 failures, and T01, T02, T03T20, T05, T07, T12, T18, T21 and the new T22 suites are all green.

## Workflow follow-up

- Archive the change after the user approves the artifacts and the full suite passes.
- After archive, append to `docs/ai-log.md`: change name, generated artifacts, what the user corrected, and the test results.
- Then start milestone 2's three parallel changes per design D7's ownership table.
