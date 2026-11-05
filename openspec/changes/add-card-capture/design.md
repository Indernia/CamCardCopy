# Design

## Context

See proposal.md for motivation and `specs/` for required behavior.

The app already has a custom tab shell, a `CardRepository`, and `BusinessCard` fields for `originalImage`/`processedImage`, but the center scan button still presents `ScanPlaceholderView`. Both app and test targets use Xcode file-system-synchronized groups (`PBXFileSystemSynchronizedRootGroup`), so new Swift files under `CamCard Copy/`, `CamCard CopyTests/` and `CamCard CopyUITests/` compile without adding project entries. The app target uses a generated Info.plist (`GENERATE_INFOPLIST_FILE = YES`) and sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` with `SWIFT_APPROACHABLE_CONCURRENCY = YES`.

`reference/dataset/` is empty, so all detection and photo fixtures are generated in code. The iOS Simulator has no camera, so live capture is a manual real-device check only. PhotoKit is available on the simulator, but tests must not depend on its real library.

## Goals / Non-Goals

**Goals:**

- A full-screen capture flow that matches P02-S01's chrome and the observed CamCard navigation in `reference/state-diagram.md`.
- Camera permission states that never crash or show a black preview, including no-camera simulator behavior.
- CamCard's own PhotoKit album picker for P03-S01/P03-S02, with limited/full/denied/not-determined handling and fixture-backed test seams.
- Still-image rectangle detection and perspective correction running off the main actor.
- The exact P04-S01 alert, including its hidden-controls and greyed-shutter state, and the P05-S01 Edit Card shell with Save disabled.
- Deterministic DEBUG launch hooks for UI tests, matching the existing `-uiTestEmptyStore` / `-uiTestSeedCards` pattern.

**Non-Goals:**

- A preview/confirm screen. CamCard's observed flow goes capture → alert (if needed) → Edit Card.
- OCR, field parsing, field editing, saving, groups, notes or Card Saved.
- Live-frame boundary overlay, auto-capture, manual crop, High Accuracy capture, Batch/Multiple/QR capture, the ••• menu content or the "5" counter.
- The system PhotosPicker, photo editing, multiple-photo selection, or album creation/management.
- Any change to the SwiftData schema, repository contract or stored data.

## Decisions

### D1 — Full-screen flow with an internal NavigationStack; no confirm screen

`RootView` keeps its `.fullScreenCover` and presents `ScanFlowView` instead of `ScanPlaceholderView`. `ScanFlowView` owns a `NavigationStack(path:)` whose root is `CameraView` and whose only route is `.editCard(ScannedCardImage)`.

- Close (X) on the camera dismisses the cover and returns to the previously selected tab.
- "Retake" on Edit Card pops the stack back to the camera.
- "Cancel saving" on the alert dismisses it and stays on the camera.
- The camera's Close control keeps the accessibility identifier `scan.close`, so the untouched `T01EmptyCardHolderUITests` still passes.
- The Album picker is a `fullScreenCover` presented from the camera. It opens on the "Recents" grid; its back chevron "<" opens the album list, and tapping an album shows that album's grid. Cancel or Done returns to the camera.

CamCard shows no preview/confirm screen: `observations.md` and `state-diagram.md` record capture → ("Card area not found" alert if detection fails) → Edit Card, with Retake on Edit Card. This intentionally differs from the assignment's generic "preview → confirm" wording. A separate preview screen was rejected because it would invent a state CamCard does not have. A second full-screen cover for Edit Card was rejected in favour of one `NavigationStack`, which keeps Retake and the nav bar (`Retake` / `Edit Card` / `Save`) simple.

### D2 — Camera acquisition, preview and permission state machine

`CameraViewModel` (`@Observable`, `@MainActor`) holds a `CameraPermissionState` and an `isProcessingCard` flag. While `isProcessingCard` is true, the shutter and Album controls are disabled so a second capture or import cannot start. `CameraSession` is a `nonisolated` final class that owns `AVCaptureSession`, `AVCapturePhotoOutput` and the torch control, and starts/stops the session on its own serial queue so blocking AVFoundation work stays off the main actor. `CameraPreviewView` is a small `UIViewRepresentable` that hosts an `AVCaptureVideoPreviewLayer`.

Camera authorization sits behind a `CameraAuthorizationProviding` protocol with a real implementation (`AVCaptureDevice.authorizationStatus` / `requestAccess`) and a fake used by unit tests. States:

- `.authorized` → start the session and show the preview.
- `.notDetermined` → request access once, then re-evaluate.
- `.denied` / `.restricted` → show an explanation and an "Open Settings" button (`UIApplication.openSettingsURLString`); the Close control still works.
- `.noCamera` → show a non-black explanation placeholder and do **not** request permission.

The `.noCamera` branch is deliberate: the simulator has no video device, and skipping the request prevents a system alert from interfering with the existing T01 scan open/close test. It also satisfies "must not show a black preview". The exact prompt copy and denied-state copy are ASSUMPTION because P02-S03/P02-S04 are not captured.

"Tap to light up" toggles the torch through `AVCaptureDevice.torchMode`. If the device has no torch, the control is a no-op; the label is assumed not to change (unobserved).

### D3 — CamCard's PhotoKit album picker

The Album control presents an in-app picker backed by PhotoKit, not the system `PhotosPicker`. PhotoKit sits behind a `PhotoLibraryProviding` protocol with:

- `PhotoAccessState`: `.notDetermined`, `.full`, `.limited`, `.denied`, `.restricted`.
- `PhotoAsset` (identifier plus thumbnail data) and `PhotoAlbum` (identifier, title, kind such as Recents).
- Authorization status and request.
- Album and asset fetching, thumbnail/photo data loading.
- Presenting the system limited-library picker.

The real implementation, `PhotoKitLibrary`, requests `.readWrite` access (reading photos is the only requirement) and uses `PHImageManager` for thumbnails and full image data on a background queue. The fake implementation, `FakePhotoLibrary`, returns generated fixture photos and a forced access state, so neither unit tests nor UI tests touch the real library.

Picker composition, matching P03-S01/P03-S02:

- The picker opens on the "Recents" grid. It shows a back chevron "<" top left, "Cancel" top right, a photo grid, and "Done" at the bottom, disabled until a photo is selected.
- Tapping "<" opens the album list; tapping an album opens that album's grid with the same "Cancel" and "Done" behaviour. "Cancel" from the Recents grid, an album grid or the album list returns to the camera.
- With limited access, the banner with the exact text "You did not allow Camcard to access all the pictures in the album,So only show the pictures you selected." sits above the grid, with "Select more photos" and "Allow access to all pictures". The grid shows only the accessible (selected) photos.
- "Select more photos" presents the system limited-library picker via `PHPhotoLibrary.presentLimitedLibraryPicker`; "Allow access to all pictures" opens the app's Settings page. Both actions are ASSUMPTION because P03-S01 captures only the initial state.
- The album list (P03-S02) shows "Recents" plus the user's albums with "Cancel". An album with no title is rendered as a blank row, matching the observed unnamed album. Tapping an album opens its grid; this is not shown in P03-S02, so the album-grid transition is ASSUMPTION.
- With full access, the grid shows all photos with "Cancel" and "Done" (P03-S05 is ASSUMPTION: not captured).
- Selection is visible and enables "Done" (P03-S06 is ASSUMPTION: not captured). One photo only.
- Denied/restricted shows an explanation and "Open Settings" (P03-S04 is ASSUMPTION: not captured) and never crashes or dead-ends.
- Not determined triggers the system prompt with `NSPhotoLibraryUsageDescription` (P03-S03 is ASSUMPTION: not captured).

Selecting a photo and tapping "Done" dismisses the picker, loads the image data and starts detection, the same downstream path as the shutter.

**App-name decision (decided):** the banner keeps the observed product name "Camcard" verbatim rather than substituting ours. `config.yaml` requires quoting exact observed UI text, and this change is a black-box replication; substituting our name would silently deviate from P03-S01. The string is isolated in one UI constant but the decision is final for this change, not an open question.

PhotoKit was chosen over `PhotosPicker` because the user decision is to replicate P03-S01/P03-S02, including the limited-access banner and album list, which `PhotosPicker` does not expose. The cost is a photo-library usage string and a real authorization state machine, both covered by the fake-provider tests.

### D4 — Detection behind `CardDetecting`; Core Image correction off the main actor

Detection is defined by a small `nonisolated` protocol:

```swift
protocol CardDetecting: Sendable {
    func detectCard(in imageData: Data) async throws -> DetectedCard?
}
```

- `DetectedCard` carries the detected rectangle/corners and the corrected image data.
- `VisionCardDetector` is the real implementation, marked `@concurrent` (async), and runs `VNDetectRectanglesRequest` (`maximumObservations: 1`, conservative `minimumAspectRatio`/`minimumSize`/`minimumConfidence`) followed by Core Image `CIPerspectiveCorrection` using the observation's corners. It returns `nil` when no rectangle is found. Threshold values are ASSUMPTION and tuned against generated fixtures first, then a real card.
- `StubCardDetector` exists only for cases that cannot occur naturally, such as a correction failure; it is not used by the UI-test happy path.
- UI tests inject the generated card/no-card images but run the **real** `VisionCardDetector`, so the fixture path is genuine end to end. The fixtures are high-contrast and generated in code, and real-card behavior remains a manual check because Vision on generated images is not a perfect proxy.
- The protocol is `nonisolated` and the implementation is `@concurrent` so image decoding and Vision/Core Image work stay off the main actor, as `config.yaml` requires.

The flow keeps a `ScannedCardImage` value:

```swift
struct ScannedCardImage: Equatable, Sendable {
    let originalImage: Data
    let processedImage: Data?
}
```

The original data is never overwritten. Edit Card displays `processedImage` when present, otherwise `originalImage`. "Continue saving" therefore shows the uncropped original. This maps directly to `BusinessCard.originalImage` / `processedImage` later; nothing is persisted now.

If detection throws, or correction cannot produce data, the flow treats it as "no card found" and shows the P04-S01 alert with the original image. This avoids a crash path and is marked ASSUMPTION (P04-S03 is not captured).

### D5 — Screen composition, exact text and inert controls

**Camera (`CameraView`), normal state**

- Full-screen dark background; no navigation bar.
- Top: Close (X) (`scan.close`), the Basic/High Accuracy segmented row with "Basic" active, and an inert ••• placeholder at top right (`scan.more`). Tapping ••• does nothing and opens no menu; the code carries `// TODO(P02-S06)`.
- Card frame: a rounded-rectangle border with a light stroke; the preview or the unavailable/denied explanation sits inside it.
- Near the bottom of the frame: "Tap to light up" (`scan.torch`).
- Below the frame: "Batch", "Multiple", "Single", "QR Code" with "Single" selected and underlined; these labels are plain `Text` (not buttons) so they are inert, each annotated `// TODO(P02-S02/P02-S05)`.
- "High Accuracy" is a label only, annotated `// TODO(P02-S02)`; "Basic" stays active.
- Bottom row: Album (`scan.album`) and the shutter (`scan.shutter`). The "5" counter is not rendered because its meaning is unconfirmed; the counter area stays empty (`// TODO(P02-S06)`).

