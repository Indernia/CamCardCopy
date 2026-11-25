# Design

## Context

See proposal.md for motivation and `specs/card-recognition/spec.md` for required behavior.

`add-card-capture` (archived) delivers a `ScannedCardImage` (original + optional corrected JPEG) to `EditCardView` through `ScanHandoff`, with detection behind the `nonisolated` `CardDetecting` protocol and a `VisionCardDetector` marked `@concurrent`. `EditCardView` is today a shell: Retake leading, disabled Save trailing, card image, one empty "Full Name" row. `LaunchConfiguration` already parses DEBUG hooks. The app target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and `SWIFT_APPROACHABLE_CONCURRENCY = YES`; both targets use file-system-synchronized groups, so new files compile without project edits.

`reference/dataset/` holds 5 scanned PNGs and 5 photographed JPEGs; `reference/ground-truth.json` has expected fields per card, with `null` for fields that must stay empty (T09) and multi-value cards for T10. P04-S02, P04-S03, P05-S02, P05-S03 and P05-S05 are not captured, so their presentation is ASSUMPTION.

The user runs tests in Terminal.app with `build-for-testing` / `test-without-building`, logging to `build/test-output.log`; results are read from that log instead of pasted output.

## Goals / Non-Goals

**Goals:**

- A recognition pipeline behind a protocol, mirroring `CardDetecting`: Vision `VNRecognizeTextRequest` (accurate, English), off the main actor.
- A separate, deterministic parser from raw text to the eight fields, never mutating the raw text and never fabricating values.
- Edit Card populated from the recognized fields, each row editable, "Full Name" first, Save disabled.
- The P04-S02 progress and P04-S03 failure states as specified (both ASSUMPTION).
- Dataset-driven accuracy tests (T07–T10) with a per-field match report, plus a DEBUG hook for UI tests.

**Non-Goals:**

- Everything the proposal lists as out of scope (Save, Edit More Info, languages picker, crop, Retake confirmation, Add Backside).
- Persisting recognized fields to SwiftData — that belongs to the save change.
- Extending `BusinessCard` for `extraPhones`/`extraEmails` — they exist only in memory here; the save change decides whether to extend the model or drop them.
- Parsing beyond the observed English layouts; no ML model beyond Vision.
- Changing the capture or album flows.

## Decisions

### D1 — Recognition behind `TextRecognizing`, mirroring `CardDetecting`

```swift
nonisolated struct RecognizedCard: Equatable, Sendable {
    let rawText: String
    let fields: CardFields
}

nonisolated struct CardFields: Equatable, Sendable {
    var name: String?
    var company: String?
    var jobTitle: String?
    var mobile: String?
    var phone: String?
    var email: String?
    var website: String?
    var address: String?
    var extraPhones: [String]
    var extraEmails: [String]
}

nonisolated protocol TextRecognizing: Sendable {
    func recognizeText(in imageData: Data) async throws -> String
}
```

- `VisionTextRecognizer` is the real `@concurrent` implementation: `VNRecognizeTextRequest` with `recognitionLevel = .accurate`, `recognitionLanguages = ["en-US"]`, `usesLanguageCorrection = false`, run at the image's native resolution. Language correction is off because it rewrites unusual proper names, email local parts and URLs toward dictionary words; recognition accuracy, not speed, is the constraint and the image is already JPEG-sized by the capture pipeline.
- The recognizer returns raw text only. Parsing is D2, so the recognizer stays swappable and the parser stays unit-testable without Vision.
- `RecognizedCard.rawText` is never mutated (project hard rule); `CardFields` is derived data.

### D2 — Parsing as a pure, deterministic component

`CardFieldParser` is a stateless `nonisolated` type: `parse(_ rawText: String) -> CardFields`. No Vision, no I/O. Heuristics, in priority order:

