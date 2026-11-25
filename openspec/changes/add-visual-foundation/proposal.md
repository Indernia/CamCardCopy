# Proposal

## Why

The goal is now to pixel-match every reference screenshot, with screens that used to be Out built as inert visual copies. The milestone 1 audit found the same gaps on every screen: iOS default type sizes instead of CamCard's smaller fixed scale, no tinted header with a white sheet below it, iOS glass circles around toolbar icons, and a magenta scan button. Fixing these per screen would mean three parallel changes reinventing the same colors and components. Pushed pages also need one shared way to navigate (a plain back chevron and a shared route list), so the parallel changes can add screens without editing each other's files.

## What Changes

- Add one shared set of visual tokens measured from the reference screenshots: colors (header tint `#F3F7F8`, white sheet, navy icon ink `#1C3F64`, primary text `#151314`, secondary text `#989898`, section header `#5F5E5E`, accent blue `#50A6F8`, scan gradient `#534EF6` → `#873EF6`, premium orange `#EF8C44` → `#F4BA47`) and a fixed type scale (page title 24 pt, navigation title 18 pt, section title 18 pt, row 15 pt, secondary 13 pt, tab label 10 pt).
- Add shared building blocks: a tinted header area with a white rounded sheet below, plain toolbar icon buttons with no glass background, a navigation bar style for pushed pages with a plain "‹" back chevron and a centered title, and a barebones placeholder page for destinations that are not built yet (shows its title and carries a `TODO(P##-S##)` marker).
- Restyle the tab bar to match P00-S01: white background, 10 pt labels, selected `#1E1E1E`, unselected `#989898`, filled icons for the selected tab, and a 44 pt round scan button with the violet gradient. Tab labels, identifiers and behavior do not change.
- Add one shared route list for pushed pages (Messages, Biz Tips, Create Card steps, Settings sub-pages, Login, Upgrade Plans). Each route resolves to a destination owned by its feature folder; this change only adds stubs that show the barebones placeholder page. **No control is wired to a route in this change**: every existing inert control stays inert, so T01, T02, T03T20 and T21 pass unchanged.
- Lock the app to light appearance. Dark mode was not captured (ASSUMPTION), and the measured colors are light-only.
- Fix `openspec/config.yaml`: quote the `rules.tasks` item that YAML currently reads as a mapping, and replace the "Out of scope" hard rule with the new scope (Out screens are built as inert visual copies; CamCard artwork still is not copied).

State IDs covered: P00-S01 (tab bar and scan button only). The tokens are measured from P00-S01, P01-S01, P05-S01, P06-S01, P10-S01a and P30-S01 but are not applied to those screens here.

Test IDs: T01, T02 (regression, unchanged), T22 (new: shared visual foundation).

## Out of scope

- Restyling any screen other than the tab bar. Home and CardHolder move to `polish-home-cardholder`, Settings to `add-settings-pages`, Tools/Messages/Create Card to `add-tools-messages-digital-card`, and the scan flow (P02–P08) to milestone 3.
- Wiring any control to a route (the bell, "Create New Card", Settings rows, the crown). The feature changes above do that.
- CamCard illustrations, icons and logos. SF Symbols stand in for them.
- Dynamic Type scaling of the fixed type scale (see design D3).
- Dark mode.

## Capabilities

### New Capabilities

- `visual-style`: the app-wide look shared by every screen: color and type tokens, the tinted header and sheet layout, plain toolbar icons, the pushed-page navigation bar, the barebones placeholder page and light-only appearance.

### Modified Capabilities

- `app-shell`: "Tab navigation shell" gains the observed P00-S01 tab bar appearance (labels, colors, filled selected icons, gradient scan button) and a shared route list for pushed pages.

## Impact

- New: `CamCard Copy/Support/Theme/CCColor.swift`, `CCFont.swift`, `CCComponents.swift`, `CamCard Copy/Features/Shell/AppRoute.swift`, route stubs `Features/Messages/MessagesRoutes.swift`, `Features/Settings/SettingsRoutes.swift`, `Features/DigitalCard/DigitalCardRoutes.swift`.
- Modified: `MainTabBar.swift`, `AppTab.swift` (selected icon names only), `RootView.swift` (Home gets a navigation stack with a hidden bar), `CardHolderView.swift`, `ToolsView.swift`, `SettingsView.swift` (one `.appRoutes()` line each), `MyApp.swift` (light appearance), `openspec/config.yaml`.
- Tests: new `CamCard CopyTests/ThemeTests.swift`, `CamCard CopyTests/AppRouteTests.swift`, `CamCard CopyUITests/T22VisualFoundationUITests.swift`. No existing test is changed.
- No data model, persistence, recognition or scan-flow code is touched.
