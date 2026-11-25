# Tasks

> Decisions confirmed by the user 2026-11-25: D8 Option A (persist `extraPhones`/`extraEmails`) and D9 allow saving with all fields empty.

## 1. Model and repository (Option A only)

- [x] 1.1 Add `extraPhones: [String] = []` and `extraEmails: [String] = []` to `BusinessCard` and `CardRecord` (same defaults), and map them in `SwiftDataCardRepository.apply(_:to:)` and `record(from:)`. Do not change the schema list in `ModelContainerFactory`. Verification: extend `CardRepositoryTests` with T10 additional values round-trip, empty-collection default, and a fetch of a card created without the new fields; run `xcodebuild build-for-testing -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" > build/build-output.log 2>&1` then `xcodebuild test-without-building -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:"CamCard CopyTests/CardRepositoryTests" > build/test-output.log 2>&1` and read the log.

## 2. Save mapping

- [x] 2.1 Add `CamCard Copy/Features/CardSaved/CardSaver.swift` with `EditedCardValues`, `CardSaver.save(image:values:savedAt:)` and the `noteText(savedAt:source:)` helper per design D1/D5: `ensureGroup(named: "Ungrouped")`, empty-after-trim rows become nil, exact typed value otherwise, images and `rawOCRText` carried unchanged, `createdAt = savedAt`, exactly one note. Verification: new `CamCard CopyTests/CardSavingTests.swift` runs all mapping cases against both the in-memory and SwiftData in-memory-container harnesses (edited values win, raw OCR preserved, both images stored, `processedImage` nil when absent, exactly one card, exactly one note with exact text and timestamp, empty values nil with no fabricated name, extras round-trip, camera/album source text). Run `-only-testing:"CamCard CopyTests/CardSavingTests"` with the same build-for-testing / test-without-building pattern into `build/test-output.log` and read the log.

## 3. Scan source on the hand-off

- [x] 3.1 Add `ScanSource` (`.camera`, `.album`) and `ScannedCardImage.source` with a `.camera` default in `CardDetecting.swift`; set `.camera` on the shutter path and `.album` on the album `Done` path (including the pending image used by "Continue saving") in `CameraView.swift`. Verification: extend `ScanHandoffTests` to assert the source survives `recognizedImage(_:)` and `scannedImage(from:)`; run `-only-testing:"CamCard CopyTests/ScanHandoffTests"` and read the log.

## 4. Save from Edit Card

- [x] 4.1 Wire saving in `EditCardView.swift`: enable "Save", add an `isSaving` guard, collect the on-screen values into `EditedCardValues`, call `CardSaver.save`, and expose a save callback that pushes `.cardSaved(record)`. On failure stay on Edit Card with the ASSUMPTION error alert and push nothing. Verification: covered by task 2.1 unit tests plus task 6.2 UI test; build succeeds with `xcodebuild build-for-testing … > build/build-output.log 2>&1` and the log shows no warnings from the touched files.
- [x] 4.2 Extract the ImageIO thumbnail decoder from `EditCardView` into `CamCard Copy/Support/CardImageThumbnail.swift` and use it from both Edit Card and Card Saved; behavior is unchanged. Verification: `-only-testing:"CamCard CopyUITests/T07RecognitionUITests"` still passes (Edit Card image renders).

## 5. Card Saved screen and navigation

- [x] 5.1 Add `CamCard Copy/Features/CardSaved/CardSavedView.swift` per design D4 with "Card Saved", "Done", thumbnail, inert "Group"/"Note", inert premium "Sync"/"Export", "Take the next", no assistant panel, and the accessibility identifiers. Verification: task 6.2 asserts the text and inert actions in the running app.
- [x] 5.2 Add `ScanRoute.cardSaved(CardRecord)` in `ScanFlowView.swift`, inject the repository/`CardSaver` from `RootView.swift`, add the `onDone` callback that dismisses the cover and selects CardHolder, and make "Take the next" clear the path back to the camera. Verification: task 6.2 and 6.4 exercise Done and "Take the next" end to end.

## 6. UI tests

- [x] 6.1 Update `CamCard CopyUITests/T07RecognitionUITests.swift` and `testT05AlbumCardFixtureReachesEditCard` in `CamCard CopyUITests/T05T06CaptureUITests.swift`: "Save" is now enabled (the old disabled assertions encoded the previous behavior); keep the remaining assertions unchanged. Verification: run `-only-testing:"CamCard CopyUITests/T07RecognitionUITests" -only-testing:"CamCard CopyUITests/T05T06CaptureUITests"` and read the log.
- [x] 6.2 Add `CamCard CopyUITests/T12SaveCardUITests.swift` test 1: `-uiTestEmptyStore` + `-uiTestRecognizeDatasetImage <reference/dataset/card-01-standard.png>` → shutter → Edit Card → change "editCard.fullName" to "Maya Test" → Save → "Card Saved" with "Done", "Group", "Note", "Sync", "Export", "Take the next" and a thumbnail → tap each inert action and assert nothing opens → Done → CardHolder shows "Maya Test" → open the detail and assert the edited name, the saved fields, "Ungrouped" and the auto note. Verification: run `-only-testing:"CamCard CopyUITests/T12SaveCardUITests"` and read the log.
- [x] 6.3 Add test 2 to the same suite (T18 with a real card): save through the same path, terminate, relaunch with no arguments at all (no `-uiTestEmptyStore`, no seed), open CardHolder, assert the saved card and its edited value are still present. Verification: same `-only-testing` run as 6.2.
- [x] 6.4 Add test 3 to the same suite: Save → "Take the next" → assert the camera chrome (Close, shutter, Album, "Single" selected) is visible and no new card is created (Done after closing shows one card). Verification: same `-only-testing` run as 6.2.

## 7. Full suite

- [x] 7.1 Run the full suite and report results: `xcodebuild build-for-testing -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" > build/build-output.log 2>&1` then `xcodebuild test-without-building -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17" > build/test-output.log 2>&1`. Verification: `build/test-output.log` shows `** TEST EXECUTE SUCCEEDED **` with 0 failures across all unit and UI suites; do not run it while another test run is active.

## Workflow follow-up

- Archive the change after the user approves the artifacts and the full suite passes.
- After archive, append to `docs/ai-log.md`: change name, generated artifacts, what the user corrected, and the test results (project rule).
