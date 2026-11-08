# card-capture Specification

## Purpose

Defines how a business card image is acquired and prepared before recognition: the camera entry screen and its controls, camera permission states, the PhotoKit album picker, still-image rectangle detection and perspective correction, the "Card area not found" alert state, and the Edit Card hand-off.

## Requirements

### Requirement: Camera entry screen

The scan flow SHALL present a full-screen camera screen in Basic mode with Single selected. It SHALL show Close (X), a top bar with "Basic", "High Accuracy" and an inert ••• placeholder, the card frame, the control "Tap to light up", the Album control, the shutter, and the mode labels "Batch", "Multiple", "Single" and "QR Code". Tapping ••• SHALL open no menu. The "5" counter SHALL NOT be rendered because its meaning is unconfirmed (likely a premium quota).

#### Scenario: T02 — Camera Basic/Single chrome is shown

- **WHEN** the user taps the center scan button
- **THEN** Close (X), the ••• placeholder, the card frame, "Tap to light up", Album and the shutter are visible
- **AND** "Batch", "Multiple", "Single" and "QR Code" are visible with "Single" selected
- **AND** "Basic" is shown as the active mode
- **AND** the "5" counter is absent

#### Scenario: T02 — The ••• placeholder is inert

- **WHEN** the user taps •••
- **THEN** no menu opens
- **AND** the camera screen stays in Basic mode with Single selected

#### Scenario: T02 — Out-of-scope mode labels are inert

- **WHEN** the user taps "Batch", "Multiple" or "QR Code"
- **THEN** "Single" remains selected and no mode change occurs

#### Scenario: T02 — Close returns to the previous tab

- **WHEN** the user taps Close (X)
- **THEN** the camera screen is dismissed and the previously selected tab is visible

#### Scenario: ASSUMPTION — "High Accuracy" label is inert (P02-S02 not captured)

- **WHEN** the user taps "High Accuracy"
- **THEN** "Basic" remains the active mode and no high-accuracy capture starts

### Requirement: Camera preview, torch and unavailable camera

The camera screen SHALL show the live preview inside the card frame when a camera device is available. "Tap to light up" SHALL toggle the device torch. When no camera device exists, the screen SHALL show a non-black explanation placeholder instead of a preview and SHALL NOT crash.

#### Scenario: T02 — Torch toggle is a manual real-device check

- **WHEN** the user taps "Tap to light up" on a device with a torch
- **THEN** the torch state toggles
- **AND** this scenario is verified manually on a real device, not by an automated simulator test

#### Scenario: ASSUMPTION — No camera device shows an explanation (simulator)

- **WHEN** the camera screen opens on a device with no camera
- **THEN** an explanation placeholder is shown in the card frame
- **AND** the preview area is not black and the app does not crash

### Requirement: Camera permission and denied state

The app SHALL request camera access with an `NSCameraUsageDescription` usage string. When access is denied or restricted, the camera screen SHALL explain why camera access is needed and SHALL offer a control that opens the app's Settings page. The denied state SHALL NOT crash and SHALL NOT show a black preview. P02-S03 and P02-S04 are not captured, so the exact prompt and denied-state copy are ASSUMPTION.

#### Scenario: T03 — Permission is requested before the preview starts

- **WHEN** camera access has not been decided and the camera screen opens
- **THEN** the system camera prompt is requested with our usage string
- **AND** the app remains running (ASSUMPTION: P02-S03 not captured)

#### Scenario: T03/T20 — Denied state explains and offers Settings

- **WHEN** camera access is denied or restricted
- **THEN** an explanation of why camera access is needed and an "Open Settings" control are visible
- **AND** the preview area is not black and the app does not crash (ASSUMPTION: P02-S04 not captured)

#### Scenario: T20 — Denied state can still be dismissed

- **WHEN** the camera is denied and the user taps Close (X)
- **THEN** the camera screen is dismissed and the previously selected tab is visible
- **AND** no crash occurs

