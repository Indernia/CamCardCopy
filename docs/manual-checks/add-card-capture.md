# Manual checks — add-card-capture

Fill in the **Result** and **Notes** columns while testing. Result is one of: Pass / Fail / Not tested.

Exact UI strings quoted from `openspec/changes/add-card-capture/specs/card-capture/spec.md` and `app-shell/spec.md`.

## 5.1 Real-device camera (iPhone only)

T04 (live boundary overlay and auto-capture) is **not built** — skip any expectation of an overlay or auto-capture.

| # | Check | State / Test ID | Expected result (exact UI text) | Result | Notes |
|---|-------|-----------------|----------------------------------|--------|-------|
| 1 | Live preview | P02-S01 | The card frame shows the live camera preview (not black). | Pass | iPhone, 2026-11-08: live preview shows in the frame. |
| 2 | Torch toggle | P02-S01 | Tapping "Tap to light up" turns the torch on; tapping again turns it off. | Pass | iPhone: torch toggles on/off. |
| 3 | Real card → Edit Card | P02-S01 → P05-S01 | Capturing a real business card reaches Edit Card with the cropped (perspective-corrected) card image. | Pass | iPhone: real card capture opens Edit Card with the cropped card. |
| 4 | Non-card scene → alert | P04-S01 | Capturing a non-card scene shows the alert titled **"Card area not found"** with message **"Move phone closer and rescan"** and buttons **"Continue saving"** and **"Cancel saving"**. | Pass | iPhone: alert appears quickly after the freeze fixes. |
| 5 | Alert hides camera controls | P04-S01 | While the alert is shown, Close (X), "Basic", "High Accuracy", •••, "Batch", "Multiple", "Single", "QR Code", Album and the counter area are **not** visible; **"Tap to light up"** remains visible; the shutter is greyed and disabled. | Pass | iPhone: controls hidden, "Tap to light up" visible, shutter greyed. |
| 6 | Continue saving | P04-S01 | Tapping **"Continue saving"** opens Edit Card with the uncropped original image. | Pass | iPhone: responds straight away after the stable-layout fix. |
| 7 | Cancel saving | P04-S04 (ASSUMPTION) | Tapping **"Cancel saving"** dismisses the alert and returns to the camera; no Edit Card screen, no card saved. | Pass | iPhone: responds straight away. |
| 8 | First-launch camera prompt | P02-S03 (ASSUMPTION) | On first launch, the system camera permission prompt appears with the usage string. Accept → preview starts. | Pass | iPhone: prompt appears; accept starts the preview. |
| 9 | Denied state | P02-S04 (ASSUMPTION) | After refusing camera access, the screen explains **"Camera access is needed to photograph business cards."** and shows an **"Open Settings"** button; the preview area is not black; no crash. | Pass | "Photo access is needed to import business cards." + Open Settings + Cancel; Cancel returns to camera; no crash. |
| 10 | Close returns Home | P02-S01 / T02 | Tapping Close (X) dismisses the camera and returns to the previously selected tab. | Pass | iPhone: Close returns Home. |
| 11 | No crash | all | No crash or black preview at any point. | Pass | iPhone: Retake restarts the live camera; denied-state shutter is disabled and does not crash. |

Simulator run (2026-11-08, iPhone 17, no camera): rows 1–3, 8, 9 and 10 need a real device and stay Not tested. The alert flow (rows 4–7) was exercised via Album on the simulator:
- Row 4/5 equivalent: flower photo → exact alert; Close, modes, •••, Album hidden; "Tap to light up" visible; shutter greyed — Pass (simulator, via Album).
- Row 6 equivalent: "Continue saving" → Edit Card with the full uncropped photo — Pass (simulator).
- Row 7 equivalent: "Cancel saving" → camera with all controls back — Pass (simulator).
- Retake on Edit Card returns to camera — Pass (simulator).
- **FIXED — shutter crash:** tapping the shutter with no running camera no longer crashes. `canStartScan` now requires `.authorized`, the shutter is disabled in the denied/restricted/no-camera states, and `CameraSession.capturePhoto()` returns nil when there is no active video connection. Retake restarts the session via `.onAppear`. Verified: `T03T20CameraDeniedUITests.testT03DeniedStateShutterIsDisabledAndDoesNotCrash` and `T05T06CaptureUITests.testT06RetakeReturnsToLiveCameraAndCapturesAgain` pass; full suite green 2026-11-08 (55 tests, 0 failures).

## 5.2 Photo library states (simulator or device)

Reset photo privacy before each state (see "How to reset" below).

| # | Check | State / Test ID | Expected result (exact UI text) | Result | Notes |
|---|-------|-----------------|----------------------------------|--------|-------|
| 1 | System photo prompt | P03-S03 (ASSUMPTION) | On first Album tap with not-determined access, the system photo permission prompt appears with the usage string. | Pass | iPhone 17 sim, 2026-11-08: prompt shows "CamCard uses your photo library so you can import business card photos for scanning." with Select Photos / Allow Full Access / Don't Allow. |
| 2 | Limited-access banner | P03-S01 | With limited access, the banner **"You did not allow Camcard to access all the pictures in the album,So only show the pictures you selected."** is visible, plus **"Select more photos"** and **"Allow access to all pictures"**. The grid shows only allowed photos. | Pass | Exact banner text, both actions visible; grid showed only the 2 selected photos; Done disabled until selection. |
| 3 | Back chevron → album list | P03-S02 | The picker opens on the "Recents" grid; the back chevron "<" top-left opens the album list showing "Recents" plus user albums and "Cancel". | Pass | Opens on Recents grid; "<" shows list with "Recents" and Cancel (simulator has no user albums). |
| 4 | Album grid | P03-S02 (ASSUMPTION) | Tapping an album in the list opens that album's grid with the same "Cancel" and "Done" behaviour. | Pass | Tapping Recents in the list opens its grid with banner, Cancel and Done. |
| 5 | Full-access grid | P03-S05 (ASSUMPTION) | With full access, a photo grid with "Cancel" and "Done" is shown; "Done" is disabled until a photo is selected. | Pass | After Allow Full Access: all 10 photos, no banner, Cancel, Done disabled. |
| 6 | Selection enables Done | P03-S06 (ASSUMPTION) | Selecting a photo makes the selection visible and enables "Done". | Pass | Selected photo gets a blue border; Done enables. Done on card photo → Edit Card with cropped card; on flower photo → "Card area not found" alert. |
| 7 | Denied state | P03-S04 (ASSUMPTION) | With denied/restricted access, an explanation of why photo access is needed and an **"Open Settings"** control are visible; no crash, no blank dead-end. | Pass | "Photo access is needed to import business cards." + Open Settings + Cancel; Cancel returns to camera; no crash. |

## How to reset

**Simulator:**
```
xcrun simctl privacy booted reset photos com.alexlundbergpersonalteam.CamCardCopy
xcrun simctl privacy booted reset camera com.alexlundbergpersonalteam.CamCardCopy
```

**Device:**
Delete the app and reinstall it.
