# Proposal

## Why

The shell and card storage exist, but the center scan button still opens a placeholder, so no card image can enter the app. This change builds the camera and album entry points, still-image rectangle detection, the "Card area not found" alert and the Edit Card hand-off. It produces the original/corrected image pair that the recognition change will consume. Without this entry point, OCR, field parsing and saving have nothing to work on.

## What Changes

- Replace the scan placeholder with the full-screen camera flow for P02-S01: Close (X), the Basic/High Accuracy row with Basic active, the card frame, "Tap to light up", Album and the shutter. The mode labels "Batch", "Multiple", "Single", "QR Code" are shown with "Single" selected; Batch, Multiple and QR are inert.
- Render the ••• control top right as an inert placeholder: tapping it does nothing and opens no menu. Mark it TODO(P02-S06).
- Do **not** render the "5" counter. Its meaning is unconfirmed (likely a premium quota), so it is omitted rather than guessed.
- Add camera permission handling with `NSCameraUsageDescription`. The denied state explains why access is needed and offers a way to Settings; it must not crash or leave a black preview (P02-S03/P02-S04 are not captured → ASSUMPTION).
- Replace the system PhotosPicker with CamCard's own PhotoKit album picker. Request photo access with `NSPhotoLibraryUsageDescription`. The picker opens on the "Recents" grid; a back chevron "<" top left opens the album list, and tapping an album shows that album's grid with the same "Cancel" and "Done". "Cancel" from the Recents grid, an album grid or the album list returns to the camera without starting detection. P03-S01 shows a limited-access banner with the exact text "You did not allow Camcard to access all the pictures in the album,So only show the pictures you selected." plus "Select more photos", "Allow access to all pictures", "Cancel" and a disabled "Done". P03-S02 shows an album list with "Recents" plus the user's albums and "Cancel". The selected-grid, permission prompt, denied state and full-access grid are not captured (P03-S03 through P03-S06 → ASSUMPTION). Selecting a photo and tapping "Done" starts detection.
- Keep the observed app name "Camcard" in the banner verbatim. This is a black-box replication and the spec must quote exact observed UI text; substituting our product name would deviate from P03-S01. The decision is recorded in design.md.
- Add rectangle detection with Vision (`VNDetectRectanglesRequest`) and perspective correction with Core Image. Detection and correction run off the main actor behind a small `CardDetecting` protocol.
- Keep the original image and the corrected image separate in memory. They map to `BusinessCard.originalImage` / `processedImage` in the next change; **nothing is persisted** in this change.
- While the "Card area not found" alert is shown, hide Close (X), the Basic/High Accuracy toggle, the ••• placeholder, the mode labels, Album and the counter area; keep "Tap to light up" visible; and show the shutter greyed and disabled (P04-S01). While detection is running, disable the shutter and Album so a second capture cannot start.
- Show the exact alert text: title "Card area not found", message "Move phone closer and rescan", buttons "Continue saving" and "Cancel saving". "Continue saving" opens Edit Card with the uncropped image; "Cancel saving" returns to the camera (P04-S04 is not captured → ASSUMPTION).
- Add the Edit Card shell for P05-S01: nav "Retake" / "Edit Card" / "Save", the card image, and an empty "Full Name" row. Save is visibly disabled because saving is not available yet. Retake returns to the camera.
- Update the app-shell requirement so the center scan button opens this capture flow. The camera's Close control keeps the existing accessibility identifier in design.md, so T01 is unchanged.
- Add DEBUG-only launch hooks that replace only the camera shutter with generated card/no-card images, force camera denial, and force each photo-library access state with generated fixture photos that include the card and no-card images. Injected images run through the real detection path. Album always goes through the picker (camera → Album → picker → select → Done → real detection).

### Flow decision: match CamCard

There is **no preview/confirm screen**. `reference/observations.md` and `reference/state-diagram.md` show capture → ("Card area not found" alert if detection fails) → Edit Card, with Retake on Edit Card. This intentionally differs from the assignment's generic "preview → confirm" wording; the observed CamCard flow is the target.

### State IDs covered

| State ID | Coverage |
|---|---|
| P02-S01 | Camera, Basic mode, Single selected: Close (X), Basic/High Accuracy row, ••• placeholder, card frame, "Tap to light up", Album, shutter, Batch/Multiple/QR labels inert. The "5" counter is omitted (meaning unconfirmed). |
| P02-S03 | Camera permission prompt. **ASSUMPTION** — not captured; the system prompt uses our usage string. |
| P02-S04 | Camera denied state. **ASSUMPTION** — not captured; explains why and offers Settings, with no crash or black preview. |
| P03-S01 | Limited-access album picker on the "Recents" grid: back chevron "<" top left, "Cancel", exact banner text, "Select more photos", "Allow access to all pictures", "Done" disabled until selection. Only selected photos are shown. |
| P03-S02 | Album list opened by "<": "Recents" plus the user's albums, with "Cancel". Tapping an album opens its grid (ASSUMPTION: P03-S02 shows only the list). |
| P03-S03 | Photo permission prompt. **ASSUMPTION** — not captured; uses `NSPhotoLibraryUsageDescription`. |
| P03-S04 | Photo access denied. **ASSUMPTION** — not captured; explains why and offers Settings, no crash. |
| P03-S05 | Full-access photo grid. **ASSUMPTION** — not captured; grid with Cancel and Done. |
| P03-S06 | Selected photo state. **ASSUMPTION** — not captured; selection is visible and Done becomes enabled. |
| P04-S01 | Alert with exact text. While it is shown, Close/X, the Basic/High Accuracy toggle, •••, mode labels, Album and the counter area are hidden; "Tap to light up" stays visible; the shutter is greyed and disabled. |
| P04-S04 | "Cancel saving" destination. **ASSUMPTION** — not captured; returns to the camera. |
| P05-S01 | Edit Card shell only: "Retake" / "Edit Card" / "Save", card image, empty "Full Name" row. Save disabled because saving is not available yet. |

