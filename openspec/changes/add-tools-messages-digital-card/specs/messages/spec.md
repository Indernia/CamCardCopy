# Spec Delta

## Purpose

Defines the Messages list reached from the notification bell (P31-S01) and the Biz Tips feed it opens (P32-S01). Both are inert visual copies: they show the observed text and layout, never fetch messages, and use no network.

## ADDED Requirements

### Requirement: Messages list

The Messages route SHALL show a white navigation bar titled "Messages" with a single back control, over a light grey page holding one white row. The row SHALL show a round peach avatar with an orange speech-bubble symbol, the title "Biz Tips", the subtitle "Great business begins with a great first impression" truncated to one line, and the date "Sunday" at the trailing edge (ASSUMPTION: the date is shown as the fixed text "Sunday", as captured). The page SHALL NOT show any other message, badge or count.

#### Scenario: T23 — Messages shows the Biz Tips row

- **WHEN** the Messages route opens
- **THEN** "Messages", "Biz Tips" and "Sunday" are visible
- **AND** the subtitle beginning "Great business begins with a great first" is visible on one line

#### Scenario: T23 — Back returns to the previous screen

- **WHEN** the user taps the back control on Messages
- **THEN** the screen that opened Messages is shown again

### Requirement: Biz Tips row opens Biz Tips

Tapping the "Biz Tips" row SHALL push the Biz Tips page, as captured in the state diagram (P31-S01 → P32-S01).

#### Scenario: T23 — Tapping Biz Tips opens the feed

- **WHEN** the user taps the "Biz Tips" row
- **THEN** a page titled "Biz Tips" is shown with "Sunday" and "Welcome to CamCard"

### Requirement: Biz Tips feed

The Biz Tips page SHALL show the date header "Sunday" and one white bordered card on a light grey page. The card SHALL contain a banner placeholder with the caption "Great business begins with a great first impression" on a dark band at its bottom, and the title "Welcome to CamCard" below it. The banner SHALL NOT reproduce CamCard's illustration or logo. Tapping the card SHALL open nothing (ASSUMPTION: the article page, P32-S02, was not captured).

#### Scenario: T23 — Biz Tips card is inert

- **WHEN** the user taps the "Welcome to CamCard" card
- **THEN** no screen, sheet or web page appears
- **AND** the Biz Tips page remains visible

#### Scenario: T23 — Messages and Biz Tips match P31-S01 and P32-S01 (visual check)

- **WHEN** both pages are compared with P31-S01 and P32-S01
- **THEN** the navigation bar, row or card geometry, text sizes and colors are within about 1 pt and match the measured values in design.md D4–D5, apart from the replaced artwork