**Processing state:** while `isProcessingCard` is true, the shutter and Album are visibly disabled and cannot start a second capture or import.

**Alert state (P04-S01):** the alert is presented over the card frame. While it is up, Close (X), the Basic/High Accuracy row, •••, the mode labels, Album and the counter area are hidden; the card frame and "Tap to light up" remain; and the shutter remains visible but greyed and disabled. Only "Continue saving" and "Cancel saving" remain actionable.

**Denied / unavailable:** icon, a short explanation, and "Open Settings" (`scan.openSettings`); the background is the app's dark surface, never a black preview.

**Album picker:** a full-screen view that opens on the "Recents" grid, with a back chevron "<" top left, "Cancel" top right, the limited banner (exact text), "Select more photos", "Allow access to all pictures", a grid of thumbnails, and "Done" disabled until selection. The back chevron opens the album list, which shows "Recents" and the user's albums with folder glyphs and chevrons; tapping an album opens its grid with the same "Cancel" and "Done". Denied shows an explanation plus "Open Settings".

**Edit Card (`EditCardView`):** a `NavigationStack` destination with the back button hidden. Toolbar leading "Retake" (`editCard.retake`), inline title "Edit Card", trailing "Save" (`editCard.save`) with `.disabled(true)` and `// TODO(recognition-change)`; the image is `processedImage` or `originalImage` with an inert crop glyph annotated `// TODO(P05-S06)`. Below it, a read-only "Full Name" row with no value and `// TODO(recognition-change)`. No High Accuracy toggle, Recognition Languages, Edit More Info, Add Backside, "Cards autosaved to Contacts" or "Improve Recognition" rows are rendered. Retake pops to the camera; no discard confirmation is shown (P05-S08 not captured).

