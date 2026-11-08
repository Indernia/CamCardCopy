# Proposal

## Why

`add-card-capture` lands a card photo on Edit Card, but every field is empty. CamCard's core value is recognizing the card for the user: the captured image is OCR'd on device and Edit Card arrives pre-filled, ready to verify. This change adds that recognition step, matching P04-S02/P04-S03 and P05-S02/P05-S03/P05-S05.

## What Changes

- On-device text recognition with Vision `VNRecognizeTextRequest` (accurate, English) running off the main actor behind a small protocol, as with `CardDetecting`. It runs on `processedImage` when present, otherwise `originalImage`.
- The raw OCR text is preserved unchanged on the hand-off result; field parsing is a separate component (project hard rule).
- A parser maps raw text to `name`, `company`, `jobTitle`, `mobile`, `phone`, `email`, `website`, `address`. It never fabricates a field: absent values stay empty (T09), including not deriving website/company from an email domain.
- Multiple contact values are supported as observed (P05-S05, ASSUMPTION): several phones and emails are kept, fax is not placed in mobile/phone (T10). `BusinessCard` has a single `phone` and a single `email`, so `extraPhones`/`extraEmails` exist only in the in-memory hand-off; the save change decides whether to extend the model or drop them. The model is not changed here.
- The recognition progress state (P04-S02, T07, ASSUMPTION — not captured) and the recognition-failed state (P04-S03, ASSUMPTION — not captured; T20) are shown during/after recognition.
- Edit Card shows the recognized fields (P05-S02, ASSUMPTION — not captured), with "Full Name" first, each editable (P05-S03, ASSUMPTION; T11). Save stays disabled and Retake still returns to the camera — saving belongs to the next change.
- DEBUG launch hook feeds a dataset image through the real recognizer for UI tests, same pattern as the scan stubs.
- Tests: parser unit tests on raw text and end-to-end recognizer tests on every `reference/dataset` image against `reference/ground-truth.json` (T07, T08, T09, T10), with a per-field match report; UI tests via the new hook.

### Out of scope

- Save / Card Saved (P06), Edit More Info (P05-S04), Recognition Languages picker (P05-S07), High Accuracy capture or "Save and Submit for High Accuracy Recognition", manual crop/rotate (P05-S06), Retake confirmation (P05-S08), Add Backside (P05-S10), "Cards autosaved to Contacts", "Improve Recognition".
- Any change to the SwiftData schema, `CardRepository`, or persisted data.
- Non-English recognition.

## Capabilities

### New Capabilities

- `card-recognition`: On-device OCR of a scanned card and parsing of the raw text into editable contact fields shown on Edit Card, including progress and failure states.

### Modified Capabilities

- `card-capture`: "Edit Card hand-off shell" no longer requires an empty "Full Name" row. Edit Card now shows the recognized contact fields with "Full Name" first, Save stays disabled, and Retake still returns to the camera without saving. Nothing is persisted.

## Impact

- **App code**: new `Features/Recognition` sources (recognizer protocol + Vision implementation + parser); `ScanHandoff`/`ScannedCardImage` carry the recognized result; `EditCardView` gains populated, editable rows; `LaunchConfiguration` gains a DEBUG recognition hook. No existing public interface changes shape except the hand-off result.
- **Tests**: new `CardRecognitionTests`/`CardParsingTests` unit suites and recognition UI tests; existing suites must stay green.
- **Reference fixtures**: `reference/dataset/*.png`, `*-photo.jpg` and `reference/ground-truth.json` drive the accuracy tests (T07–T10).
- State IDs: P04-S02, P04-S03, P05-S02, P05-S03, P05-S05. Test IDs: T07, T08, T09, T10, T11, T20.
