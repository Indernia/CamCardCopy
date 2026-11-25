# Visual and flow check: add-settings-pages

Simulator: CC Agent Settings (79E4E936-57C1-4D61-8464-D173AEEC32B8), 402 x 874 pt, 3 px/pt.
Screenshots: `docs/manual-checks/add-settings-pages/*.png`.

## Measurement convention

- Reference mockups: `y_pt = y_px / 1.537 + 3.1`, `x_pt = (x_px - 8) / 1.537`.
- Reference bar divider: 150 px (about 100.7 pt). Ours: 116 pt on pushed pages.
- Tables below give content positions relative to the divider ("rel") for pushed pages, and absolute pt for the root. Title and chevron offsets are the known system-bar difference and are not reported.
- Tolerance: positions +/-3 pt, sizes +/-3 pt, colours +/-8 per channel.

## P10-S01a / P10-S01b (Settings root)

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Title "Settings" centre | about 79 pt | 81 pt | Pass |
| Sign-in card top | 126 pt (ref) | 119 pt | Fail (-7) |
| Sign-in card height | about 124 pt (ref) | 115 pt | Fail (-9) |
| Premium card top | 266 pt (ref) | 251 pt | Fail (-15) |
| Premium card height | 157 pt (ref, spec about 157) | 143 pt | Fail (-14) |
| "APP SETTINGS" header | 465 pt (ref) | 433 pt | Fail (-32, follows premium card) |
| First root row height | about 51 pt | 51 pt | Pass |
| Texts (sign-in, Premium, Upgrade +, section headers, all rows, Resume In-APP Purchases, Help and Feedback, Recommend to Friends, About, Personal Information Collection Checklist) | present | present | Pass |
| P10-S01b: header pinned, tab bar shown | pinned | pinned | Pass |

## P11 General

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| First row top, rel | 10.4 pt | 10.5 pt | Pass |
| Row height | 49.3 pt | 50 pt | Pass |
| Toggle off track | #CCCCCC | (197,197,199) | Pass |
| Texts (all rows, footer) | present | present | Pass |
| Tab bar hidden | hidden | hidden | Pass |
| Tap toggle, state unchanged | unchanged | unchanged | Pass |

## P12 Language setting

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| List top, rel | 10.4 pt | 10.5 pt | Pass |
| Row height | 49.8 pt | 50.8 pt | Pass |
| Six languages, order, check on System Default | as spec | as spec | Pass |
| Tap English, check stays on System Default | unchanged | unchanged | Pass |

## P13 Notifications

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Row 1 top, rel | 10.4 pt | 10.5 pt | Pass |
| Row 1 height | 49.3 pt | 50 pt | Pass |
| Group 2 top, rel | 114.7 pt | 112 pt | Pass |
| Texts incl. footer, Sound and Vibrate on | as spec | as spec | Pass |
| Tap Sound, stays on | unchanged | unchanged | Pass |

## P14 Privacy Settings

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Row top, rel | 8.4 pt | 10.5 pt | Pass |
| Row height | 59.6 pt | 50 pt | Fail (-10) |
| Toggle off track | #CCCCCC | (197,197,199) | Pass |
| Texts incl. footer | as spec | as spec | Pass |
| Tap toggle, state unchanged | unchanged | not run | Not run |

## P15 System permissions

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Title position, rel | 51.9 pt | 54.5 pt | Pass |
| Texts (title, description, Settings link) | as spec | as spec | Pass |
| Card height and link colour | reference not measured | 110 pt card | Not run |

## P16 Help and Feedback

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Section band top, rel | 0.9 pt | 0 pt | Pass |
| Section band height | 40 pt | 40.5 pt | Pass |
| Question row pitch | 44.8 pt | 50.7 pt | Fail (+6) |
| Nine questions, two categories, "Contact Us" | as spec | as spec | Pass |
| "Contact Us" height | about 40 pt | about 40 pt | Pass |
| Nav bar white | white | white | Pass |

## P17 Recommend CamCard

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Banner top, rel | 0.7 pt | 0.7 pt | Pass |
| Banner height | 258 pt | 258 pt | Pass |
| Share sheet top, rel | 593 pt | 607 pt | Fail (+14) |
| Share icons, offset from sheet top | 25 pt | 17 pt | Fail (-8) |
| Texts (title, banner, card, four tiles, four labels, note, fine print, facebook/sms/email) | as spec | as spec | Pass |
| Tap "email", no sheet | no sheet | not run | Not run |

## P18 About

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Row top, rel | 9.7 pt | 10.5 pt | Pass |
| Row height | 50 pt | 50.7 pt | Pass |
| Version line, rel | 208 pt | 211 pt | Pass |
| Texts (Rate It Now, Follow us, Contact Us, version, terms link) | as spec | as spec | Pass |
| Version text | "CamCard Copy 1.0" | accepted (D6) | Pass |
| IntSig copyright line | omitted | omitted | Pass (accepted) |

## P19 Personal Information Collection Checklist

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Table top, rel | 41 pt | 9 pt | Fail (-32) |
| Table title and three column headers | as spec | as spec | Pass |
| Six row titles and cells | as spec | as spec | Pass |
| Table side margins | about 21 pt (ref) | 16 pt | Fail (minor) |
| Bar title truncated, divider present | as ref | as ref | Pass |

