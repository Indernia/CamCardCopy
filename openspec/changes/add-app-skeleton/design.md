# Design

## Context

See proposal.md for motivation and `specs/` for required behavior. The app is the Xcode SwiftUI template: `MyApp.swift` shows `ContentView` ("Hello, world!"). There is no model, persistence, navigation or feature code yet. The targets use Xcode file-system-synchronized groups, so new files under `CamCard Copy/` are compiled without editing `project.pbxproj`. `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, iOS 27, Swift 5 language mode. `reference/dataset/` and `ground-truth.json` are empty, so seeded UI-test fixtures are defined in code.

## Goals / Non-Goals

**Goals:**

- A five-slot tab shell matching P00-S01's structure, with Home/Tools/Settings as placeholders and a scan entry that presents a placeholder.
- P01-S01's exact empty-state text including the inert ⊕ placeholder, a populated CardHolder list (P01-S02, T12 foundation, ASSUMPTION) and a read-only detail (P09-S01, T13 foundation, ASSUMPTION).
- One persistence boundary (`CardRepository`) with a SwiftData implementation and a pure in-memory implementation, including `CardGroup` records, notes cascade deletion and external image storage.
- Deterministic UI-test launch hooks and automated T01, T12/T13 foundation, T16 foundation, T18 and repository unit tests T18-U1 through T18-U5.

**Non-Goals:**

- Camera, detection, OCR, parsing, Edit Card, saving from capture, search (including the Home search bar and T15), group filtering, notes UI, editing, delete, export, paywall or any P10+ screen.
- Group picker or group creation/renaming UI (T16); only the stored `CardGroup` records and the default "Ungrouped" group are built.
- The ⊕ menu (P01-S08); the button is rendered but inert.
- A reusable design system, localization, dark-mode polish or list sort/search controls.
- Migrating or preserving data from earlier versions; there is no earlier version.

## Decisions

### D1 — Custom tab bar instead of `TabView`

`RootView` owns `@State selectedTab: AppTab` and `@State isScanPresented: Bool`. `MainTabBar` draws five slots: Home, CardHolder, center scan button, Tools, Settings. Tabs render `PlaceholderView(title: "Home")`, `CardHolderView`, `PlaceholderView(title: "Tools")` and `PlaceholderView(title: "Settings")`. The scan button presents `ScanPlaceholderView` in a `.fullScreenCover`; its Close button dismisses it and the previously selected tab remains visible.

Native `TabView` was rejected: adding a fifth tab for the scan action makes the scan button look selected and changes the selected tab when tapped. The requirement says it is a button, not a tab.

Icons are SF Symbols only (house, card stack, camera, folder, gearshape); the purple circular scan treatment is a styling choice, not copied artwork.

Identifiers: `tab.home`, `tab.cardHolder`, `tab.scan`, `tab.tools`, `tab.settings`, `scan.close`.

### D2 — Repository returns value-type records, not `@Model` objects

- `BusinessCard`, `Note` and `CardGroup` are SwiftData `@Model` classes and exist only inside the persistence layer.
- `CardRecord`, `NoteRecord` and `GroupRecord` are `Identifiable, Equatable, Sendable` structs. The repository maps model objects to records and never leaks a `ModelContext` to views.
- `BusinessCard.groups` is a many-to-many `[CardGroup]` relationship with `.nullify`, so deleting a card unlinks its groups without deleting them. `BusinessCard.notes` uses `.cascade`, so notes die with their card. `CardGroup` has a unique `id` and unique `name`.
- `CardRecord.groups` carries `[GroupRecord]` (id + name), not bare strings; `CardRecord.notes` carries `[NoteRecord]`.
- `originalImage` and `processedImage` are `Data?` annotated `@Attribute(.externalStorage)`.
- Rationale: the in-memory repository can own plain values with no SwiftData container, unit tests need no context, and views do not import SwiftData. Returning `@Model` objects was rejected because the in-memory implementation would either need an in-memory `ModelContainer` (not a separate implementation) or expose uninserted relationship graphs, which SwiftData does not guarantee to support.

### D3 — One contract, two implementations

`CardRepository` is a `@MainActor` protocol with `fetchAll()`, `fetch(id:)`, `create(_:)`, `update(_:)`, `delete(id:)`, `fetchAllGroups()` and `ensureGroup(named:)`, all `throws`. `SwiftDataCardRepository` wraps a `ModelContext`. `InMemoryCardRepository` stores cards and groups by id and applies the same ordering rules, so unit tests run every scenario against both.

- `fetchAll()` returns newest `createdAt` first; this is an ASSUMPTION, since P01-S03 (sort order) is not captured.
- `fetchAllGroups()` returns groups by name ascending; `ensureGroup(named:)` returns the existing group with that name or creates one, making it idempotent. This exists for the default "Ungrouped" group and seed data, not for user-facing group creation (T16 stays out of scope).
- `fetch(id:)` returns nil for an unknown id.
- `create(_:)` and `update(_:)` resolve `GroupRecord` ids to stored groups; an unknown group id throws `CardRepositoryError.groupNotFound`.
- `update(_:)` replaces scalar fields and notes; old note records for that card are deleted, then re-created from the record.
- `delete(id:)` removes the card; the `.cascade` relationship removes its notes, and `.nullify` keeps its groups.
- Repository errors use a small `CardRepositoryError` enum (`cardNotFound`, `duplicateIdentifier`, `groupNotFound`) and are propagated, not swallowed.
- Views read through a `CardHolderViewModel` (`@Observable`, `@MainActor`) that calls `fetchAll()`; detail receives its `CardRecord` from the list, including group names and notes.

### D4 — Explicit store URL, launch-time test configuration and default group

`ModelContainerFactory` creates a container from `Schema([BusinessCard.self, Note.self, CardGroup.self])` with an explicit configuration at `Application Support/CamCard.store`. Using a known URL makes reset deterministic.

`LaunchConfiguration` reads `ProcessInfo.processInfo.arguments`:

- `-uiTestEmptyStore` → delete `CamCard.store`, `CamCard.store-shm`, `CamCard.store-wal` and the `.CamCard_SUPPORT` directory before opening the container.
- `-uiTestSeedCards` → after the container opens and the default group is ensured, insert three fixed mock cards and their groups when there are no cards.
- No argument → open the existing store unchanged.
- Reset and seeding are compiled under `#if DEBUG` so a release build cannot delete data through a stray argument. The default "Ungrouped" group is ensured in every build.

