# Design

## Context

See proposal.md for motivation and `specs/card-saving/spec.md`, `specs/card-capture/spec.md` and `specs/card-storage/spec.md` for required behavior.

`add-card-recognition` (in progress) delivers a `ScannedCardImage` to `EditCardView` through `ScanHandoff`. `EditCardView` already renders editable rows seeded from `recognized.fields`, with Retake leading, "Edit Card" title and a disabled "Save" trailing. Everything else is in place to persist: `CardRepository` supports create/fetch/update/delete and `ensureGroup(named:)`, `BusinessCard` stores both images as external storage plus `rawOCRText`, eight fields, groups, notes and `createdAt`, and `StoreBootstrap` ensures exactly one "Ungrouped" group on every launch.

The scan flow is a `fullScreenCover` (`RootView` → `ScanFlowView` → `NavigationStack` with `ScanRoute.editCard`). `RootView` owns the selected tab and the repository; `ScanFlowView` currently has no repository and cannot dismiss into CardHolder. `CameraView` knows whether the image came from the shutter or the album picker.

The user runs tests in Terminal.app with `build-for-testing` / `test-without-building`, logging to `build/test-output.log`; results are read from that log.

## Goals / Non-Goals

**Goals:**

- Persist exactly one card from Edit Card's current on-screen values, in both repository implementations.
- Show the P06-S01 Card Saved screen and leave it through "Done" or "Take the next".
- Make CardHolder and card detail show the real saved card, and prove T18 with a real saved card.
- Keep raw OCR text, both images and the auto-created first Note intact.
- Isolate the save mapping from the view so it is unit-testable without UI.

**Non-Goals:**

- Add to group (P07), the Note screen (P08), Retake confirmation (P05-S08), Sync/Export/paywall (P21), Contacts export (T19), Edit More Info, High Accuracy, crop.
- Changing `CardRepository`'s interface, `CardHolderViewModel`, `CardHolderView`, `CardDetailView` or `ModelContainerFactory`'s schema list.
- Rendering the additional phones/emails in card detail (P09-S01 is not captured; they are stored, not displayed).
- Date/locale settings or a user-selectable time zone.

## Decisions

### D1 — A `CardSaver` owns the mapping from edited rows to `CardRecord`

A new `@MainActor struct CardSaver` takes `repository`, the `ScannedCardImage` hand-off and an `EditedCardValues` value:

```swift
nonisolated struct EditedCardValues: Equatable, Sendable {
    var name: String = ""
    var company: String = ""
    var jobTitle: String = ""
    var mobile: String = ""
    var phone: String = ""
    var email: String = ""
    var website: String = ""
    var address: String = ""
    var extraPhones: [String] = []
    var extraEmails: [String] = []
}

@MainActor
struct CardSaver {
    let repository: CardRepository
    func save(
        image: ScannedCardImage,
        values: EditedCardValues,
        savedAt: Date = .now
    ) throws -> CardRecord
}
```

`save` does, in order: `ensureGroup(named: "Ungrouped")`; map the eight values (empty after trimming whitespace/newlines → `nil`, otherwise the exact typed string); carry `originalImage`, `processedImage` (nil when absent) and `recognized?.rawText` unchanged; set `createdAt = savedAt`; build one `NoteRecord` (D5); call `repository.create`; return the stored `CardRecord`.

Why a separate type rather than saving inside `EditCardView`: the mapping is the risky part (edited vs parsed values, nil handling, note text, group assignment) and must be tested against both the in-memory and SwiftData repositories, exactly like `CardRepositoryTests`. Keeping it out of the view also keeps the view's local `@State` the single source of truth for "as currently edited".

Mapping empty input to `nil` (instead of storing `""`) matches the existing `CardRecord` contract and the no-fabrication rule: a card saved with no name has `name == nil`, and CardHolder's existing "Untitled" fallback is only a display label.

### D2 — Repository injection and the Card Saved route

