# Tasks

Prerequisite (Opus, on `main`, before this change's worktree is created): decide on design D2, the shared chevron color and nav divider. Agents never edit shared files.

Workflow: Sonnet implements in its own worktree on its own simulator (shut down "iPhone 17" before `simctl clone`, or use `xcrun simctl create "iPhone 17 - tools" <device type> <runtime>`), running targeted tests only. Every test run adds `-collect-test-diagnostics never`:

```
xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17 - tools" -collect-test-diagnostics never -only-testing:"<target>/<suite>" > build/test-output.log 2>&1
```

Read `build/test-output.log` and require `** TEST SUCCEEDED **` before checking a task.

## 1. Test hook

- [x] 1.1 Add `Features/Messages/UITestRouteHook.swift` per D10, plus `CamCard CopyTests/UITestRouteHookTests.swift` with the D9 cases. Switch `ToolsView` to `NavigationStack(path:)` and push the hooked route once on first appear. Verification: `-only-testing:"CamCard CopyTests/UITestRouteHookTests"` passes, and `-only-testing:"CamCard CopyUITests/T21ShellPlaceholderUITests"` still passes with no test edits.

## 2. Tools restyle

- [x] 2.1 Restyle `ToolsView` to the D3 values: title, Help and "?" circle, centered segments with the underline and the `.isSelected` trait, divider, 176 × 188 tiles with a scrim and bottom-left titles, the "New" badge on AI Transcription only. Keep the header outside the `ScrollView` and keep every identifier. Verification: `-only-testing:"CamCard CopyUITests/T21ShellPlaceholderUITests"` passes unedited, and the T23 test `testT23ToolsBadgeAndSelectorState` (added in this task to `T23ToolsMessagesDigitalCardUITests.swift`) passes.

## 3. Messages and Biz Tips

- [x] 3.1 Add `MessagesView` (D4) and `BizTipsView` (D5), and resolve `.messages` / `.bizTips` to them in `MessagesRoutes.swift`. Verification: `testT23MessagesToBizTipsAndBack` passes.

## 4. Create your card

- [x] 4.1 Add `CreateCardComponents.swift` (progress dashes with their accessibility value, heading, primary button, filled field with a floating-label variant) and `CreateCardStepView` for steps 1–3 per D6–D8. Resolve `.createCard(step:)` in `DigitalCardRoutes.swift`. "Continue" and "Next step" push `.createCard(step: 2)` and `.createCard(step: 3)`; every other control is inert with its `TODO(P##-S##)` marker. Verification: `testT23CreateCardStepsForwardAndBack` passes.

## 5. Review

- [ ] 5.1 Haiku visual and flow check on the agent's simulator, per D9. Screenshot P30-S01, P30-S02, P31-S01, P32-S01 and P33-S01/S02/S03 through `-uiTestOpenRoute`. For each, compare measured positions (pt), sizes and sampled colors with the D3–D8 tables and the reference screenshots. Check the flows P30-S01 → P30-S02, P31-S01 → P32-S01, and P33-S01 → S02 → S03 → back. Write Pass/Fail per item, with evidence and screenshot paths, to `docs/manual-checks/add-tools-messages-digital-card.md`. Mismatches go back to Sonnet as a fix round. Verification: every item reads Pass, or is listed as an accepted difference (CamCard artwork, neutral template content, the step 3 offset from D6).

## 6. Full suite

- [ ] 6.1 After Opus merges the branch into `main`, run the full suite with the project's exact command: `xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" -collect-test-diagnostics never > build/test-output.log 2>&1`. Verification: `build/test-output.log` shows `** TEST SUCCEEDED **` with 0 failures, including T21, T22, the new T23 suite and `UITestRouteHookTests`.

## Workflow follow-up

- Archive after the user approves the artifacts and the full suite passes.
- After archive, append to `docs/ai-log.md`: change name, generated artifacts, what the user corrected, and test results.