**External-storage folder (verified):** SwiftData stores external binary data in a hidden sibling support directory. For a store named `CamCard.store`, that is `.CamCard_SUPPORT/` containing `_EXTERNAL_DATA/`. This was confirmed with a Core Data SQLite probe using the exact store name `CamCard.store` (the store layer SwiftData uses), which produced `.CamCard_SUPPORT/_EXTERNAL_DATA/<uuid>`; SwiftData's own `default.store` follows the published `.default_SUPPORT` convention. `resetStore(at:)` deletes both the store sidecars and `.CamCard_SUPPORT`, and an isolated unit test runs the same helper against a temporary directory.

`StoreBootstrap.prepare(repository:seed:)` runs after the container opens: it always calls `ensureGroup(named: "Ungrouped")` (release and DEBUG), then, in DEBUG when `-uiTestSeedCards` is set, calls `SeedData.seedIfEmpty`. This makes "Ungrouped" present on every launch and exactly one even after relaunch.

The alternative, an in-memory store for UI tests, was rejected because T18 must prove on-disk persistence across relaunch; T01 should exercise the same store path.

Seed fixtures (test data only): groups "VIP", "Customer", "Supplier", "Partner" and "Industry Peer" taken from P07-S01's suggestions, plus the default "Ungrouped". Three cards with fixed UUIDs, names "Avery Chen", "Blair Ortiz", "Casey Lund", companies, emails, one group each (Avery → VIP, Blair → Customer, Casey → Partner), and a note on the first card. The first card has no website, so the detail omission path is exercised. Images are nil, so the detail placeholder path is exercised; no card or group is user-created.

### D5 — Screen composition

- **CardHolder**: `NavigationStack` with inline title "CardHolder". A toolbar ⊕ button at the top right uses identifier `cardholder.add` and an empty action with a `// TODO(P01-S08)` comment; it is consciously unfinished and must not be mistaken for working. A non-editable search pill (magnifying glass + `Text("Search")`, accessibility identifier `cardholder.search`) sits under the title; it is a plain view, so tapping cannot open a keyboard. Below it, a plain `List` with section header "Cards". Empty: SF Symbol, "No cards", helper text. Populated: one `Button` row per card, identifier `card.row`, showing an image thumbnail or SF Symbol, name and company. Selecting a row pushes `CardDetailView`.
- **Card detail**: `NavigationStack` destination, root identifier `cardDetail`. Shows the original image when `originalImage` decodes, otherwise an SF Symbol placeholder. It lists only non-nil fields with these ASSUMPTION labels: "Full Name", "Company", "Job Title", "Mobile", "Phone", "Email", "Website", "Address", "Groups", "Notes". Group names come from `GroupRecord.name`. Notes are sorted oldest first and shown as text plus a `createdAt` timestamp. No toolbar actions.
- **Home / Tools / Settings**: `PlaceholderView` with the tab name as text and no CamCard content.
- **Scan**: `ScanPlaceholderView` with a title, a short placeholder message, and a Close button. It links no camera, photo or Vision framework.