`RootView` passes its `repository` into `ScanFlowView`; `ScanFlowView` builds one `CardSaver` and passes it (or the repository) to `EditCardView`. `ScanRoute` gains:

```swift
case cardSaved(CardRecord)
```

`EditCardView`'s Save button calls `CardSaver.save`, then appends `.cardSaved(record)` to the navigation path. `EditCardView` keeps an `isSaving` guard so a second tap cannot create a second card (spec: exactly one card). Repository errors stay on Edit Card with an error alert (D6).

Alternatives: saving directly in `EditCardView` (untestable without UI) and a global environment object (unnecessary for one dependency).

### D3 — Scan source rides on `ScannedCardImage`

`ScannedCardImage` gains `let source: ScanSource` (`.camera` / `.album`) with a default of `.camera`, so all existing initializers keep compiling. `CameraView` sets `.camera` for the shutter path and `.album` for the album `Done` path, including the "Card area not found" → "Continue saving" path (the pending image keeps its source). `CardSaver` uses it for the Note source line (D5).

Alternative: carry the source in `ScanRoute` / `EditCardView` parameters. Putting it on the hand-off keeps one source of truth and lets `ScanHandoffTests` assert it.

### D4 — Card Saved screen is a new, mostly inert view

New `Features/CardSaved/CardSavedView.swift`, shown as the `.cardSaved` destination inside the existing `ScanFlowView` `NavigationStack`:

- `ToolbarItem(placement: .principal)`: a checkmark SF Symbol plus "Card Saved".
- `ToolbarItem(placement: .topBarTrailing)`: "Done" → `onDone`.
- A white card panel with the saved card's thumbnail (`processedImage ?? originalImage`) and a static chevron (the chevron's destination is not captured; it is not a button).
- An action row: "Group" (`TODO(P07-S01)`), "Note" (`TODO(P08-S01)`), "Sync" and "Export" (premium, `TODO(P21-S01)`), all buttons with empty actions. Sync and Export show a small crown SF Symbol as the premium marker from P06-S01.
- A full-width "Take the next" button → `onTakeNext`.
- No assistant panel, no gradient artwork. Backgrounds use system colors; layout and text follow P06-S01.

All controls get accessibility identifiers (`cardSaved.done`, `cardSaved.group`, `cardSaved.note`, `cardSaved.sync`, `cardSaved.export`, `cardSaved.takeNext`, `cardSaved.thumbnail`).

Thumbnail decoding reuses the ImageIO approach already in `EditCardView`. D9 extracts it to `Support/CardImageThumbnail.swift` instead of duplicating it.

### D5 — Note text and timestamp

`CardSaver` creates exactly one `NoteRecord` with `createdAt = card.createdAt` and text:

```
Card Saved <yyyy-MM-dd HH:mm>
From: Taking photo          // .camera
From: Importing photo       // .album — ASSUMPTION, P03/P08 album source not captured
```

The formatter is a fixed `DateFormatter` (`dateFormat = "yyyy-MM-dd HH:mm"`, `locale = en_US_POSIX`, current time zone), matching the observed P08-S01 entry "Card Saved 2026-11-05 11:23". `CardSaver` exposes a small `noteText(savedAt:source:)` helper so unit tests assert the exact text without duplicating the format. The album string is one constant, easy to change when captured.

Alternative: store only the timestamp in the note text and render "Card Saved" from `createdAt` in the Note screen. That would force the future P08 screen to invent the label; storing the observed text verbatim keeps that screen a pure timeline.

### D6 — Save failure stays on Edit Card (ASSUMPTION)

`CardSaver.save` throws; `EditCardView` catches it, clears `isSaving`, and shows `.alert("Couldn't save card", …)` with an "OK" button. No Card Saved destination is pushed and no partial card is shown. P05 save-failure behavior is not captured, so the copy is ASSUMPTION; the no-fabrication and "failures are reported" rules make staying put preferable to dismissing.

### D7 — Done and Take the next navigation