## P20 Login via email

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Heading, rel | 35.8 pt | 51.4 pt | Fail (+16) |
| Email box, agree box, Next, five sign-in buttons | as ref | as ref, buttons 45 pt tall | Pass |
| Texts (heading, subtitle, placeholder, agree text, "Or continue with") | as spec | as spec | Pass |
| Typing in email box, cleared on return | empty | empty | Pass |
| Keyboard open: layout | subtitle and divider text not truncated | page scrolls under bar, subtitle "re...", "Or continue..." truncated | Fail |
| Tap Next or a sign-in button | nothing | not run | Not run |

## P21 Upgrade Plans

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| "Upgrade Plans" title once, centred | once, centred | once, centred | Pass |
| Selected tab | Premium | PRO highlighted | Fail |
| Plan tiles and prices, 12 Months selected with trial badge | as spec | as spec | Pass |
| Trial text | as spec | as spec | Pass |
| Feature table columns Feature, Pro, Premium | as spec | as spec; first-column label wraps ("Business / Card Scanner") | Pass (minor wrap) |
| Tap PRO tab, Tap Continue, nothing changes | unchanged | unchanged | Pass |

## Account and Sync

| item | expected | measured | Pass/Fail |
|---|---|---|---|
| Opens "Not built yet" page, tab bar hidden, back works | as spec | as spec | Pass |

## Flow checks

| check | result |
|---|---|
| Every row on the Settings root opens its page (P11-P19, Account and Sync, P20 from sign-in, P21 from Upgrade) | Pass |
| No tab bar on any pushed page | Pass |
| "‹" returns to Settings with tab bar | Pass (back tap sometimes did not register on the first try, about 3 of 20 taps; retried) |
| Toggles keep state when tapped (P11, P13) | Pass |
| Toggle P14 | Not run |
| Buttons open nothing (P12, P21) | Pass |
| Buttons open nothing (P15, P16, P17, P18, P20 sign-in and Next) | Not run |
| P20 email box typed text not saved | Pass |

## Mismatches (ranked by visibility)

Fix round 1: each item was re-measured against the reference before changing. Rules: pushed pages compare content relative to the divider; bottom-anchored elements compare internal spacing, not absolute y. Measurements are in pt.

1. **P21 selected tab.** Premium was selected in code, but PRO looked highlighted (strong lavender, bold). Fixed: Premium now has a gold open-bottom outline and the panel colour, PRO is lighter and smaller. "Upgrade Plans" renders once, centred (checked: one title). Before: PRO looked selected. After: Premium looks selected.
2. **P10 root.** Re-measured: sign-in card top 119 -> 127.7 (ref 126), height 115 -> 124 (ref 125); Premium card top 251 -> 266.7 (ref 266), height 143 -> 158 (ref 160 incl. border); "APP SETTINGS" and rows follow (gap 59.7 ref, 60 ours). Rows still 51 pt pitch. P10-S01b: header pinned, rows keep 51 pt pitch and the 12 pt gaps; absolute y differs because the scroll end is bottom-anchored (not compared).
3. **P19 table.** Top below divider 9 -> 46 (ref 45.5), grey band 26 pt added as in the reference, side margins 16 -> 21.
4. **P20 login.** Heading centre rel 51 -> about 36 (ref 35.8). Form is now in a ScrollView; with the keyboard open the page does not slide under the bar and no text is truncated (screenshot `P20-S01-keyboard.png`). Social buttons stay pinned to the bottom when there is room.
5. **P17 share bar.** Re-checked under the bottom-anchored rule: absolute sheet top is not comparable. Internal spacing (sheet top to icon top) was 17, ref 24: now 24. Bottom padding unchanged.
6. **P14 row height.** 50 -> 59 (ref 59.2).
7. **P16 question rows.** Pitch 50.7 -> 45 (ref 44.8); two-line rows 66 (ref 67).
8. **P21 first column.** "Business Card Scanner" no longer wraps (single line, scaled to fit).
9. **P15 card height.** Measured 111 -> 98 (ref 99). Link colour is `#50A6F8`.

Not-run checks, now run on the simulator (all inert):
- P14 toggle tap: state unchanged (test T25 plus visual).
- P15 "Settings" link tap: nothing opens.
- P16 question, category and "Contact Us" taps: nothing opens.
- P17 "email" tap: no composer or sheet.
- P18 "Rate It Now" tap: nothing opens (T25).
- P20 agree box, Next and "Sign in with Apple" taps: no change, no sheet; typing works and is not saved.

Known and accepted, not listed per page: the navigation bar divider (about 15 pt lower on ours) and the chevron and title (about 4 pt lower), caused by the iOS 27 system bar.

## Counts

- Pass: 56 rows (tables and flow checks)
- Fail: 14 rows (P10 x5, P14 x1, P16 x1, P17 x2, P19 x2, P20 x2, P21 x1)
- Not run: 6 rows (P14 toggle tap, P15 card height, P17 email tap, P20 Next and sign-in, P14 flow toggle, P15/P16/P17/P18 button taps in the flow check)

Updated after fix round 1.
