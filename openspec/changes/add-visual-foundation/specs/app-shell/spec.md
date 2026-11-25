# Spec Delta

## MODIFIED Requirements

### Requirement: Tab navigation shell

The app SHALL present a tab bar labelled "Home", "CardHolder", "Tools" and "Settings" with a center scan button. Selecting Home, CardHolder, Tools or Settings SHALL show that tab's content. The center scan button SHALL be a button, not a fifth tab selection.

The tab bar SHALL match P00-S01: a white background, 10 pt labels, the selected tab's icon and label in `#1E1E1E` with a filled icon, unselected tabs in `#989898` with an outline icon, and a 56 pt round center scan button filled with the `#534EF6` to `#873EF6` gradient and a white camera symbol. Tab labels, accessibility identifiers and selection behavior SHALL NOT change.

#### Scenario: T01 — First launch opens the Home tab

- **WHEN** the app launches with an empty store
- **THEN** the Home tab is selected and the P00-S01 Home content is visible

#### Scenario: T21 — Tools and Settings open their observed tabs

- **WHEN** the user selects the Tools or Settings tab
- **THEN** that tab's inert placeholder content from P30-S01/P30-S02 or P10-S01 is shown
- **AND** no "Coming soon" text is rendered in either tab

#### Scenario: T22 — Selected tab is marked and the others are not

- **WHEN** the user selects each of Home, CardHolder, Tools and Settings in turn
- **THEN** only the selected tab button reports the selected state
- **AND** the labels "Home", "CardHolder", "Tools" and "Settings" stay visible

#### Scenario: T22 — Scan button keeps opening the camera

- **WHEN** the user taps the restyled center scan button
- **THEN** the card capture camera screen appears with Close (X)

#### Scenario: T22 — Tab bar matches P00-S01 (visual check)

- **WHEN** the tab bar is compared with P00-S01
- **THEN** the background is white, labels use the measured colors and size, the selected icon is filled, and the scan button shows the violet gradient

## ADDED Requirements

### Requirement: Shared route list for pushed pages

The app SHALL keep one list of pushable destinations: "Messages" (P31-S01), "Biz Tips" (P32-S01), "Create your card" steps 1–3 (P33-S01, P33-S02, P33-S03), the Settings sub-pages "Account and Sync" (P10-S01, ASSUMPTION: not captured), "Language setting" (P12-S01), "Notifications" (P13-S01), "Privacy Settings" (P14-S01), "System permissions" (P15-S01), "Help and Feedback" (P16-S01), "Recommend to Friends" (P17-S01), "About" (P18-S01), "Personal Information Collection Checklist" (P19-S01), "Login via email" (P20-S01) and "Upgrade Plans" (P21-S01). Home, CardHolder, Tools and Settings SHALL each be able to push any of them. In this change no control pushes a route; every control that was inert stays inert.

#### Scenario: T22 — Routes exist without changing inert controls

- **WHEN** the app runs after this change
- **THEN** every route in the list resolves to a page
- **AND** the Home bell, "Create New Card", the CardHolder bell and every Settings row except "General" still open nothing
