# digital-card-creation Specification

## Purpose
Defines the three-step "Create your card" flow (P33-S01, P33-S02, P33-S03) as an inert visual copy. Step navigation works; no digital card, account, login or network request is ever made.

## Requirements

### Requirement: Step progress and heading

Each step SHALL show a white navigation bar with a single back control and no title. Below it SHALL be three short progress dashes: step 1 has the first dash blue, step 2 the first two, step 3 all three; the rest are light grey. Then the heading "CREATE YOUR CARD" in blue heavy italic, centered.

#### Scenario: T23 — Progress reflects the current step

- **WHEN** steps 1, 2 and 3 are shown in turn
- **THEN** the progress indicator reports 1, 2 and 3 completed dashes respectively
- **AND** "CREATE YOUR CARD" is visible on every step

### Requirement: Step 1 — choose a template

Step 1 SHALL show "Choose the template you want for your digital business card", a horizontally peeking template card carousel with nine page dots (the first selected), a "Continue" button, and the line "Already have an account" followed by "Sign in". The template cards SHALL show neutral placeholder content, not CamCard's sample names, companies, phone numbers or emails (ASSUMPTION: the user confirms this in design.md Open Questions). "Continue" SHALL open step 2. "Sign in" SHALL open nothing (P20-S01 is not linked from here in the state diagram).

#### Scenario: T23 — Continue opens step 2

- **WHEN** the user taps "Continue" on step 1
- **THEN** step 2 is shown with "Complete your information."

#### Scenario: T23 — Step 1 Sign in is inert

- **WHEN** the user taps "Sign in" on step 1
- **THEN** no login screen appears and step 1 remains visible

### Requirement: Step 2 — complete your information

Step 2 SHALL show "Complete your information." and four grey rounded fields:

- "Full Name" as a small label with a red "*"
- "Enter company info to display."
- "Enter job title info to display."
- "Add an email address to be contacted."

Below the fields SHALL be "Scan paper cards" with a camera symbol, and a "Next step" button above a hairline divider. Typed values SHALL stay only on screen and SHALL NOT be saved anywhere (ASSUMPTION). "Next step" SHALL open step 3 whether or not "Full Name" is filled, as captured with an empty name and an active button. "Scan paper cards" SHALL open nothing.

#### Scenario: T23 — Step 2 shows the observed fields

- **WHEN** step 2 is shown
- **THEN** "Full Name", "Enter company info to display.", "Enter job title info to display.", "Add an email address to be contacted." and "Scan paper cards" are visible

#### Scenario: T23 — Next step opens step 3

- **WHEN** the user taps "Next step" with every field empty
- **THEN** step 3 is shown with "Only one step away, Sign in to save your card"

#### Scenario: T23 — Scan paper cards is inert

- **WHEN** the user taps "Scan paper cards"
- **THEN** the camera does not open and step 2 remains visible

### Requirement: Step 3 — sign in to save

Step 3 SHALL show:

- "Only one step away, Sign in to save your card"
- "Unregistered camcard email will be registered automatically"
- an empty field labelled "Email Number"
- an unchecked checkbox with "Agree to Terms of Service and Privacy Policy", where "Terms of Service" and "Privacy Policy" are blue and underlined
- a "Next" button
- "Or continue with" between two hairlines
- three outlined buttons: "Sign in with phone", "Sign in with Google" and "Sign in with Apple"

Every control on step 3 SHALL be inert: no login, registration, terms acceptance, web page or network call. The checkbox SHALL stay unchecked.

#### Scenario: T23 — Step 3 controls are inert

- **WHEN** the user taps "Next", the checkbox, "Terms of Service", "Privacy Policy", "Sign in with phone", "Sign in with Google" or "Sign in with Apple"
- **THEN** no screen, sheet, web page or alert appears
- **AND** step 3 remains visible

#### Scenario: T23 — Back walks the steps in reverse

- **WHEN** the user taps the back control on step 3, then step 2, then step 1
- **THEN** step 2, step 1 and the screen that opened step 1 are shown in that order

#### Scenario: T23 — Steps match P33-S01, P33-S02 and P33-S03 (visual check)

- **WHEN** each step is compared with its screenshot
- **THEN** the dashes, heading, text, fields, buttons and spacing are within about 1 pt and match the measured values in design.md D6–D8, apart from the replaced template content and logos
