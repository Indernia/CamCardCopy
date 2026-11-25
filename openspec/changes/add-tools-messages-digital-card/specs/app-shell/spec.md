# Spec Delta

## MODIFIED Requirements

### Requirement: Tools tab content

The Tools tab SHALL show "Tools" with "Help" and a "Recommend" / "Smart sync" selector, with "Recommend" selected initially. The two panes SHALL show the observed P30-S01 and P30-S02 tiles. Every tile and "Help" SHALL be inert.

The layout SHALL match P30-S01/P30-S02 within about 1 pt:

- "Tools" in the page title style at the top left.
- "Help" in `#1C4064` followed by a filled "?" circle at the top right.
- The selector labels are centered in the left and right halves. The selected label is in `#1F1F1F` with a short `#50A6F8` underline; the other is in `#9A9A9A`.
- A hairline divider sits below the selector.
- A two-column grid of rounded tiles has each tile's title in white at its bottom left.
- "AI Transcription" carries a red "New" badge at its top right.

CamCard's tile photographs SHALL NOT be copied.

#### Scenario: T21 — Tools opens on Recommend

- **WHEN** the user selects the Tools tab
- **THEN** "Recommend" and "Smart sync" are visible
- **AND** "AI Transcription", "Email Signatures", "Video Conference Card", "Dashboard", "High Accuracy" and "Team Business Card" are visible

#### Scenario: T21 — Smart sync shows the observed tiles

- **WHEN** the user selects "Smart sync"
- **THEN** "Save to Contacts", "Contacts Backup", "Salesforce", "Google Contacts", "Outlook/Office365" and "Export to Excel/Vcf" are visible
- **AND** the Recommend tiles are no longer shown

#### Scenario: T21 — Tools tiles are inert

- **WHEN** the user taps any Recommend or Smart sync tile
- **THEN** no screen, sheet or menu appears
- **AND** no card list, selection count or sync operation is shown
- **AND** the current Tools pane remains selected

#### Scenario: T21 — Tools Help is inert

- **WHEN** the user taps "Help"
- **THEN** no screen or menu appears (P16-S01 is out of scope)

#### Scenario: T23 — AI Transcription shows the "New" badge

- **WHEN** the Recommend pane is shown
- **THEN** a "New" badge is visible on the "AI Transcription" tile
- **AND** no other tile shows a badge

#### Scenario: T23 — Selector marks the selected pane

- **WHEN** the user selects "Recommend" and then "Smart sync"
- **THEN** only the selected segment reports the selected state each time

#### Scenario: T23 — Tools matches P30-S01 and P30-S02 (visual check)

- **WHEN** the Recommend and Smart sync panes are compared with P30-S01 and P30-S02
- **THEN** the title, Help, selector, underline, divider, tile sizes, gutters, corner radius, title placement and "New" badge are within about 1 pt and match the measured colors in design.md D3