### D6 — DEBUG hooks for deterministic UI tests

`LaunchConfiguration` gains DEBUG-only values, parsed from launch arguments:

| Argument | Effect |
|---|---|
| `-uiTestScanStubCard` | The camera shutter uses a generated card fixture; the camera preview and Album are unaffected, so Album still opens `AlbumPickerView`. The real `VisionCardDetector` runs. |
| `-uiTestScanStubNoCard` | The camera shutter uses a generated plain image; the camera preview and Album are unaffected; the real detector returns nil, so the P04-S01 alert appears. |
| `-uiTestScanStubCameraDenied` | Camera screen shows the denied state without requesting permission. |
| `-uiTestPhotoLibraryFullAccess` | `FakePhotoLibrary` reports `.full` with generated fixture photos that include the card and no-card images. |
| `-uiTestPhotoLibraryLimited` | `FakePhotoLibrary` reports `.limited` with the same fixture photos and the banner. |
| `-uiTestPhotoLibraryDenied` | `FakePhotoLibrary` reports `.denied`, so the denied view appears. |
| `-uiTestPhotoLibraryNotDetermined` | `FakePhotoLibrary` reports `.notDetermined`; its first request resolves deterministically so the request path runs without the system prompt. |

Release builds and normal launches ignore these arguments and use the real camera, PhotoKit and `VisionCardDetector`. Album never uses a scan fixture as a shortcut: it always goes camera → Album → `AlbumPickerView` → picker → select → Done → real detection. The fake library returns only generated fixtures, so the simulator's real photo library is never required.

