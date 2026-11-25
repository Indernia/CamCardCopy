# Tasks

Implemented by Opus directly on `main` (shared files), before the milestone 2 worktrees are created. Test runs add `-collect-test-diagnostics never`.

## 1. Tokens and visibility

- [x] 1.1 Add `navInk` and `navDivider` to `CCColor` and `ThemeTests` (D1). Verification: `-only-testing:"CamCard CopyTests/ThemeTests"` passes.
- [x] 1.2 Add `Support/Theme/TabBarVisibility.swift` and `CamCard CopyTests/TabBarVisibilityTests.swift` (D2). Verification: `-only-testing:"CamCard CopyTests/TabBarVisibilityTests"` passes.

## 2. Wiring

- [x] 2.1 Inject `TabBarVisibility` from `RootView` and hide `MainTabBar` while `isHidden`; make `ccPushedNavigationBar` report appear/disappear, draw the chevron in `navInk` and the `navDivider` line (D2, D3). Verification: simulator check in D4 recorded in `docs/manual-checks/fix-pushed-page-chrome.md` with screenshots before and after back, scaffold removed.

## 3. Full suite

- [x] 3.1 Run the full suite with the exact project command (`-collect-test-diagnostics never`). Verification: `** TEST SUCCEEDED **`, 0 failures.

## Workflow follow-up

- Archive, ai-log entry, commit and push `main` before creating the milestone 2 worktrees.