### Requirement: Album picker — limited access

The Album control SHALL present an in-app PhotoKit picker, not the system PhotosPicker. With limited access it SHALL show the exact banner quoted in the scenarios, "Select more photos", "Allow access to all pictures", "Cancel", and a "Done" control that is disabled until a photo is selected. The grid SHALL show only the photos the user allowed.

#### Scenario: T05 — Limited access shows the exact banner and actions

- **WHEN** photo access is limited and the user taps Album
- **THEN** the banner "You did not allow Camcard to access all the pictures in the album,So only show the pictures you selected." is visible
- **AND** "Select more photos" and "Allow access to all pictures" are visible
- **AND** "Cancel" is visible
- **AND** "Done" is disabled

#### Scenario: T05 — Limited access shows only the selected photos

- **WHEN** photo access is limited and the grid is shown
- **THEN** the grid shows only the photos the user allowed
- **AND** photos outside that selection are not shown

#### Scenario: T05 — "Select more photos" opens the system limited-library picker

- **WHEN** the user taps "Select more photos"
- **THEN** the system limited-library picker is presented
- **AND** the in-app picker stays behind it (ASSUMPTION: this action is not captured)

#### Scenario: T05 — "Allow access to all pictures" offers a way to Settings

- **WHEN** the user taps "Allow access to all pictures"
- **THEN** the app's Settings page is opened
- **AND** the app does not crash (ASSUMPTION: this action is not captured)

### Requirement: Album picker — albums, full access, denial and selection

The picker SHALL request photo access with an `NSPhotoLibraryUsageDescription` usage string and SHALL offer an album list with "Recents" plus the user's albums and "Cancel". With full access it SHALL show a photo grid with "Cancel" and "Done". When access is denied it SHALL explain why and offer Settings without crashing. Selecting one photo and tapping "Done" SHALL start detection.

#### Scenario: T05 — Album list shows Recents and the user's albums

- **WHEN** the user opens the album list
- **THEN** "Recents" and the user's albums are visible
- **AND** "Cancel" is visible

#### Scenario: ASSUMPTION — Photo permission prompt is shown (P03-S03 not captured)

- **WHEN** photo access has not been decided and the user taps Album
- **THEN** the system photo permission prompt is requested with our usage string
- **AND** the app remains running

#### Scenario: T05/T20 — Photo access denied explains and offers Settings (ASSUMPTION: P03-S04 not captured)

- **WHEN** photo access is denied or restricted
- **THEN** an explanation of why photo access is needed and an "Open Settings" control are visible
- **AND** the app does not crash
- **AND** no blank dead-end screen is shown

#### Scenario: ASSUMPTION — Full-access grid is shown (P03-S05 not captured)

- **WHEN** photo access is full
- **THEN** a photo grid with "Cancel" and "Done" is shown
- **AND** "Done" is disabled until a photo is selected

#### Scenario: ASSUMPTION — A selected photo enables Done (P03-S06 not captured)

- **WHEN** the user selects a photo
- **THEN** the selection is visible and "Done" becomes enabled

#### Scenario: T05 — Selecting a photo and tapping Done starts detection

- **WHEN** the user selects a photo and taps "Done"
- **THEN** the picker closes and detection starts on that photo
- **AND** the flow continues to Edit Card or to the "Card area not found" alert

### Requirement: Album picker navigation

The picker SHALL open on the "Recents" grid with a back chevron "<" at the top left. Tapping "<" SHALL show the album list. Tapping an album SHALL show that album's grid with the same "Cancel" and "Done" behaviour. "Cancel" from the Recents grid, an album grid or the album list SHALL return to the camera without starting detection.

#### Scenario: T05 — Back chevron opens the album list

- **WHEN** the picker opens on the "Recents" grid
- **THEN** a back chevron "<" is visible at the top left
- **AND** tapping "<" shows the album list

#### Scenario: T05 — Tapping an album shows its grid (ASSUMPTION: P03-S02 shows only the list)

