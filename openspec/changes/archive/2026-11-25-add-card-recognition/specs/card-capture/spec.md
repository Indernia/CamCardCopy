# Spec Delta

## MODIFIED Requirements

### Requirement: Edit Card hand-off shell

After a successful capture or import, or after "Continue saving", the app SHALL show the Edit Card screen with "Retake" leading, "Edit Card" as the title, "Save" trailing, the card image, and the recognized contact fields with "Full Name" as the first row. Each row SHALL show its recognized value, or an empty value when nothing was recognized. "Save" SHALL be visibly disabled because saving is not available yet. "Retake" SHALL return to the camera without saving.

#### Scenario: ASSUMPTION — Edit Card shell is shown with disabled Save (P05-S01 shell only; T08/T09/T11 not covered)

- **WHEN** the flow reaches Edit Card with nothing recognized
- **THEN** "Retake", "Edit Card" and "Save" are visible
- **AND** "Save" is disabled
- **AND** the card image and an empty "Full Name" row are visible
- **AND** the empty row shows no fabricated value

#### Scenario: T07 — Recognized fields pre-fill Edit Card (ASSUMPTION: P05-S02 not captured)

- **WHEN** the flow reaches Edit Card after recognition parsed values
- **THEN** "Retake", "Edit Card" and "Save" are visible
- **AND** "Save" is disabled
- **AND** the card image and the recognized field rows are visible with "Full Name" first
- **AND** each row shows its recognized value

#### Scenario: ASSUMPTION — Retake returns to the camera (P05-S08 not captured)

- **WHEN** the user taps "Retake"
- **THEN** the camera screen is shown again
- **AND** no card is saved and no discard confirmation is shown
