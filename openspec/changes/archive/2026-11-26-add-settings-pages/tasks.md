# Tasks

> Prerequisites before the worktree is created:
> 1. The user approves the artifacts, including the test changes listed in proposal.md and decisions D4 and D6. Tasks assume the recommended options.
> 2. Opus makes the design D2 tab-bar prerequisite on `main` and pushes `main`.
>
> The worktree is cut from `origin/main` after that.

Every test run uses the agent's own simulator and adds `-collect-test-diagnostics never`. Shut down "iPhone 17" first (`xcrun simctl shutdown "iPhone 17"`), then `xcrun simctl clone "iPhone 17" "iPhone 17 - settings"`, or create an equivalent iOS 27 iPhone 17 with `xcrun simctl create`. Targeted runs:

```
xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17 - settings" -collect-test-diagnostics never -only-testing:"<target>/<suite>" > build/test-output.log 2>&1
```

Read `build/test-output.log` and require `** TEST SUCCEEDED **` before checking a task.

## 1. Settings root and General

- [x] 1.1 Add `Features/Settings/SettingsPageComponents.swift` (`SettingsGroup`, list row, value row, toggle row with a constant binding, footer) using D1 values and shared tokens. Rewrite `SettingsView.swift` per D3 with a pinned header, cards and groups, and every identifier kept. Rows become `NavigationLink(value:)` to their `AppRoute`, General stays a direct link, and "Resume In-APP Purchases" stays inert. Verification: the app builds, plus a simulator screenshot of the root at the top and scrolled, saved to `docs/manual-checks/add-settings-pages/`.
- [x] 1.2 Restyle `SettingsGeneralView.swift` per D1 and D4: white rows on `#F0F0F0`, `ccPushedNavigationBar(title: "General")` plus `.navigationTitle("General")`, and constant-binding toggles that aren't disabled. Verification: `-only-testing:"CamCard CopyUITests/T21ShellPlaceholderUITests/testSettingsGeneralIsReadOnlyAndInert"` passes **unedited**. If it fails, stop and report.

## 2. Pages

- [x] 2.1 Add the P12, P13 and P14 views (`SettingsLanguageView`, `SettingsNotificationsView`, `SettingsPrivacyView`) with the exact texts from the settings-pages spec, and route them in `SettingsRoutes.swift`. Verification: T25 tests for these three pages (task 3.1) pass.
- [x] 2.2 Add the P15, P16 and P18 views (`SettingsPermissionsView`, `SettingsHelpFeedbackView`, `SettingsAboutView` with the D6 recommended legal lines) and route them. Verification: the T25 tests for these pages pass.
- [x] 2.3 Add the P17 and P19 views (`SettingsInviteFriendsView` with the D7 stand-ins, `SettingsPIChecklistView` with the six observed table rows and `TODO(P19-S01)` for the rows not captured) and route them. Verification: the T25 tests for these pages pass.
- [x] 2.4 Add the P20 and P21 views (`LoginEmailView` with the email `TextField` that accepts typing and saves nothing, `UpgradePlansView` with fixed selection and the D5 bar exception) and route `.login` and `.paywall`. Keep `.settings(.accountSync)` on `CCPlaceholderPage`. Verification: the T25 tests for Login, Upgrade Plans and Account and Sync pass.

## 3. Tests

- [x] 3.1 Add `CamCard CopyUITests/T25SettingsPagesUITests.swift` per D8: one test per page or page group, plus a tab-bar-hidden test. Verification: `-only-testing:"CamCard CopyUITests/T25SettingsPagesUITests"` passes. Write this before or alongside tasks 2.1–2.4.
- [x] 3.2 Edit the approved assertions only: T21 `testSettingsPlaceholdersExistAndAreInert`, renamed `testSettingsRowsExistAndOpenTheirPages`, and the Language block in T22 `testT22InertControlsStayInert`, exactly as listed in proposal.md "Tests that change". Verification: `-only-testing:"CamCard CopyUITests/T21ShellPlaceholderUITests" -only-testing:"CamCard CopyUITests/T22VisualFoundationUITests"` passes, and `git diff` of those two files shows only the listed edits.

## 4. Visual and flow check (Haiku)

- [x] 4.1 Haiku screenshots P10 (top and scrolled) and P11–P21 on the agent's simulator and compares each with its reference per D8: sampled colors, texts, row heights about ±2 pt, tab bar hidden. It records Pass or Fail with evidence in `docs/manual-checks/add-settings-pages.md`. Sonnet fixes measurable mismatches and Haiku re-checks. Verification: every page shows Pass, or lists only accepted artwork differences.
- [x] 4.2 Haiku walks P10 → P11–P20 and back for each edge in `reference/state-diagram.md`'s navigation shell, plus Upgrade + → P21 (ASSUMPTION edge), and records the results in the same file. Verification: all edges Pass.

## 5. Full suite

- [x] 5.1 After Opus merges to `main`: `xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" -collect-test-diagnostics never > build/test-output.log 2>&1`. Verification: `** TEST SUCCEEDED **` with 0 failures, including T21, T22 and the new T25.

## Workflow follow-up

- Archive after the user approves and the full suite passes. Append to `docs/ai-log.md` and push `main`.
