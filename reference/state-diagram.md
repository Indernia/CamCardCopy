# CamCard state diagrams

Source of truth for navigation. State names use underscores (P01_S01 = P01-S01 in `observations.md`). Transitions marked "not yet captured" are unverified.

## Navigation shell

```mermaid
stateDiagram-v2
  [*] --> P00_S01: first launch, logged out
  P00_S01 --> P01_S01: tab CardHolder
  P00_S01 --> P30_S01: tab Tools
  P00_S01 --> P10_S01: tab Settings
  P00_S01 --> P31_S01: bell
  P00_S01 --> P33_S01: Create New Card
  P30_S01 --> P30_S02: Smart sync
  P31_S01 --> P32_S01: Biz Tips
  P33_S01 --> P33_S02: Continue
  P33_S02 --> P33_S03: Next step
  P10_S01 --> P20_S01: Sign in
  P10_S01 --> P11_S01: General
  P10_S01 --> P12_S01: Language setting
  P10_S01 --> P13_S01: Notifications
  P10_S01 --> P14_S01: Privacy Settings
  P10_S01 --> P15_S01: System permissions
  P10_S01 --> P16_S01: Help and Feedback
  P10_S01 --> P17_S01: Recommend to Friends
  P10_S01 --> P18_S01: About
  P10_S01 --> P19_S01: Personal Information Collection Checklist
```

## Scan flow

```mermaid
stateDiagram-v2
  P00_S01 --> P02_S01: center scan button
  P01_S01 --> P02_S01: center scan button
  P02_S01 --> P02_S02: tap High Accuracy
  P02_S02 --> P02_S01: tap Basic
  P02_S01 --> P03_S01: Album (limited access)
  P03_S01 --> P03_S02: back
  P02_S01 --> P04_S01: capture, no card detected
  P02_S01 --> P05_S02: capture, card detected (not yet captured)
  P04_S01 --> P05_S01: Continue saving
  P04_S01 --> P02_S01: Cancel saving (not yet verified)
  P05_S01 --> P02_S01: Retake
  P05_S01 --> P06_S01: Save
  P06_S01 --> P07_S01: Group
  P06_S01 --> P08_S01: Note
  P06_S01 --> P21_S01: Sync / Export (premium)
  P06_S01 --> P02_S01: Take the next
  P06_S01 --> P01_S02: Done (not yet captured)
```