1. **Labelled lines win** ("Mobile", "Tel", "Phone", "Email", "E-mail", "Website", "Web", "Fax", "Address"). Labels map directly to fields; "Fax" maps to nothing (T10).
2. **Pattern matches**: emails and URLs by regular expression; phone-like lines by digit density, then assigned to mobile/phone by label or by order when unlabelled (ASSUMPTION — ground truth shows unlabelled single numbers land in `phone`, a "Mobile"-labelled one in `mobile`).
3. **Position heuristics** for name/jobTitle/company, using observed layouts: the name is the most prominent early line, job title typically follows the name, the company follows the title (ASSUMPTION, tuned against the dataset).
4. **Address** from lines with street/locality patterns ("Street", "Road", "Avenue", "Suite", city + postcode).
5. **No fabrication**: a field with no evidence stays `nil`. Email domains are never reused for `website` or `company` (T09). Multiple phones/emails go to `extraPhones`/`extraEmails`, first match stays primary (T10).
6. **No dataset-specific rules**: the parser must not contain names, companies, domains or other literal values from `reference/`; only generic conventions (labels, patterns, positions) live in code, so raw-text samples outside the dataset exercise the same rules.

A rule-based parser was chosen over an ML/NER model because the dataset is small, the layouts are conventional, and determinism makes T07–T10 reproducible. `VNRecognizeTextRequest` alone was rejected for field mapping because it returns lines, not semantics.

### D3 — Recognition runs inside `ScanHandoff`, before navigation

