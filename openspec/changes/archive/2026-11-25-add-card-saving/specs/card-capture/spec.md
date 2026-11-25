# Spec Delta

## REMOVED Requirements

### Requirement: Edit Card hand-off shell

**Reason**: "Save" is now enabled so the verified card can be persisted; the old requirement mandated a disabled Save because saving was not available.

**Migration**: Replaced by "Edit Card hand-off with enabled Save", which keeps the same chrome, rows and Retake behavior with an enabled Save.

### Requirement: Image hand-off without persistence

**Reason**: Edit Card now persists exactly one card when the user taps "Save"; the old requirement forbade any persistence. The full save contract lives in the `card-saving` capability.

**Migration**: Replaced by "Image hand-off and save hand-off", which keeps the original and corrected images separate and limits persistence to exactly one card per save.

## ADDED Requirements

### Requirement: Edit Card hand-off with enabled Save

After a successful capture or import, or after "Continue saving", the app SHALL show the Edit Card screen with "Retake" leading, "Edit Card" as the title, "Save" trailing, the card image, and the recognized contact fields with "Full Name" as the first row. Each row SHALL show its recognized value, or an empty value when nothing was recognized. "Save" SHALL be enabled so the verified card can be saved. "Retake" SHALL return to the camera without saving.

#### Scenario: ASSUMPTION — Edit Card shell is shown with enabled Save (P05-S01 shows an active Save)

- **WHEN** the flow reaches Edit Card with nothing recognized
- **THEN** "Retake", "Edit Card" and "Save" are visible
- **AND** "Save" is enabled
- **AND** the card image and an empty "Full Name" row are visible
- **AND** the empty row shows no fabricated value

#### Scenario: T07 — Recognized fields pre-fill Edit Card (ASSUMPTION: P05-S02 not captured)

- **WHEN** the flow reaches Edit Card after recognition parsed values
- **THEN** "Retake", "Edit Card" and "Save" are visible
- **AND** "Save" is enabled
- **AND** the card image and the recognized field rows are visible with "Full Name" first
- **AND** each row shows its recognized value

#### Scenario: ASSUMPTION — Retake returns to the camera (P05-S08 not captured)

- **WHEN** the user taps "Retake"
- **THEN** the camera screen is shown again
- **AND** no card is saved and no discard confirmation is shown

### Requirement: Image hand-off and save hand-off

The flow SHALL carry the original image, the corrected image when available, the raw OCR text and the recognized fields to Edit Card. Edit Card SHALL persist exactly one card only when the user taps "Save"; it SHALL NOT create or update any record before that. The two images SHALL remain separate.

#### Scenario: T06 — Original and corrected images stay distinct

- **WHEN** detection finds a card and correction succeeds
- **THEN** the original image data and the corrected image data are both retained
- **AND** the original image data is not replaced by the corrected image

#### Scenario: T11 — Edit Card persists nothing before Save

- **WHEN** the flow reaches Edit Card, including through "Continue saving", and the user has not tapped "Save"
- **THEN** the card repository still contains the same number of cards as before
- **AND** no card record is created or updated

#### Scenario: T11 — Edit Card persists exactly one card on Save

- **WHEN** the user taps "Save" on Edit Card
- **THEN** exactly one card record is created from the hand-off's images and raw OCR text
- **AND** retapping the same Save control does not create a second card

### Requirement: Capture source travels with the hand-off

The hand-off SHALL identify whether the card came from the camera shutter or from the album picker, so saving can record the observed Note source line. A shutter capture SHALL be a camera capture; a photo chosen in the album picker and confirmed with "Done" SHALL be an album import.

#### Scenario: T12/P08-S01 — A shutter capture is a camera source

- **WHEN** the user captures a card with the shutter and reaches Edit Card
- **THEN** the hand-off identifies the card as a camera capture

#### Scenario: ASSUMPTION — An album selection is an album source (P03-S06 not captured)

- **WHEN** the user selects a photo in the album picker and taps "Done"
- **THEN** the hand-off identifies the card as an album import
