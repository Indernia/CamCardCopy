# Proposal

## Why

`add-card-recognition` pre-fills Edit Card with recognized, editable fields, but "Save" is still disabled and nothing is persisted: the scan flow ends at a verification screen with no result. The core loop CamCard is observed doing — verify the card, save it, see it in CardHolder — does not exist yet (P05-S01 → P06-S01 → P01-S02).

## What Changes

- "Save" on Edit Card becomes enabled and saves the values as currently edited on screen, not the original parse. Every recognized result still passes through Edit Card first (project hard rule).
- One card is persisted through the existing `CardRepository`:
  - `originalImage` and `processedImage` (external storage, as the model already declares)
  - `rawOCRText` unchanged
  - the eight edited fields (`name`, `company`, `jobTitle`, `mobile`, `phone`, `email`, `website`, `address`)
  - `createdAt`
  - the default group "Ungrouped"
- The first Note entry is created on save as observed on P08-S01: "Card Saved <yyyy-MM-dd HH:mm>" and "From: Taking photo". The album-import source string is not captured (ASSUMPTION — a proposed value is recorded in the spec).
- Saving with all fields empty (P05-S09, not captured) is ASSUMPTION. Proposed behavior: allow saving the image-only card and never fabricate a name. This is flagged for the user's decision in design.md.
- The Card Saved screen (P06-S01) is built with its exact observed text: "Card Saved" with "Done", the card thumbnail, Group, Note, Sync, Export and "Take the next".
  - Group and Note are inert placeholders (`TODO(P07-S01)`, `TODO(P08-S01)`); a separate change builds them.
  - Sync and Export are premium: inert, with no paywall (P21 out of scope).
  - The CC AI assistant panel is out of scope.
  - "Take the next" returns to the camera (P02-S01) for a new capture.
  - "Done" dismisses the scan flow and shows CardHolder with the new card (P01-S02, not captured → ASSUMPTION).
- CardHolder (T12) and card detail (T13) render the real saved card with the existing views, including the image and saved fields.
- Persistence across relaunch (T18) is exercised with a real saved card, not seed data.
- `extraPhones`/`extraEmails` are kept in memory today and would be lost on save. Two options are presented in design.md — extend `BusinessCard` with migration-safe arrays (recommended) or drop them — and the choice is flagged for the user. Data is not silently dropped.

### States covered

- P05-S01 / P05-S02 Edit Card (Save enabled)
- P05-S09 Saving with all fields empty (not captured — ASSUMPTION)
- P06-S01 Card Saved
- P06-S02 Card Saved with a real card (not captured — ASSUMPTION on layout only)
- P08-S01 Note auto entry (content only; the Note screen itself is out of scope)
- P01-S02 CardHolder with one card (not captured — ASSUMPTION), P01-S03 many cards
- P02-S01 camera (return target for "Take the next")
- P09-S01 card detail (not captured — existing view only)

### Test IDs covered

- T11 edit-then-save mapping (edited values win)
- T12 CardHolder list shows the saved card
- T13 card detail shows the saved card
- T18 persistence across relaunch with a real card
- T20 edge behavior around saving (empty fields, save failure, inert actions)

## Capabilities

### New Capabilities

- `card-saving`: The save action on Edit Card and the Card Saved screen — what a save persists, the auto-created first Note, the Card Saved actions and their navigation.

### Modified Capabilities

- `card-capture`: "Edit Card hand-off shell" and "Image hand-off without persistence" change: "Save" is enabled, Edit Card persists exactly one card through the repository, and it hands off to Card Saved instead of doing nothing. Retake behavior is unchanged.
- `card-storage`: Only if the `extraPhones`/`extraEmails` option is chosen. The delta adds the optional multi-value contact fields to the stored card record with a migration-safe default. This delta is conditional on the decision flagged in design.md.

## Impact

- **App code**: `Features/EditCard/EditCardView.swift` (enabled Save, save state, error handling); new `Features/CardSaved` view; `Features/Scan/ScanFlowView.swift` (Card Saved route, repository injection, "Take the next", Done); `Features/Scan/CameraView.swift` and `Features/Scan/CardDetecting.swift`/`ScanHandoff` if the scan source (camera vs album) rides along; new save-mapping type; `Models/BusinessCard.swift`, `Persistence/CardRecord.swift`, `Persistence/SwiftDataCardRepository.swift`, `Persistence/InMemoryCardRepository.swift` only for the multi-value option; `Features/Shell/RootView.swift` (Done selects CardHolder).
- **Tests**: new save-mapping unit tests (both repository harnesses); new UI suite for save → Card Saved → Done → CardHolder → detail; T18 relaunch with a real saved card; "Take the next" returns to the camera. `T07RecognitionUITests` currently asserts "Save" is disabled — that assertion encodes the old behavior and must be updated with this change.
- **Reference fixtures**: `reference/dataset/card-01-standard.png` (via the existing `-uiTestRecognizeDatasetImage` hook) and `reference/screenshots/P06-S01_card-saved.png` for text and layout.
- No new dependencies, no network, no paywall, no fake card data.
