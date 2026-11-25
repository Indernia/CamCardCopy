# visual-style Specification

## Purpose
Defines the app-wide look every screen shares, measured from the reference screenshots: color and type tokens, the tinted header with a white sheet, plain toolbar icons, the pushed-page navigation bar, the barebones placeholder page for unbuilt destinations, and light-only appearance.

## Requirements

### Requirement: Measured color tokens

The app SHALL define one shared set of colors measured from the reference screenshots and SHALL use only these for the shared chrome: header tint `#F3F7F8`, sheet `#FFFFFF`, grouped page background `#F0F0F0`, grouped card `#FAFAFA`, icon ink `#1C3F64`, primary text `#151314`, secondary text `#989898`, section header text `#5F5E5E`, separator `#EAEAEA`, accent blue `#50A6F8`, tab selected `#1E1E1E`, tab unselected `#989898`, scan gradient `#534EF6` to `#873EF6`, premium gradient `#EF8C44` to `#F4BA47`, premium card `#FEF4D8`.

#### Scenario: T22 — Color tokens equal the measured reference values

- **WHEN** the color tokens are read
- **THEN** each token equals the hex value listed above

### Requirement: Fixed type scale

The app SHALL define a fixed type scale measured from the reference screenshots at the default text size: page title 24 pt regular, navigation title 18 pt regular, section title 18 pt medium, row text 15 pt regular, emphasized row 16 pt medium, secondary text 13 pt regular, section header 14 pt regular, tab label 10 pt regular. The sizes SHALL NOT change with the system text size (ASSUMPTION: CamCard's text did not appear to scale; not verified).

#### Scenario: T22 — Type scale equals the measured sizes

- **WHEN** the type scale is read
- **THEN** each role has the point size and weight listed above

### Requirement: Light appearance only

The app SHALL always render in light appearance, whatever the system setting (ASSUMPTION: dark mode was not captured).

#### Scenario: T22 — Dark system appearance still shows light chrome

- **WHEN** the device is in dark appearance and the app launches
- **THEN** the tab bar background is white and tab labels use the light-mode colors

### Requirement: Tinted header with white sheet

The app SHALL provide a screen layout with a header area in the header tint and a white sheet below it with rounded top corners, as observed on P00-S01 and P01-S01. Screens adopt it in their own changes; this requirement defines the shared layout only.

#### Scenario: T22 — Header and sheet render in the measured colors (visual check)

- **WHEN** a screen uses the tinted header layout
- **THEN** the header area is `#F3F7F8`, the sheet is `#FFFFFF`, and the sheet's top corners are rounded

### Requirement: Plain toolbar icons

Toolbar icons on tab roots (the bell and ⊕ on Home and CardHolder) SHALL render as plain icons in the icon ink `#1C3F64`, with no circular or glass background, as observed on P00-S01 and P01-S01. The back chevron on pushed pages follows "Pushed-page navigation bar" instead.

#### Scenario: T22 — Toolbar icons have no glass background (visual check)

- **WHEN** a tab root shows a plain toolbar icon
- **THEN** the icon is drawn in `#1C3F64` with no circle or material behind it

### Requirement: Pushed-page navigation bar

Every page pushed through the shared route list SHALL show a plain "‹" back control at the top left drawn in `#232323` with no circle or glass, a centered title in the navigation title style, and a 0.5 pt `#F1F1F1` line under the bar, as observed on P11-S01, P12-S01, P20-S01, P31-S01, P32-S01 and P33-S01. The system back button SHALL be hidden on these pages so only one back control exists. Tapping "‹" SHALL return to the previous screen. While such a page is shown the app's tab bar SHALL be hidden, and it SHALL reappear when the user returns to a tab root.

#### Scenario: T22 — A pushed page shows one plain back control and its title

- **WHEN** a placeholder route page is pushed
- **THEN** exactly one back control is visible, its title is centered, and tapping the back control returns to the previous screen

#### Scenario: T22 — Pushed pages hide the tab bar

- **WHEN** a page with the pushed-page navigation bar is shown
- **THEN** the tab bar and the scan button are not visible
- **WHEN** the user taps "‹" back to the tab root
- **THEN** the tab bar and the scan button are visible again

#### Scenario: T22 — Chevron and divider colors match the reference (visual check)

- **WHEN** a pushed page is compared with P31-S01
- **THEN** the chevron is `#232323` and a thin `#F1F1F1` line runs under the bar

### Requirement: Barebones placeholder page

A route whose screen is not built yet SHALL open a barebones page that shows the route's title in the pushed-page navigation bar, a short "Not built yet" note and the route's state ID (for example "P31-S01"). It SHALL NOT show invented content, fetch data, use the network or simulate login or payment. Its source SHALL carry a `TODO(P##-S##)` marker for the state it stands in for.

#### Scenario: T22 — Every route resolves to a titled page with a state ID

- **WHEN** each route in the shared route list is resolved
- **THEN** it has a non-empty title and a state ID in the form `P##-S##`
- **AND** an unbuilt route shows that title, "Not built yet" and the state ID