`ScanFixtureFactory` (compiled into the app target) renders the fixtures with `UIGraphicsImageRenderer`: a light rounded rectangle rotated on a contrasting background for the card case, and a plain gradient for the no-card case. `PhotoFixtureFactory` renders thumbnail fixtures that include both the card and no-card images for the fake album. No CamCard artwork is used. Unit tests in `CamCard CopyTests` use the same factories through `@testable import`.

### D7 — Project-file and scheme changes (explicit)

Because the Info.plist is generated, both usage strings must be added as build settings. These are the **only** project-file changes:

| File | Configuration | Change |
|---|---|---|
| `CamCard Copy.xcodeproj/project.pbxproj` | App target "CamCard Copy" Debug (`000000000000000111000000`) | Add `INFOPLIST_KEY_NSCameraUsageDescription = "CamCard uses the camera to photograph business cards for scanning.";` alongside the existing `INFOPLIST_KEY_*` entries. |
| `CamCard Copy.xcodeproj/project.pbxproj` | App target "CamCard Copy" Release (`000000000000000112000000`) | Add the same `INFOPLIST_KEY_NSCameraUsageDescription` entry. |
| `CamCard Copy.xcodeproj/project.pbxproj` | App target "CamCard Copy" Debug (`000000000000000111000000`) | Add `INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "CamCard uses your photo library so you can import business card photos for scanning.";` alongside the existing `INFOPLIST_KEY_*` entries. |
| `CamCard Copy.xcodeproj/project.pbxproj` | App target "CamCard Copy" Release (`000000000000000112000000`) | Add the same `INFOPLIST_KEY_NSPhotoLibraryUsageDescription` entry. |

No other `project.pbxproj` edits are needed: both targets use file-system-synchronized groups, so new sources and tests need no entries. `CamCard Copy.xcodeproj/xcshareddata/xcschemes/CamCard Copy.xcscheme` is **unchanged**. No entitlements, capabilities or test-target Info.plist changes are added. The photo usage string is ASSUMPTION because P03-S03 is not captured.

Missing these keys would terminate the app when the camera or photo library is first accessed, so both are verified by a build and by the manual device checks.

