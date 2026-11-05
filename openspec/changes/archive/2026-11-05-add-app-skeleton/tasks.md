# Tasks

## 1. Data foundation

- [x] 1.1 Add `BusinessCard`, `Note` and `CardGroup` SwiftData models plus `CardRecord`, `NoteRecord` and `GroupRecord` value types. Use `@Attribute(.externalStorage)` for both images, a many-to-many `.nullify` groups relationship, and a `.cascade` notes relationship. Verify with `xcodebuild build -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17"`: the build succeeds and the relationships compile.
- [x] 1.2 Add `CardRepository` (CRUD, `fetchAllGroups`, `ensureGroup(named:)`), `CardRepositoryError`, `SwiftDataCardRepository` and `InMemoryCardRepository`. Add `CardRepositoryTests` and run the project test command with `-only-testing:"CamCard CopyTests/CardRepositoryTests"`: T18-U1 (create/fetch, nil round-trip), T18-U2 (notes order, unknown id), T18-U3 (update), T18-U4 (delete plus notes cascade), and T18-U5 (group round-trip and groups surviving card deletion) pass for both implementations; the SwiftData case asserts the `Note` count is zero after delete.

## 2. Bootstrap, tab shell and empty CardHolder (T01)

- [x] 2.1 Add `ModelContainerFactory` (explicit `Application Support/CamCard.store` URL and `resetStore(at:)` deleting the store, sidecars and `.CamCard_SUPPORT`), `LaunchConfiguration` (`-uiTestEmptyStore`, `-uiTestSeedCards`, DEBUG-only reset/seeding), `StoreBootstrap` (always ensures "Ungrouped") and `SeedData` (groups VIP, Customer, Supplier, Partner, Industry Peer and three fixed cards, seeded only when there are no cards). Wire `MyApp` to build the container and repository and attach `.modelContainer`. Add foundation tests to `CardRepositoryTests` for "Ungrouped" after repeated bootstrap (T16), seed idempotence with card and group counts (T18), and `resetStore(at:)` clearing a temporary store plus `.CamCard_SUPPORT` (T01), run them with `-only-testing:"CamCard CopyTests/CardRepositoryTests"`, then launch with `-uiTestEmptyStore` and confirm the app reaches the shell without crashing.
- [x] 2.2 Add `AppTab`, `MainTabBar`, `RootView`, `PlaceholderView` and `ScanPlaceholderView`; delete `ContentView.swift` and remove its reference from `MyApp.swift`. Verify by launching with `-uiTestEmptyStore`: Home is selected, all five slots are present, and the scan placeholder opens and closes back to Home.
- [x] 2.3 Add `CardHolderViewModel` and the empty `CardHolderView`: inline title "CardHolder", inert ⊕ toolbar button (`cardholder.add`, empty action, `// TODO(P01-S08)`), non-editable "Search" pill, "Cards" section, SF Symbol artwork, "No cards" and the exact helper text. Verify with `-uiTestEmptyStore` that tapping the search pill opens no keyboard and tapping ⊕ leaves "No cards" and opens nothing.
- [x] 2.4 Add `T01EmptyCardHolderUITests` and run the project test command with `-only-testing:"CamCard CopyUITests/T01EmptyCardHolderUITests"`: T01 passes, asserting Home on launch, the five tab slots, every P01-S01 string, the inert ⊕, and the inert search.

## 3. Card list, read-only detail and persistence (T12, T13, T18)

- [x] 3.1 Add the populated `CardHolderView` state: one row per card in the "Cards" section, name and company, image thumbnail or SF Symbol fallback, `card.row` identifier, and navigation to detail. Verify with `-uiTestEmptyStore -uiTestSeedCards` that three rows replace "No cards" (T12 foundation).
- [x] 3.2 Add the read-only `CardDetailView`: image or placeholder, only non-nil fields with the design D5 labels, group names from `GroupRecord`, notes ordered oldest first, and no edit/save/delete/export/sync controls. Verify by opening "Avery Chen": name, company, email, group "VIP" and the note are shown, no "Website" label appears, and no action controls are present (T13 foundation).
- [x] 3.3 Add `T18PersistenceUITests` and run the project test command with `-only-testing:"CamCard CopyUITests/T18PersistenceUITests"`: T12/T13 foundation assertions pass, then T18 passes with three seeded rows, unchanged rows and the VIP group on a second seeded launch, unchanged rows after a third launch with no arguments, and the persisted detail values. Group-count idempotence is covered by the task 2.1 unit test.

## 4. Full verification

- [x] 4.1 Run `xcodebuild test -project "CamCard Copy.xcodeproj" -scheme "CamCard Copy" -destination "platform=iOS Simulator,name=iPhone 17"` and report the output: T01, T12/T13 foundation assertions, the T16, seed-idempotence and T01 reset unit tests, T18, T18-U1 through T18-U5, and the existing template tests must pass, with the xcodebuild output shown rather than summarized.
