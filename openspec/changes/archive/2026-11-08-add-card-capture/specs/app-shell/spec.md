# Spec Delta

## REMOVED Requirements

### Requirement: Scan placeholder

**Reason**: The placeholder screen is replaced by the real card capture flow; it no longer exists in the app.
**Migration**: Use the new "Scan button opens card capture" requirement. The existing scan open/close UI test keeps its current path.

## ADDED Requirements

### Requirement: Scan button opens card capture

The center scan button SHALL open the full-screen card capture flow defined by the `card-capture` capability instead of a placeholder screen. Closing the camera SHALL dismiss the flow and return to the previously selected tab.

#### Scenario: T02 — Scan button opens the camera flow

- **WHEN** the user taps the center scan button
- **THEN** the card capture camera screen appears with Close (X)
- **AND** no placeholder screen is shown

#### Scenario: T02 — Closing the camera returns to the previous tab

- **WHEN** the user taps Close (X) on the camera screen
- **THEN** the capture flow is dismissed
- **AND** the previously selected tab is shown again

#### Scenario: ASSUMPTION — Existing scan open/close path is preserved

- **WHEN** the existing scan open/close UI check taps the center scan button
- **THEN** the camera screen appears
- **AND** tapping Close returns to the Home tab