### D6 — Tests and accessibility

- `CardRepositoryTests` (XCTest): every case loops over an `InMemoryCardRepository` and a `SwiftDataCardRepository` backed by an in-memory `ModelConfiguration(isStoredInMemoryOnly: true)`; maps to T18-U1…U5. T18-U4 also asserts that the SwiftData context has no `Note` rows left after the card is deleted; the in-memory implementation cannot orphan notes because the record owns them. T18-U5 covers group round-trip and survival after card deletion. Three foundation tests also live here: the default "Ungrouped" group after repeated `StoreBootstrap.prepare` (T16), seed idempotence with card and group counts after two `StoreBootstrap.prepare(seed: true)` calls (T18), and `resetStore(at:)` clearing a temporary store plus `.CamCard_SUPPORT` (T01).
- `T01EmptyCardHolderUITests` launches with `-uiTestEmptyStore`, asserts Home is selected, taps CardHolder, asserts the exact P01-S01 strings, asserts the ⊕ (`cardholder.add`) is present and tapping it leaves "No cards" visible and opens nothing, and asserts no keyboard appears after tapping "Search".
- `T18PersistenceUITests` launches with `-uiTestEmptyStore -uiTestSeedCards`, asserts three rows (T12 foundation), opens "Avery Chen" and asserts the stored name, company, email, group "VIP", note text, the absence of the "Website" label and the absence of edit actions (T13 foundation), terminates, relaunches with the seed argument and asserts the rows and the VIP group are unchanged (T18 idempotence), then relaunches with no arguments and asserts the rows and values persist (T18). Group counts are asserted by the seed-idempotence unit test, since group UI is out of scope.
- `T12` and `T13` are foundation assertions only; their full assignment versions need capture/save and contact actions.
- The existing `CamCard_CopyTests.swift` (Swift Testing sample) and `CamCard_CopyUITests.swift` (launch smoke test) stay unchanged.

### Files and types

**Modified**

| File | Change |
|---|---|
| `CamCard Copy/MyApp.swift` | Build `LaunchConfiguration` and `ModelContainer`, create `SwiftDataCardRepository`, run `StoreBootstrap.prepare` (default group in all builds, DEBUG-only reset/seeding), show `RootView` from `WindowGroup`, attach `.modelContainer`. |
| `CamCard Copy/ContentView.swift` | Deleted (template screen and `#Playground` block removed). |

**Added**

| File | Types |
|---|---|
| `CamCard Copy/Models/BusinessCard.swift` | `BusinessCard` `@Model` (id, external-storage originalImage/processedImage, rawOCRText, name, company, jobTitle, mobile, phone, email, website, address, groups, notes, createdAt), `Note` `@Model` (id, text, createdAt, cascade inverse card relationship) |
| `CamCard Copy/Models/CardGroup.swift` | `CardGroup` `@Model` (unique id, unique name, many-to-many cards relationship) |
| `CamCard Copy/Persistence/CardRecord.swift` | `CardRecord`, `NoteRecord`, `GroupRecord` value types |
| `CamCard Copy/Persistence/CardRepository.swift` | `CardRepository` protocol (CRUD, `fetchAllGroups`, `ensureGroup(named:)`), `CardRepositoryError` |
| `CamCard Copy/Persistence/SwiftDataCardRepository.swift` | SwiftData mapping, group resolution and CRUD |
| `CamCard Copy/Persistence/InMemoryCardRepository.swift` | Array-backed cards and groups with the same contract |
| `CamCard Copy/Persistence/ModelContainerFactory.swift` | Schema/container creation, explicit store URL, `resetStore(at:)` including `.CamCard_SUPPORT` |
| `CamCard Copy/Support/LaunchConfiguration.swift` | Argument parsing for the two test hooks |
| `CamCard Copy/Support/StoreBootstrap.swift` | Ensures "Ungrouped" on every launch, then optional DEBUG seeding |
| `CamCard Copy/Support/SeedData.swift` | Deterministic mock cards and groups (VIP, Customer, Partner) |
| `CamCard Copy/Features/Shell/AppTab.swift` | `AppTab` enum (`home`, `cardHolder`, `tools`, `settings`) |
| `CamCard Copy/Features/Shell/RootView.swift` | Tab selection and scan cover |
| `CamCard Copy/Features/Shell/MainTabBar.swift` | Five-slot bar |
| `CamCard Copy/Features/Shell/PlaceholderView.swift` | Home/Tools/Settings placeholder |
| `CamCard Copy/Features/Scan/ScanPlaceholderView.swift` | Scan placeholder |
| `CamCard Copy/Features/CardHolder/CardHolderView.swift` | Search pill, inert ⊕ toolbar button, empty state, list, `CardRow` |
| `CamCard Copy/Features/CardHolder/CardHolderViewModel.swift` | `@Observable` `@MainActor` list state |
| `CamCard Copy/Features/CardDetail/CardDetailView.swift` | Read-only detail with groups and notes |
| `CamCard CopyTests/CardRepositoryTests.swift` | XCTest tests for both repositories, groups, notes cascade, default group and store reset |
| `CamCard CopyUITests/T01EmptyCardHolderUITests.swift` | T01 |
| `CamCard CopyUITests/T18PersistenceUITests.swift` | T12/T13 foundation assertions and T18 |