- "Done": `ScanFlowView` calls an injected `onDone`. `RootView` dismisses the scan cover and sets `selectedTab = .cardHolder`. CardHolder is rebuilt and its existing `.task` reloads from the repository, so the new card appears. ASSUMPTION: P01-S02 is not captured.
- "Take the next": `ScanFlowView` clears its navigation path (`path.removeAll()`), returning to `CameraView`. `CameraView.onAppear` restarts the session; no additional card is saved.

Alternative for "Done": pop the stack and let the user tap the CardHolder tab. That would not satisfy "Done shows CardHolder with the new card".

### D8 — DECIDED (2026-11-25): `extraPhones`/`extraEmails` — Option A

Recognition keeps multiple phones/emails in `CardFields` only. Saving them is not in the current model. Both options, with the recommended one reflected in `specs/card-storage/spec.md`:

**Option A (recommended) — extend the model.**

- `BusinessCard` gains `var extraPhones: [String] = []` and `var extraEmails: [String] = []`; `CardRecord` gains the same with default `[]`; `SwiftDataCardRepository.apply/record(from:)` maps them.
- Migration: SwiftData lightweight migration fills the default `[]` for existing stores; no record is duplicated, the schema list and `ModelContainerFactory` are unchanged. Verified by the repository test that fetches a pre-change card shape.
- Rationale: P05-S05 explicitly shows multiple phones/emails; dropping them silently loses recognized contact data, which conflicts with "Do not silently drop data". The cost is a small model/record/repository change and one more round-trip assertion.
- Trade-off: a SwiftData schema change is the riskiest part of this change; it is covered by a migration scenario and by launching against an existing store.

**Option B — drop them.**

- Keep `extraPhones`/`extraEmails` in memory only and persist just the primary `mobile/phone` and `email`.
- Rationale: smallest diff, no schema migration.
- Consequence: a multi-contact card loses all but the primary values on save; the user must be told this is intentional. If chosen, the `card-storage` delta and the extra-value scenarios are removed before apply.

**Decision: Option A** (confirmed by the user 2026-11-25).

### D9 — DECIDED (2026-11-25): saving with all fields empty — allow

**Recommended behavior (reflected in the specs): allow saving.**

- P05-S01 is the "nothing recognized" state and still shows "Save" in the active blue style, unlike a disabled control; that is the only evidence available.
- P05-S09 ("Saving with all fields empty") is not captured, so the outcome is ASSUMPTION.
- The saved card stores `nil` for every text field and keeps the image. No name is fabricated. CardHolder shows its existing "Untitled" placeholder. This keeps the user's captured image and lets them fix fields later via a future edit change.

**Alternative: block the save (disabled Save or an alert).** Closer to "a card without a name is meaningless", but contradicts the active Save observed on P05-S01 and leaves the user with no way to store the image.

**Decision: allow, never fabricate** (confirmed by the user 2026-11-25).

### D10 — Tests

- `CamCard CopyTests/CardSavingTests.swift` runs every save-mapping case against both the in-memory and a SwiftData in-memory-container repository (same harness pattern as `CardRepositoryTests`): edited values win, raw OCR preserved, both images stored (and `processedImage` nil when absent), "Ungrouped" assigned exactly once, exactly one card, exactly one note with the exact text/timestamp, empty values stay nil, no fabricated name, extras round-trip (Option A), camera vs album source text.
- `ScanHandoffTests` gains a source assertion; `CardRepositoryTests` gains the extra-values round-trip (Option A).
- `T07RecognitionUITests` and `T05T06CaptureUITests.testT05AlbumCardFixtureReachesEditCard` flip their "Save stays disabled" assertions to enabled — the two existing tests whose assertions encode the old behavior (the T05T06 one was found by the full-suite run and approved by the user 2026-11-25).
- New `CamCard CopyUITests/T12SaveCardUITests.swift`, three tests:
  1. dataset hook → Edit Card → change "Full Name" → Save → Card Saved → Done → CardHolder shows the edited value → open detail.
  2. the same save, terminate, relaunch without `-uiTestEmptyStore`, card still present (T18 with a real card).
  3. Save → Card Saved → "Take the next" → camera chrome is visible.