`ScanHandoff` gains a `TextRecognizing` and a parser alongside the detector. After detection (or the alert's "Continue saving" with the original image), it runs recognition on `processedImage ?? originalImage`, then returns a `ScannedCardImage` extended with `recognized: RecognizedCard?` (`nil` when recognition fails or yields no text — the P04-S03 fallback). Camera/Album call sites are unchanged; only the handoff grows a stage.

Running recognition before pushing Edit Card keeps Edit Card itself synchronous and matches the observed capture → progress → Edit Card flow. Recognizing lazily inside EditCardView was rejected: it would put an async stage and a second progress state inside the destination screen, diverging from P04-S02's placement between capture and Edit Card.

### D4 — Progress and failure states live on the camera screen (ASSUMPTION)

`CameraViewModel` gains a `recognitionPhase` (`.idle`, `.recognizing`). While `.recognizing`, the card frame shows the existing disabled-shutter state plus a spinner with the text "Recognizing…" (ASSUMPTION — P04-S02 not captured; T07). The shutter and Album stay disabled exactly as during detection. On failure or empty text, the flow navigates to Edit Card with all fields empty and no error alert (ASSUMPTION — P04-S03 not captured). The no-alert landing is justified by P05-S01: after "Continue saving" with nothing recognized, CamCard was observed on an empty Edit Card with no alert, so the failure path matches that observed state. P04-S03 itself stays ASSUMPTION because the failure-specific state was not captured.

### D5 — Edit Card becomes a form of editable rows

`EditCardView` keeps its chrome (Retake leading, "Edit Card" title, disabled Save trailing, card image, "Full Name" first row — P05-S01) and renders one `TextField` row per field in P05-S02 order (ASSUMPTION beyond "Full Name"): Company, Job Title, Mobile, Phone, Email, Website, Address. Rows bind to local `@State` seeded from `recognized.fields`; empty rows show the label with an empty value (no invented placeholder). Editing mutates only local state — nothing is saved (T11). `extraPhones`/`extraEmails` render as additional rows after their primary (P05-S05, ASSUMPTION). `BusinessCard` has a single `phone` and a single `email`, so the extras exist only in the in-memory `CardFields`; this change does not touch the model. The save change decides whether to extend `BusinessCard` or drop the extras.

A `Form` of `TextField`s was chosen over the current static `LabeledContent` rows because P05-S03 requires in-place editing; a navigation-per-field editor (like the real app) is out of scope until P05-S03 is captured.

### D6 — Dataset fixtures drive accuracy tests without inviting overfitting

Comparison normalizes both parsed values and ground truth: trim leading and trailing whitespace, collapse internal whitespace runs to a single space, and compare `email` and `website` case-insensitively; every other field compares case-sensitively after normalization.

- Unit tests read `reference/dataset/*` and `reference/ground-truth.json` via a `#filePath`-relative helper in the test target (no bundle copying, no network). The accuracy test decodes ground truth once, runs the real recognizer + parser per image, and emits a per-field match/mismatch report in the test log.
- Scanned PNGs: assert that every non-null ground-truth field matches after normalization and that every `null` ground-truth field stays `nil` (T07–T10).
- Photographed JPEGs: assert only `name`, `email` and the primary phone (`mobile` when present, otherwise `phone`) after normalization. The remaining fields stay in the report but are not asserted, because photographed-card OCR is weaker and asserting them would push the parser toward dataset-specific rules.
- `CardParsingTests` uses hand-written raw-text samples that are not taken from the dataset, so the parser's conventions must generalize beyond the fixtures.
- `CardFieldParser` contains no dataset names, companies, domains or other literal values from `reference/`.
- The DEBUG hook is `-uiTestRecognizeDatasetImage <absolute-path>`: `LaunchConfiguration` parses it, and `CameraView`'s shutter path feeds that file's data through the real detector + recognizer (the same `ScanHandoff` stages as production). UI tests read `ground-truth.json` themselves to derive expected field values. The hook is test-only and compiled under `#if DEBUG`.

Passing a path (instead of bundling images) keeps the app target free of test assets and lets the same hook serve any future dataset entry.

### D7 — Files touched

New:

- `CamCard Copy/Features/Recognition/TextRecognizing.swift` — protocol + `RecognizedCard`/`CardFields`
- `CamCard Copy/Features/Recognition/VisionTextRecognizer.swift`
- `CamCard Copy/Features/Recognition/CardFieldParser.swift`
- `CamCard CopyTests/CardParsingTests.swift` — T07–T10 on hand-written raw text that is not from the dataset
- `CamCard CopyTests/CardRecognitionTests.swift` — end-to-end dataset accuracy + report
- `CamCard CopyTests/DatasetFixtures.swift` — shared `#filePath`-relative loader
- `CamCard CopyUITests/T07RecognitionUITests.swift` — progress state, populated Edit Card, T11 editing

Modified:

- `CamCard Copy/Features/Scan/CardDetecting.swift` — `ScannedCardImage` gains `recognized`
- `CamCard Copy/Features/Scan/ScanHandoff.swift` — recognition stage (D3)
- `CamCard Copy/Features/Scan/CameraViewModel.swift` — `recognitionPhase` (D4)
- `CamCard Copy/Features/Scan/CameraView.swift` — progress overlay (D4)
- `CamCard Copy/Features/Scan/ScanFlowView.swift` — report camera authorization for the DEBUG hook so the shutter is usable on the simulator (D6)
- `CamCard Copy/Features/EditCard/EditCardView.swift` — editable populated rows (D5)
- `CamCard Copy/Support/LaunchConfiguration.swift` — `-uiTestRecognizeDatasetImage` hook (D6)
- `CamCard CopyTests/ScanHandoffTests.swift`, `CamCard CopyTests/CameraPermissionTests.swift` if needed, `CamCard CopyTests/LaunchConfigurationTests.swift` — updated and new tests for D3, D4 and D6

Nothing else. Unrelated files stay untouched (project rule).

## Risks / Trade-offs

- [Parser heuristics overfit the 10-image dataset] → Scanned PNGs assert every field, photographed JPEGs assert only name, email and the primary phone; `CardParsingTests` uses raw text outside the dataset and the parser has no dataset-specific strings; the no-fabrication rule limits damage from unknown layouts and position rules stay ASSUMPTION.
- [Vision accuracy on photographed cards is worse than scans] → The dataset includes both; the accuracy report makes any gap visible per field instead of hiding it in a pass/fail.
- [`reference/` paths break if the repo moves] → The test helper resolves from `#filePath`; the DEBUG hook takes an absolute path, so only the test launch code knows the location.
- [Recognition latency on device makes the wait feel long] → It already runs off-main; the P04-S02 progress state covers the perceived wait (as the capture change's spinner did for detection).
- [Editable rows drift from P05-S02's real layout] → The layout is marked ASSUMPTION everywhere it is unobserved; only "Full Name" order is binding.