### D8 — Files and types touched

**Modified**

| File | Change |
|---|---|
| `CamCard Copy/Features/Shell/RootView.swift` | Present `ScanFlowView` in the existing `.fullScreenCover` instead of `ScanPlaceholderView`. |
| `CamCard Copy/Support/LaunchConfiguration.swift` | Add the DEBUG-only scan, camera-denial and photo-library hooks. |
| `CamCard Copy.xcodeproj/project.pbxproj` | The four `INFOPLIST_KEY_NSCameraUsageDescription` / `INFOPLIST_KEY_NSPhotoLibraryUsageDescription` entries listed in D7. |

**Deleted**

| File | Reason |
|---|---|
| `CamCard Copy/Features/Scan/ScanPlaceholderView.swift` | Replaced by the real capture flow. |

**Added**

| File | Types / responsibility |
|---|---|
| `CamCard Copy/Features/Scan/ScanFlowView.swift` | `ScanFlowView`, `ScanRoute` — cover root, NavigationStack, camera→Edit Card routing. |
| `CamCard Copy/Features/Scan/CameraView.swift` | `CameraView` — P02-S01 chrome, alert state, permission/denied/unavailable states, controls. |
| `CamCard Copy/Features/Scan/CameraViewModel.swift` | `CameraViewModel` (`@Observable`, `@MainActor`) — permission, processing flag, capture/album orchestration. |
| `CamCard Copy/Features/Scan/CameraSession.swift` | `CameraSession` (`nonisolated`) — session/photo output lifecycle and torch, serial queue. |
| `CamCard Copy/Features/Scan/CameraPreviewView.swift` | `CameraPreviewView` (`UIViewRepresentable`) — preview layer host. |
| `CamCard Copy/Features/Scan/CameraAuthorization.swift` | `CameraAuthorization`, `CameraPermissionState`, `CameraAuthorizationProviding`, real implementation. |
| `CamCard Copy/Features/Scan/CardDetecting.swift` | `CardDetecting`, `DetectedCard`, `ScannedCardImage`. |
| `CamCard Copy/Features/Scan/VisionCardDetector.swift` | `VisionCardDetector` (`@concurrent`) — Vision detection + Core Image correction. |
| `CamCard Copy/Features/Scan/StubCardDetector.swift` | `StubCardDetector` — correction-failure and other impossible-naturally cases only. |
| `CamCard Copy/Features/Scan/ScanFixtureFactory.swift` | `ScanFixtureFactory` — generated synthetic card, plain and photo-grid images. |
| `CamCard Copy/Features/Album/PhotoLibraryProviding.swift` | `PhotoLibraryProviding`, `PhotoAccessState`, `PhotoAsset`, `PhotoAlbum`, real `PhotoKitLibrary`, `FakePhotoLibrary`. |
| `CamCard Copy/Features/Album/AlbumPickerView.swift` | `AlbumPickerView` — banner, grid, album list, Cancel/Done, denied view. |
| `CamCard Copy/Features/Album/AlbumPickerViewModel.swift` | `AlbumPickerViewModel` (`@Observable`, `@MainActor`) — authorization, selection, thumbnails. |
| `CamCard Copy/Features/EditCard/EditCardView.swift` | `EditCardView` — P05-S01 shell with disabled Save and Retake. |
| `CamCard CopyTests/CardDetectionTests.swift` | T06-U1/U2 against generated fixtures and the real detector. |
| `CamCard CopyTests/CameraPermissionTests.swift` | T03 camera permission-state mapping with a fake provider. |
| `CamCard CopyTests/PhotoLibraryTests.swift` | T05 full/limited/denied/not-determined mapping and fixture-photo selection. |
| `CamCard CopyTests/ScanHandoffTests.swift` | T06 image separation, processing-disable state and no persistence. |
| `CamCard CopyTests/LaunchConfigurationTests.swift` | Hook argument parsing. |
| `CamCard CopyUITests/T02CameraUITests.swift` | T02 chrome, inert •••, inert mode labels, Close. |
| `CamCard CopyUITests/T03T20CameraDeniedUITests.swift` | T03/T20 camera denied state. |
| `CamCard CopyUITests/T05AlbumUITests.swift` | T05 Recents grid, back chevron to album list, album grid, limited banner, selection, Done, Cancel and photo denied. |
| `CamCard CopyUITests/T05T06CaptureUITests.swift` | T05/T06 album and shutter fixture paths, alert, Continue/Cancel, Edit Card shell. |

