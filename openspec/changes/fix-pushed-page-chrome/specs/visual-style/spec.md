# Spec Delta

## MODIFIED Requirements

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