### Test IDs covered

| Test ID | Coverage |
|---|---|
| T02 | **Covered, partly manual.** Camera chrome, inert •••, inert mode labels and Close are automated with injected fixtures; live preview and torch are a manual real-device check. |
| T03 | **Partly covered.** Camera permission handling is unit-tested through a fake provider; the denied screen is UI-tested via a launch hook. The system prompt itself is not captured (P02-S03). |
| T04 | **Not covered.** Live boundary overlay and auto-capture need P02-S05, which is not captured. Still-image detection is covered under T06. |
| T05 | **Covered for the app-owned picker, with ASSUMPTION system states.** Recents grid, back chevron to the album list, album grid, limited banner, exact text, buttons, selection, Done, Cancel and detection are automated through the fake PhotoKit provider and generated fixture photos; Album always goes through the picker rather than a scan stub. The system prompt (P03-S03), denied screen (P03-S04), full-access grid (P03-S05) and selected state (P03-S06) are ASSUMPTION and the system UI itself is not automatable. |
| T06 | **Partly covered.** No-card detection, the exact alert, its hidden-controls state and the Edit Card hand-off are covered; detected-rectangle correction is unit-tested. Auto-capture (P02-S05) and manual crop (P05-S06) are not captured and not built. |
| T20 | **Partly covered — only this flow's error cases.** No card found, "Cancel saving", camera denied and photo access denied. Recognition failure (P04-S03), saving with empty fields (P05-S09), Retake confirmation (P05-S08) and search no-results are out of scope. |
| T08, T09, T11 | **Not covered.** They need recognized fields and field editing; only the empty Edit Card shell (P05-S01) is built. |

## Capabilities

### New Capabilities

- `card-capture`: camera screen and controls, camera permission states, the PhotoKit album picker and its permission states, still-image rectangle detection and perspective correction, the "Card area not found" alert state, the Edit Card hand-off shell, and the DEBUG capture stubs used by tests.

### Modified Capabilities

- `app-shell`: the scan placeholder is removed. The center scan button now opens the capture flow, and closing it returns to the previously selected tab.

## Out of scope

- OCR, raw text capture and field parsing.
- Edit Card fields, field editing (P05-S03), Edit More Info (P05-S04), multiple phones (P05-S05), Recognition Languages (P05-S07), High Accuracy toggle, "Cards autosaved to Contacts", "Improve Recognition", and Add Backside (P05-S10).
- Card saving and Card Saved (P06), Groups (P07), Notes (P08), card detail changes (P09).
- High Accuracy mode (P02-S02), Batch/Multiple/QR capture, the ••• menu content (P02-S06), the "5" counter, live boundary overlay and auto-capture (P02-S05), and manual crop/rotate (P05-S06).
- The system PhotosPicker. The album picker is CamCard's own PhotoKit surface, as observed.
- Photo editing, multiple-photo selection, and album creation/management. The picker selects one photo and lists existing albums.
- Recognition failure (P04-S03), Retake discard confirmation (P05-S08), and saving with empty fields (P05-S09).
- Any P10+ screen, premium/paywall, login, sync, export, messages or AI assistant; CamCard artwork, icons and logos are not reproduced.

## Impact

- **App code**: `RootView` presents a new scan flow instead of `ScanPlaceholderView`; `ScanPlaceholderView` is removed. New sources under `CamCard Copy/Features/Scan` and `CamCard Copy/Features/EditCard`, plus a PhotoKit album picker under `CamCard Copy/Features/Album` and shared detection/hand-off types. `LaunchConfiguration` gains DEBUG capture, camera-denial and photo-access hooks.
- **Project file**: `project.pbxproj` gains `INFOPLIST_KEY_NSCameraUsageDescription` and `INFOPLIST_KEY_NSPhotoLibraryUsageDescription` in the app target's Debug and Release configurations. No scheme changes; file-system-synchronized groups compile new files automatically. Every project-file change is listed explicitly in design.md.
- **Tests**: new XCTest fixtures, detection/correction tests, permission tests, PhotoKit-state tests and hand-off tests in `CamCard CopyTests`; new XCUITest files for T02/T03/T05/T06/T20 in `CamCard CopyUITests`. UI tests are run by the user in Terminal.app.
- **Dependencies**: SwiftUI, AVFoundation, Vision, Core Image, PhotoKit and XCTest only. No third-party dependency.
- **Persistence**: none. No SwiftData model, schema, store or repository behavior changes, and no `card-storage` delta.