- **WHEN** the user taps an album in the album list
- **THEN** that album's grid is shown
- **AND** "Cancel" and "Done" are visible with the same behaviour as the Recents grid

#### Scenario: T05 — Cancel returns to the camera from either screen

- **WHEN** the user taps "Cancel" on the Recents grid, an album grid or the album list
- **THEN** the picker closes and the camera is visible
- **AND** no detection starts

### Requirement: Rectangle detection and perspective correction

After a capture or an import, the app SHALL detect a card rectangle in the still image. When a rectangle is found, the app SHALL produce a perspective-corrected image. The original image SHALL be retained unchanged and kept separate from the corrected image. Detection and correction SHALL not block the camera UI. Detection of live frames, auto-capture and manual crop are not part of this change.

#### Scenario: T06-U1 — A rotated synthetic card yields a rectangle and a corrected image

- **WHEN** a synthetic card image rotated on a contrasting background is passed to detection
- **THEN** a card rectangle is reported
- **AND** a perspective-corrected image is produced
- **AND** the original image data is unchanged

#### Scenario: T06-U2 — A plain image yields no card

- **WHEN** a synthetic image without a card rectangle is passed to detection
- **THEN** no card rectangle is reported
- **AND** no corrected image is produced

#### Scenario: T06 — Correction failure is treated as no card found (ASSUMPTION)

- **WHEN** detection reports a rectangle but correction cannot produce an image
- **THEN** the flow follows the "Card area not found" alert with the uncropped image
- **AND** the app does not crash

### Requirement: "Card area not found" alert

When no card rectangle is detected after a capture or import, the app SHALL show an alert with the exact title "Card area not found", message "Move phone closer and rescan", and buttons "Continue saving" and "Cancel saving". The camera chrome and shutter SHALL match the alert-state scenarios. "Continue saving" SHALL continue to Edit Card with the uncropped image; "Cancel saving" SHALL return to the camera.

#### Scenario: T06/T20 — Alert shows the exact text

- **WHEN** detection finds no card rectangle
- **THEN** the alert title "Card area not found" is visible
- **AND** the message "Move phone closer and rescan" is visible
- **AND** the buttons "Continue saving" and "Cancel saving" are visible

#### Scenario: T06/T20 — Alert hides the camera controls and greys the shutter

- **WHEN** the "Card area not found" alert is shown
- **THEN** Close (X), "Basic", "High Accuracy", •••, "Batch", "Multiple", "Single", "QR Code", Album and the counter area are not visible
- **AND** "Tap to light up" remains visible
- **AND** the shutter is visible but greyed and disabled

#### Scenario: ASSUMPTION — Shutter and Album are disabled while detection runs

- **WHEN** detection is in progress after a capture or import
- **THEN** the shutter and Album are disabled
- **AND** a second capture or import cannot start

#### Scenario: T06 — "Continue saving" opens Edit Card with the uncropped image

- **WHEN** the user taps "Continue saving"
- **THEN** the Edit Card screen is shown with the uncropped original image
- **AND** no corrected image is used

#### Scenario: T20 — "Cancel saving" returns to the camera (ASSUMPTION: P04-S04 not captured)

- **WHEN** the user taps "Cancel saving"
- **THEN** the alert is dismissed and the camera screen is visible again
- **AND** no Edit Card screen is shown and no card is saved

### Requirement: Edit Card hand-off shell

After a successful capture or import, or after "Continue saving", the app SHALL show the Edit Card screen with "Retake" leading, "Edit Card" as the title, "Save" trailing, the card image, and an empty "Full Name" row. "Save" SHALL be visibly disabled because saving is not available yet. "Retake" SHALL return to the camera without saving.

#### Scenario: ASSUMPTION — Edit Card shell is shown with disabled Save (P05-S01 shell only; T08/T09/T11 not covered)

