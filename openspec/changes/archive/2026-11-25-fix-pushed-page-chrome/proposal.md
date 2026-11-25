# Proposal

## Why

While drafting the three milestone 2 changes, two facts about pushed pages turned up in the reference screenshots that add-visual-foundation got wrong. Both live in frozen shared files, so they have to be fixed on `main` before the three parallel changes start:

1. **No pushed page shows the tab bar.** P11, P12, P20, P31, P32 and P33 all have no tab bar; Home (a tab root) has one.
2. **The back chevron on pushed pages is `#232323`**, not the navy `#1C3F64` used for the bell and ⊕. Measured identically on P11, P12, P20, P31, P32 and P33. A 0.5 pt `#F1F1F1` hairline also sits under the white navigation bar.

## What Changes

- Add the color tokens `navInk` `#232323` and `navDivider` `#F1F1F1`.
- `ccPushedNavigationBar(title:)` draws the "‹" in `navInk` and a 0.5 pt `navDivider` line under the bar.
- Every page using `ccPushedNavigationBar` hides the app's tab bar while it is shown, and the tab bar returns when the user goes back to a tab root.
- Tab roots (Home, CardHolder, Tools, Settings) keep the navy `iconInk` for their bell and ⊕; that is unchanged.

State IDs: P11-S01, P12-S01, P20-S01, P31-S01, P32-S01, P33-S01 (chrome only). Test IDs: T22 (extended).

## Out of scope

- Every screen body. The pages themselves come from the three milestone 2 changes.
- Edit Card and the scan flow: they are in a full-screen cover with no tab bar already (milestone 3).

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `visual-style`: "Plain toolbar icons" now limits navy to tab-root icons; "Pushed-page navigation bar" gains the `#232323` chevron, the divider and the hidden tab bar.

## Impact

- Shared files edited (by Opus on `main`, before the milestone 2 worktrees are created): `Support/Theme/CCColor.swift`, `Support/Theme/CCComponents.swift`, `Features/Shell/RootView.swift`, plus a new `Support/Theme/TabBarVisibility.swift`.
- Tests: `ThemeTests` gains the two tokens; a new `TabBarVisibilityTests` unit suite. No existing test changes.