Unit tests are deterministic: fixed `savedAt` and fixed image bytes. UI tests use the existing `-uiTestEmptyStore` on the first launch only.

### D11 — Files touched

New:

- `CamCard Copy/Features/CardSaved/CardSavedView.swift`
- `CamCard Copy/Features/CardSaved/CardSaver.swift` — `CardSaver`, `EditedCardValues`, note text helper
- `CamCard Copy/Support/CardImageThumbnail.swift` — extracted ImageIO thumbnail decoder
- `CamCard CopyTests/CardSavingTests.swift`
- `CamCard CopyUITests/T12SaveCardUITests.swift`

Modified:

- `CamCard Copy/Features/EditCard/EditCardView.swift` — enabled Save, `isSaving`, save call, Card Saved push, failure alert, shared thumbnail helper
- `CamCard Copy/Features/Scan/ScanFlowView.swift` — repository/saver injection, `.cardSaved` route, `onDone`, "Take the next"
- `CamCard Copy/Features/Scan/CardDetecting.swift` — `ScanSource` + `ScannedCardImage.source`
- `CamCard Copy/Features/Scan/CameraView.swift` — pass `.camera` / `.album`
- `CamCard Copy/Features/Shell/RootView.swift` — pass repository, Done selects CardHolder
- `CamCard Copy/Models/BusinessCard.swift` — extra value arrays (Option A only)
- `CamCard Copy/Persistence/CardRecord.swift` — extra value arrays (Option A only)
- `CamCard Copy/Persistence/SwiftDataCardRepository.swift` — extra value mapping (Option A only)
- `CamCard CopyTests/T07RecognitionUITests.swift` — Save-enabled assertion
- `CamCard CopyUITests/T05T06CaptureUITests.swift` — Save-enabled assertion
- `CamCard CopyTests/ScanHandoffTests.swift` — source travels with the hand-off
- `CamCard CopyTests/CardRepositoryTests.swift` — extra values round-trip (Option A only)

Unchanged interfaces and files: `CardRepository` protocol, `InMemoryCardRepository`, `CardHolderView`, `CardHolderViewModel`, `CardDetailView`, `ModelContainerFactory`, `StoreBootstrap`, `SeedData`, `EditCardView`'s row layout and Retake behavior.

## Risks / Trade-offs

- [SwiftData schema change breaks an existing store] → Option A uses non-optional arrays with a default; the repository test and the relaunch UI test launch against a store created before the save; if migration fails the fallback is to keep Option B.
- [Double-tapping Save creates two cards] → `isSaving` blocks re-entry and the unit test asserts one additional card per save.
- [Edited values vs parsed values drift] → `CardSaver` takes only the on-screen `EditedCardValues`; `CardFields` is never read for stored values, and the unit test changes every field.
- [The album source string is wrong] → It is one constant, marked ASSUMPTION in the spec; changing it later touches only `CardSaver`.
- [Card Saved layout uses CamCard artwork] → Only SF Symbols, system colors and the observed text; the AI assistant panel and gradient artwork are deliberately absent.
- [UI tests get slow from image decoding] → The thumbnail uses the existing ImageIO downscaling path, and UI tests wait on accessibility identifiers rather than fixed sleeps.

## Migration Plan

1. Option A model change first (arrays with defaults), then build and run the repository tests against both harnesses.
2. Save mapping and its unit tests, then the Card Saved view and navigation, then UI tests.
3. Rollback if the store cannot migrate: revert the model/record/repository edits (Option B) and drop the card-storage delta; the save flow and Card Saved are unaffected.
4. No data deletion, no reset of existing stores, no schema list change.

## Open Questions

- The chevron beside the Card Saved thumbnail is rendered inert because its destination is not captured; a future change can wire it when P06-S02/P09-S01 exist.