- **WHEN** the flow reaches Edit Card
- **THEN** "Retake", "Edit Card" and "Save" are visible
- **AND** "Save" is disabled
- **AND** the card image and an empty "Full Name" row are visible
- **AND** the empty row shows no fabricated value

#### Scenario: ASSUMPTION — Retake returns to the camera (P05-S08 not captured)

- **WHEN** the user taps "Retake"
- **THEN** the camera screen is shown again
- **AND** no card is saved and no discard confirmation is shown

### Requirement: Image hand-off without persistence

The flow SHALL carry the original image and, when available, the corrected image from capture or import to Edit Card. Edit Card SHALL NOT create, update or persist a card; the Save control SHALL be disabled because saving is not available yet. The two images SHALL remain separate.

#### Scenario: ASSUMPTION — Edit Card does not save a card (saving is not available yet)

- **WHEN** the flow reaches Edit Card, including through "Continue saving"
- **THEN** the card repository still contains the same number of cards as before
- **AND** no card record is created or updated

#### Scenario: T06 — Original and corrected images stay distinct

- **WHEN** detection finds a card and correction succeeds
- **THEN** the original image data and the corrected image data are both retained
- **AND** the original image data is not replaced by the corrected image

### Requirement: DEBUG capture stubs

Debug builds SHALL accept launch arguments that replace the camera shutter with generated card/no-card images, force camera denial, and force each photo-library access state with generated fixture photos that include card and no-card images. Album SHALL always go through the album picker. UI-test images SHALL use the real detection path; a stub detector SHALL only cover cases that cannot occur naturally. These arguments SHALL have no effect in release builds or on a normal launch.

#### Scenario: T06 — The camera card fixture runs the real detection path

- **WHEN** the app launches in DEBUG with the card fixture and the user taps the shutter
- **THEN** the same detection and correction path used for real captures runs
- **AND** the flow reaches Edit Card without a canned result

#### Scenario: T06 — The camera no-card fixture shows the alert

- **WHEN** the app launches in DEBUG with the no-card fixture and the user taps the shutter
- **THEN** detection finds no card on the fixture
- **AND** the "Card area not found" alert is shown

#### Scenario: T05 — Album always goes through the picker

- **WHEN** the app launches in DEBUG with a camera fixture and the user taps Album
- **THEN** the album picker opens instead of handing the camera fixture straight to Edit Card
- **AND** selecting the generated card fixture photo and tapping "Done" runs the real detection path and reaches Edit Card
- **AND** selecting the generated no-card fixture photo and tapping "Done" shows the "Card area not found" alert

#### Scenario: T05 — Forced limited access shows the banner and fixture photos

- **WHEN** the app launches in DEBUG with the limited-access photo hook
- **THEN** the limited banner and generated fixture photos are shown
- **AND** no real photo library or permission prompt is used

#### Scenario: T05 — Forced full access shows the fixture grid

- **WHEN** the app launches in DEBUG with the full-access photo hook
- **THEN** the full-access grid with generated fixture photos is shown
- **AND** no real photo library or permission prompt is used

#### Scenario: T05 — Forced not-determined access requests then resolves

- **WHEN** the app launches in DEBUG with the not-determined photo hook
- **THEN** the app requests access through the injected provider
- **AND** the picker resolves to the provider's result without the real system prompt

#### Scenario: T05/T20 — Forced photo denied shows the denied state

- **WHEN** the app launches in DEBUG with the photo-denied hook
- **THEN** the explanation and "Open Settings" control are shown
- **AND** no real photo library is used

#### Scenario: T03/T20 — The camera-denied hook shows the denied state

- **WHEN** the app launches in DEBUG with the camera-denied hook
- **THEN** the denied state with its explanation and "Open Settings" control is shown
- **AND** no system camera prompt appears

#### Scenario: ASSUMPTION — Hooks do not affect a normal launch

- **WHEN** the app launches without a hook
- **THEN** the real camera and PhotoKit paths are used
- **AND** the hooks have no effect
