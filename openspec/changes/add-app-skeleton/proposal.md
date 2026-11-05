# Proposal

## Why

The app is still the Xcode "Hello, world!" template. The capture and recognition work that follows needs two things first: a tab shell that matches CamCard's navigation, and a durable place to put saved cards. Building the skeleton now fixes the domain vocabulary (CardHolder, card fields, notes), the repository seam, and the UI-test hooks before any camera or OCR code depends on them.

## What Changes

- Replace the template screen with a five-slot tab shell: Home, CardHolder, center scan button, Tools, Settings. Home, Tools and Settings are placeholders; the scan button opens a placeholder screen.
- Build the CardHolder screen:
  - Empty state matching P01-S01 (`"CardHolder"`, `"Cards"`, `"No cards"`, helper text, search field shown as a disabled placeholder) plus the ⊕ control at the top right. The ⊕ is inert in this change; P01-S08 is not captured, so it is TODO(P01-S08).
  - Card list state when the store has cards (P01-S02, not yet captured — ASSUMPTION; T12 foundation only).
  - Tapping a row opens a read-only card detail screen (P09-S01, not yet captured — ASSUMPTION; T13 foundation only).
- Add `BusinessCard`, `Note` and `CardGroup` SwiftData models. `BusinessCard` has `originalImage` and `processedImage` (external storage), `rawOCRText`, `name`, `company`, `jobTitle`, `mobile`, `phone`, `email`, `website`, `address`, `groups` (many-to-many `CardGroup`), `notes` (timestamped `Note` entries that cascade-delete with the card), `createdAt`, plus a stable `id`. `CardGroup` has a stable `id` and a unique name. Every store contains "Ungrouped" (P07-S01), ensured on every launch.
- Add a `CardRepository` protocol with two implementations: SwiftData-backed (persistent) and in-memory (tests and previews). CRUD is create, fetch all, fetch one, update, delete; group access is fetch all groups and ensure a named group. The in-memory and on-disk stores return the same `CardRecord`/`NoteRecord`/`GroupRecord` values.
- Add launch-argument test hooks: `-uiTestEmptyStore` deletes the store, its sidecar files and its external-storage folder (`.CamCard_SUPPORT`); `-uiTestSeedCards` inserts deterministic mock cards and groups (VIP, Customer, Supplier, Partner, Industry Peer from P07-S01's suggestions) when the store is empty.
- Add tests: T01 (first launch shows empty CardHolder) as XCUITest; T12 and T13 foundation-only XCUITest assertions for the list and detail; T16 foundation unit coverage for "Ungrouped"; T18 foundation (data survives relaunch) as XCUITest; and repository unit tests T18-U1 through T18-U5 in XCTest.

### State IDs covered

| State ID | Coverage |
|---|---|
| P00-S01 | Tab bar (Home, CardHolder, center scan, Tools, Settings) and scan button only. Home is a minimal placeholder; the search bar, bell, crown and stats icons are intentionally not built. The Home search bar is deferred to T15 (P00-S03). |
| P01-S01 | Empty CardHolder: title, search placeholder, "Cards" section, "No cards", helper text, and the ⊕ control at the top right. CamCard's illustration is replaced by an SF Symbol placeholder. |
| P01-S02 | CardHolder with cards. Not captured in `reference/` — layout and row content are ASSUMPTION. T12 foundation only. |
| P09-S01 | Read-only card detail. Not captured in `reference/` — layout and displayed fields are ASSUMPTION. T13 foundation only. |
| P01-S08 | Not built. The ⊕ from P01-S01 is visible but inert; TODO(P01-S08) until the tap state is captured. |
| P07-S01 | Partial: the group names (VIP, Customer, Supplier, Partner, Industry Peer) and the "Ungrouped" default feed the store and seed data. The group picker and group management UI are out of scope (T16). |

### Test IDs covered

| Test ID | Coverage |
|---|---|
| T01 | First launch, empty store: CardHolder empty state, inert search, inert ⊕, and store-reset checks. XCUITest plus a reset unit test. |
| T12 | Foundation only: seeded cards render in the CardHolder list. The capture-to-save path that T12 really covers is not built. XCUITest. |
| T13 | Foundation only: tapping a card opens the read-only detail. Phone, email, website and image actions that T13 covers are not built. XCUITest. |
| T16 | Foundation only: "Ungrouped" exists once on every launch. Group picker and group management are not built. XCTest. |
| T18 | Foundation only: seeded cards survive termination and relaunch. XCUITest. |
| T18-U1 … T18-U5 | Repository unit tests in XCTest: create/fetch and nil round-trip (U1), notes and unknown id (U2), update (U3), delete plus note cascade (U4), groups and survival after card delete (U5). These are this change's own labels; the assignment defines no unit-level IDs. |
| T15 | Not covered. Needs the deferred Home search bar (P00-S03) and the search states P01-S04 to P01-S06. |

## Capabilities

### New Capabilities

- `app-shell`: tab shell and navigation, Home/Tools/Settings placeholder pages, the center scan placeholder, CardHolder empty and populated states including the inert ⊕ placeholder, and the read-only card detail screen.
- `card-storage`: the `BusinessCard`/`Note`/`CardGroup` model, the `CardRepository` contract, its SwiftData and in-memory implementations, group storage and the default "Ungrouped" group, notes cascade deletion, external image storage, persistence across launch, and launch-time store reset/seeding hooks.

### Modified Capabilities

None. `openspec/specs/` is empty; this is the first change.

## Out of scope

- Camera capture, rectangle detection, photo import, OCR, field parsing and the Edit Card screen.
- Search: the Home search bar and T15 (P00-S03), plus P01-S04 to P01-S06. The P00-S01 search entry is deferred, not built.
- Group filtering (P01-S07), group management (P01-S09, P01-S10, P07-S02, P07-S03), and user creation or renaming of groups (T16). Only the stored group records and the default "Ungrouped" group are in scope.
- The ⊕ menu (P01-S08): the control is built but inert until the state is captured.
- Notes UI, card editing, delete and multi-select.
- Export, Save to Contacts, premium/paywall, login, sync, messages, AI assistant.
- Every P10+ screen and any tab content beyond a placeholder.
- CamCard's illustrations, icons and logos; SF Symbols or plain placeholders are used instead.

## Impact

- **App code**: `CamCard Copy/MyApp.swift` is rewritten; `CamCard Copy/ContentView.swift` is removed. New sources under `CamCard Copy/Models`, `CamCard Copy/Persistence`, `CamCard Copy/Support`, `CamCard Copy/Features`.
- **Tests**: new XCTest files in `CamCard CopyTests`; new XCUITest files in `CamCard CopyUITests`. The existing `CamCard_CopyTests.swift` and `CamCard_CopyUITests.swift` templates are left unchanged.
- **Project file**: no manual edits expected; both targets use file-system-synchronized groups, so added files compile automatically.
- **Dependencies**: none added. SwiftUI, SwiftData and XCTest only.
- **Persistence**: a new on-disk SwiftData store at `Application Support/CamCard.store`. UI tests may delete it only when `-uiTestEmptyStore` is passed; the reset also removes the store sidecars and the `.CamCard_SUPPORT` external-storage folder beside it.