**Existing interfaces that stay unchanged**

- `CardRepository`, `SwiftDataCardRepository`, `InMemoryCardRepository`, `CardRepositoryError`.
- `BusinessCard`, `Note`, `CardGroup`, `CardRecord`, `NoteRecord`, `GroupRecord` and the SwiftData schema/store.
- `CardHolderView`, `CardHolderViewModel`, `CardDetailView`, `MainTabBar`, `AppTab`, `PlaceholderView`.
- `MyApp`, `ModelContainerFactory`, `StoreBootstrap`, `SeedData`.
- `T01EmptyCardHolderUITests` (its scan open/close path keeps working), `CamCard_CopyUITests`, `CamCard_CopyTests`, assets, `reference/`.
- `openspec/specs/card-storage`: no delta and no behavior change.
- `openspec/specs/app-shell`: changed only by the delta in this change.

## Risks / Trade-offs

- **Missing usage descriptions terminate the app on first camera or photo access** → D7 adds both generated-plist keys to Debug and Release; verified by a build and the manual checks.
- **Simulator has no camera** → `.noCamera` shows an explanation placeholder; UI tests use injected fixtures; live preview, torch and real capture are manual real-device checks only.
- **UI tests now run the real Vision detector on generated images** → Fixtures are high-contrast and generated in code, but Vision detections can still vary; a real-card manual check remains, and `StubCardDetector` is reserved for correction-failure cases.
- **PhotoKit permission states are not captured** → P03-S03 through P03-S06 are implemented as ASSUMPTION and covered through the fake provider; system prompts and the real library are not used in tests.
- **Keeping "Camcard" verbatim in our banner** → This matches P03-S01 exactly but shows another product's name. The decision is **decided** for this change: `config.yaml` requires quoting exact observed UI text, so the observed name is kept verbatim. The string is isolated for an easy change.
- **Inert controls look functional** (•••, Batch/Multiple/QR, High Accuracy, crop glyph) → Plain labels/buttons with no actions, explicit TODO comments in code, and T02 asserts taps do not change mode or open a menu.
- **Counter omitted leaves the bottom-right slot empty** → It is omitted because its meaning is unconfirmed; P02-S06 covers the ••• menu, not the counter. The counter is listed as out of scope.
- **Alert state hides Close (X)** → The user can only Continue or Cancel, matching P04-S01; the alert must remain dismissible through its two buttons.
- **Detection could hang with both entry points disabled** → `VisionCardDetector` returns or throws; thrown failures route to the P04-S01 alert. No new timeout is added.
- **Photo thumbnails and full images can be large** → Thumbnails load through PhotoKit off the main actor; only one full image is held as `ScannedCardImage` in memory, and it is released when the cover closes.
- **`@concurrent` in the current Swift mode** → The protocol is `nonisolated` and the implementation is `@concurrent`, matching `SWIFT_APPROACHABLE_CONCURRENCY`; if the compiler rejects the attribute, the same nonisolated async method can be moved onto a detached task without changing the seam.

## Migration Plan

None. No SwiftData schema, store or repository change and nothing is persisted. Reverting this change restores `ScanPlaceholderView` and removes the capture/album sources; the two usage-description build settings are harmless if left in place.

## Open Questions

- P03-S03 through P03-S06 copy, denied-screen layout, full-access grid and selected-photo styling are not captured. The current implementation is ASSUMPTION and can be corrected when screenshots exist.
- P02-S06's ••• menu content and the "5" counter meaning are not captured. The ••• glyph is inert and the counter is omitted.
- P02-S03/P02-S04 prompt and denied copy, P04-S04's "Cancel saving" destination, and P05-S08's Retake confirmation are not captured. The current assumptions (system prompt, explanation plus Settings, return to camera, no confirmation) can be corrected without changing this design.
- The torch button's on-state label is unobserved; the current assumption keeps "Tap to light up" unchanged.
