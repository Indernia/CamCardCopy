# Tasks

Setup for the implementing agent (Sonnet, in its own worktree):

- Create its own simulator. Run `xcrun simctl shutdown "iPhone 17"` first if a clone is wanted, or `xcrun simctl create "iPhone 17 - home" "iPhone 17" <iOS 27 runtime>`.
- Use `-destination "platform=iOS Simulator,name=iPhone 17 - home"` for targeted runs.
- Every test run adds `-collect-test-diagnostics never` and writes to `build/test-output.log`. Require `** TEST SUCCEEDED **` before checking a task.
- Only edit the files listed in proposal.md Impact. Frozen shared files need Opus.

## 1. Search and image helpers (no UI yet)

- [x] 1.1 Add `CardHolderSearch.filter` and `cardDisplayImageData` per design D7 and D9 (in `Features/CardHolder/CardHolderSearchBar.swift` and `Features/CardHolder/CardHolderRow.swift`). Add `query`, `isSearching` and `visibleCards` to `CardHolderViewModel`. Add `CamCard CopyTests/CardHolderSearchTests.swift` with the D10 unit cases. Verification: `-only-testing:"CamCard CopyTests/CardHolderSearchTests"` passes.

## 2. CardHolder

- [x] 2.1 Restyle `CardHolderView` per D1 and D3: tinted system bar, plain bell and ⊕, white search capsule, sheet, "Cards" header, empty state. Add the D8 ⊕ menu. Keep every identifier and the `navigationTitle`. Verification: `-only-testing:"CamCard CopyUITests/T01EmptyCardHolderUITests"` passes unedited. If the ⊕ menu breaks it, stop and report.
- [x] 2.2 Add `CardHolderRow` per D9 and use it for the list; wire the search bar per D7 with "No results". Verification: `-only-testing:"CamCard CopyUITests/T12SaveCardUITests" -only-testing:"CamCard CopyUITests/T18PersistenceUITests"` pass unedited.
- [x] 2.3 Add `CamCard CopyUITests/T15SearchUITests.swift` per D10. Verification: `-only-testing:"CamCard CopyUITests/T15SearchUITests"` passes.
- [x] 2.4 Update `CardDetailView` per D9: corrected image first, plain back control, token fonts. Verification: T12 and T18 still pass, and the CardHolderSearchTests image cases pass.

## 3. Home

- [x] 3.1 Restyle `HomeView` per D1, D2 and D4 with every identifier kept. Verification: the T21 `testHomePlaceholdersExistAndAreInert` checks above its tap loop still pass (labels and texts), confirmed by running the suite after 4.1.

## 4. Wiring and changed tests

- [x] 4.1 Wire the Home bell, crown, "Create New Card" and the CardHolder bell per D5. Apply exactly the T21 and T22 assertion changes listed in proposal.md "Tests that change". Change nothing else in those files. Verification: `-only-testing:"CamCard CopyUITests/T21ShellPlaceholderUITests" -only-testing:"CamCard CopyUITests/T22VisualFoundationUITests"` pass.
- [x] 4.2 Add `CamCard CopyUITests/T24HomeCardHolderUITests.swift` per D10. Verification: `-only-testing:"CamCard CopyUITests/T24HomeCardHolderUITests"` passes.

## 5. Review

- [x] 5.1 Implementing agent: commit on its branch and leave its simulator booted with the app installed. Verification: the commit hash, plus T01, T02, T12, T15, T18, T21, T22 and T24 run together on its simulator with `Executed N tests, with 0 failures`.
- [x] 5.2 Haiku visual and flow check on that simulator. Compare Home with `P00-S01_home-empty.png` and the empty CardHolder with `P01-S01_cardholder-empty.png` against the D1 table, and walk the state-diagram transitions in D10. Write Pass/Fail with measurements to `docs/manual-checks/polish-home-cardholder.md`. Verification: every item Pass, or an accepted artwork-only difference; any Fail goes back to Sonnet for a fix round.

## 6. Full suite

- [x] 6.1 After merge to `main`, run the full suite with the exact project command: `xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" -collect-test-diagnostics never > build/test-output.log 2>&1`. Verification: `** TEST SUCCEEDED **` with 0 failures, including the new T15 and T24 suites.

## Workflow follow-up

- Archive after the full suite passes, append the ai-log entry, commit and push `main`.