**Existing interfaces unchanged:** `CamCard_CopyTests.swift`, `CamCard_CopyUITests.swift`, `Assets.xcassets`, `CamCard Copy.xcodeproj/project.pbxproj`, `reference/` and `openspec/specs/` are not modified. There is no public API outside the app bundle; the repository protocol is the only new seam consumed by later changes.

### Concurrency

Everything runs on `MainActor` (project default). No background work exists in this change; SwiftData access stays on the main context. Later Vision/OCR work will be the first place to mark work nonisolated.

## Risks / Trade-offs

- **Unobserved layouts** (P01-S02, P09-S01): list row layout, detail labels and sort order are invented. → Marked ASSUMPTION in the specs; T12 and T13 are foundation-only assertions; keep layout code small so a screenshot can replace it.
- **Inert ⊕ looks functional**: P01-S01 shows an active-looking button that does nothing. → Flagged as TODO(P01-S08) in the spec, proposal, design, task list and an inline code comment; it is enabled on purpose so it matches the captured state, and T01 asserts tapping opens nothing.
- **Deleting store files on `-uiTestEmptyStore`**: a wrong path or missing sidecar/support folder leaves stale data or images. → Single explicit store URL, delete `.store`, `.store-shm`, `.store-wal` and `.CamCard_SUPPORT`, DEBUG-only, a temp-directory reset unit test, and T01 proves the empty state.
- **External-storage folder naming**: `.CamCard_SUPPORT` is verified for a `CamCard.store` Core Data/SwiftData store, but Apple could change the convention. → The reset also fails safe by deleting the known folder; if a later OS changes it, the reset unit test and T01 will expose stale data.
- **Duplicate row identifiers**: multiple `card.row` identifiers can count unexpectedly if a future view reuses the id. → Count is asserted only on the CardHolder list, where each row is one button.
- **Test-order dependence**: T18 leaves seeded data on disk. → Every other UI test that expects emptiness passes `-uiTestEmptyStore`; the untouched template smoke test asserts only that the app runs.
- **Unique groups and duplicate create**: `@Attribute(.unique)` on `CardGroup.name` may upsert instead of failing. → `ensureGroup(named:)` returns the existing group by name; no UI creates groups in this change.
- **Many-to-many delete semantics**: deleting a card must not delete its groups. → `.nullify` on the card-to-groups relationship, and T18-U5 asserts the groups survive.
- **Images are optional** (`Data?`) until capture exists: seeded cards have none, so thumbnail and detail fall back to SF Symbols. → Captured cards will always set `originalImage`; keep the optional until the capture change lands.

## Migration Plan

None. First data model and first store; no existing data to migrate. Removing the change restores the template code and can delete `CamCard.store` from the simulator/device container. Data created by UI tests lives only in the test simulator and is reset by `-uiTestEmptyStore`.

## Open Questions

- The Home search bar and T15 (P00-S03, plus P01-S04 to P01-S06) are deferred; they must be added in a later change so the P00-S01 search entry is not forgotten.
- P01-S08 (what the ⊕ opens) is not captured. The button stays inert until that screenshot exists and a follow-up change wires it.
- Exact card-detail labels and list sort order will be confirmed when P01-S02 and P09-S01 screenshots are captured; until then the ASSUMPTION values above stand.
- Note timestamp formatting (abbreviated date plus short time) is unobserved; it can be tuned without changing the specs.
- Group ordering from `fetchAllGroups()` (name ascending) and the group detail label text are unobserved; they can be adjusted when the group screens are captured.
