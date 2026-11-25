# Tasks

Verification for every task uses the project's exact test command:

```
xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17"
```

For targeted runs append `-only-testing:"<target>/<suite>"`, and redirect output to the log the project reads:

```
mkdir -p build
xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:"<target>/<suite>" > build/test-output.log 2>&1
```

Read `build/test-output.log` and require `** TEST SUCCEEDED **` before marking a task done. Never claim a test passed without that log line.

## 1. Home tab

- [x] 1.1 Add `Features/Shell/HomeView.swift` with the P00-S01 chrome (bell, "Search Card Holder", crown, stats, two promo cards, "My Digital Card", "No cards yet. Create a new one!" as one string with no newline, "Create New Card"), SF Symbols only, all controls inert with the identifiers and `TODO(P##-S##)` markers from design D7, and keep `.accessibilityIdentifier("placeholder.home")` on the "My Digital Card" text; wire it into `RootView`; verify T01EmptyCardHolderUITests, T02CameraUITests and T03T20CameraDeniedUITests still pass.
- [x] 1.2 Add `testHomePlaceholdersExistAndAreInert` to `CamCard CopyUITests/T21ShellPlaceholderUITests.swift`. Assert the texts "Search Card Holder" (via `home.search`'s label), "Speech to Text" and "AI Summary" (via `home.promo.speechToText`), "High Accuracy" and "99.99% Accuracy" (via `home.promo.highAccuracy`), "Create New Card" (via `home.digitalCard.create`), and the plain texts "My Digital Card" and "No cards yet. Create a new one!" (via `app.staticTexts`); assert tapping search/bell/crown/stats/promo cards/"Create New Card" leaves `placeholder.home` visible with no keyboard, sheet or new screen; verify the test passes.

## 2. CardHolder bell

- [x] 2.1 Add the `.topBarLeading` bell to `CardHolderView` with `cardholder.bell` and `TODO(P31-S01)`, leaving the list, empty state, search pill and ⊕ untouched; verify T01EmptyCardHolderUITests still passes.
- [x] 2.2 Add `testCardHolderBellIsInert` to the T21 suite asserting `app.buttons["cardholder.bell"]` exists on the empty screen, that tapping it opens no screen or sheet, and that "No cards" remains; verify the test passes.

## 3. Tools tab

- [x] 3.1 Add `Features/Shell/ToolsView.swift` with the "Tools" title, inert "Help", the custom Recommend / Smart sync selector and the P30-S01/S02 tiles from design D4-D7 (no "New" badge on AI Transcription), each with its identifier and TODO marker; wire it into `RootView`; verify the app target builds in `build/test-output.log`.
- [x] 3.2 Add `testToolsPlaceholdersExistAndAreInert` to the T21 suite asserting `app.buttons["tools.segment.recommend"]` and `["tools.segment.smartSync"]` exist, the six Recommend tile identifiers under `tools.recommend.*` are visible, tapping a Recommend tile changes nothing, the six Smart sync identifiers under `tools.sync.*` appear after tapping "Smart sync", tapping a sync tile changes nothing, and "Help" opens nothing; verify the test passes.

## 4. Settings root

- [x] 4.1 Add `Features/Shell/SettingsView.swift` with the P10-S01 root (sign-in card, Premium card with "Premium", "Upgrade +" and the four inert items "Unlimited Scan", "Sync CRM", "Export to Excel", "Back up", "APP SETTINGS" rows, "Resume In-APP Purchases", "Help and Feedback", "ABOUT CAMCARD"), every row and item inert except "General" which is a `NavigationLink` to `SettingsGeneralView`, `.textCase(nil)` on headers, each with its identifier and TODO marker (`P21-S01` for the four Premium items); wire it into `RootView`; verify the app target builds in `build/test-output.log`.
- [x] 4.2 Add `testSettingsPlaceholdersExistAndAreInert` to the T21 suite asserting the visible root identifiers via `app.buttons[...]`, scrolling to reach the lower sections, that sign-in, Upgrade, the four Premium items and all rows except General open no screen or sheet, tapping "Help and Feedback" by `settings.row.helpFeedback` (never by text), and that Settings remains the current screen; verify the test passes.

## 5. Settings General

- [x] 5.1 Add `Features/Shell/SettingsGeneralView.swift` with the P11-S01 rows, values ("Off", "First, Last", "Not logged in"), the two disabled off toggles with `settings.general.showGroupSettings.toggle` and `settings.general.saveCardImage.toggle` and the App Lock footer, all inert with identifiers and `TODO(P11-S01)`; verify the app target builds in `build/test-output.log`.
- [x] 5.2 Add `testSettingsGeneralIsReadOnlyAndInert` to the T21 suite opening Settings › General, asserting the row identifiers, the two toggles via `app.switches[...]` and the footers, that tapping a row or a toggle changes nothing and leaves the toggle values unchanged, and that the back control returns to Settings; verify the test passes.
- [x] 5.3 Remove `Features/Shell/PlaceholderView.swift` after confirming no references remain (`grep -R "PlaceholderView" "CamCard Copy"`), then verify the full T21 suite still passes with the exact test command.

## 6. Integration

- [x] 6.1 Run the full test suite with the project's exact test command (no `-only-testing`) and report the pass/fail counts from `build/test-output.log`, confirming T01, T02, T03T20, T18 and the new T21 suite are green.

## Workflow follow-up

- Archive the change after the project's review requirements are satisfied.
- Append the change entry (generated artifacts, corrections, test results) to `docs/ai-log.md`, per the project rules.
