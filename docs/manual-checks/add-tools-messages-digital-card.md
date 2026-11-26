# Manual check: add-tools-messages-digital-card

Simulator: CC Agent Tools (9A0D94F6-D053-4AA0-B8BC-6DD2BEE80781), iPhone 402x874 pt, 3 px/pt.
Screens captured in `docs/manual-checks/add-tools-messages-digital-card/`.
Method: y positions measured in pt from the top of each frame (ink bands, sampled from the simulator PNGs and compared with the design tables and the reference mockups). Colours were NOT sampled, so colour rows are listed as Not measured. Reference mockups are 620x1312 (about 1.537 px/pt), so their y values are approximate.

## P30-S01 Tools, Recommend
| Item | Expected | Measured | Pass/Fail |
|---|---|---|---|
| "Tools" cap top | 67.7 | 74.0 | Fail (+6.3) |
| Segment labels cap top | 115.8 | 119.3 | Fail (+3.5) |
| Selector underline y | 146.4 | 150.3 | Fail (+3.9) |
| First tile top | 167 | 169.7 | Pass (+2.7) |
| Titles present (AI Transcription, Email Signatures, Video Conference Card, Dashboard, High Accuracy, Team Business Card) | present | present | Pass |
| "New" badge only on AI Transcription | only there | only there | Pass |
| Tab bar shown | yes | yes | Pass |
| Colours (Help, ? circle, underline, selector) | per D3 | Not measured | n/a |

## P30-S02 Tools, Smart sync
| Item | Expected | Measured | Pass/Fail |
|---|---|---|---|
| Smart sync selected, grid switches to sync tiles | yes | yes (Save to Contacts, Contacts Backup, Salesforce, Google Contacts, Outlook/Office365, Export to Excel/Vcf) | Pass |
| Selector underline y | 146.4 | 150.3 | Fail (+3.9) |

## P31-S01 Messages
| Item | Expected | Measured | Pass/Fail |
|---|---|---|---|
| Nav title "Messages" cap top | 67.0 (reference) | 73.3 | Fail (+6.3) |
| Row "Biz Tips", "Sunday", subtitle present | present | present | Pass |
| No tab bar on pushed page | none | none | Pass |
| Back chevron present | yes | yes | Pass |
| Nav divider and row colours | per D2/D4 | Not measured | n/a |

## P32-S01 Biz Tips
| Item | Expected | Measured | Pass/Fail |
|---|---|---|---|
| "Sunday" date header cap top | 118.4 | 133.0 | Fail (+14.6) |
| Card top | 139.2 | about 160 | Fail (+21) |
| Banner top | 147 | about 167 | Fail (+20) |
| "Welcome to CamCard" cap top | 343.5 | 358.3 | Fail (+14.8) |
| Caption text and card title present | present | present | Pass |
| No tab bar, back chevron present | yes | yes | Pass |
| Background #F0F0F0 | #F0F0F0 | looks correct, not sampled | Not measured |

## P33-S01 Create your card, step 1
| Item | Expected | Measured | Pass/Fail |
|---|---|---|---|
| Progress dashes top | 105.4 | 123.7 | Fail (+18) |
| "CREATE YOUR CARD" cap top | 131.4 | 146.0 | Fail (+14.6) |
| Subtitle top | 168 | 189 | Fail (+21) |
| Template card top | 239 | about 260 | Fail (+21) |
| Page dots y | 673 | about 705 | Fail (+32) |
| Continue button top | 708 | about 737 | Fail (+29) |
| "Already have an account / Sign in" y | 779 | about 816 | Fail (+37) |
| Texts present, back chevron, no tab bar | yes | yes | Pass (4 items) |

## P33-S02 Create your card, step 2
| Item | Expected | Measured | Pass/Fail |
|---|---|---|---|
| Field 1 top ("Full Name", *) | 227 | 249 | Fail (+22) |
| Fields 2 to 4 (company, job title, email) present, pitch 67 | yes | yes | Pass |
| "Scan paper cards" present | yes | yes | Pass |
| "Next step" button, height 47 | 47 | 46 | Pass |

## P33-S03 Create your card, step 3
| Item | Expected | Measured | Pass/Fail |
|---|---|---|---|
| Subtitle, note, email field, checkbox with Terms and Privacy links | present | present | Pass |
| "Next" button, "Or continue with", three sign-in capsules | present | present | Pass |
| Positions | per D7/D8 | not measured separately; likely inherits the +18 to +22 offset | Not measured |

## Flow checks
| Flow | Result |
|---|---|
| Tools, Recommend to Smart sync | Pass |
| Messages row to Biz Tips | Pass (Tools tap, then row tap) |
| Create card: step 1 Continue to step 2 | Pass |
| Step 2 Next step to step 3 | Pass |
| Back x3 from step 3 returns to Tools | Pass |
| Biz Tips card tap inert, step 3 controls inert | Not run |

## Mismatches (fix round 1, re-measured)

Method: reference mockup y_pt = y_px/1.537 + 3.1, x_pt = (x_px - 8)/1.537; simulator shots are 3 px/pt (402 pt wide). On pushed pages (P31, P32, P33) positions are compared as offsets from the nav-bar divider: reference (y_px - 150)/1.537, ours y_pt - 116. Accepted by the user: the iOS 27 system nav bar stays ~15 pt taller than the reference (recorded in design.md Risks). Screenshots after the fix: `fix1-P30-S01.png` ... `fix1-P33-S03.png` in the folder above.

| Item | Reference | Before | After |
|---|---|---|---|
| Tools title ink top (pt) | 72.7 | 77.3 (+4.6) | 72.0 (-0.7) |
| Tools selector labels | 118.9 | 119.3 | 119.3 |
| Tools underline / divider | 148.8-151.4 / 152.4 | 150.3 / 152.3 | 150.3 / 152.3 (within 2) |
| Tools tiles top / row bottoms | 169.0 / 357-359 | 170.0 / 357.3 | 170.0 / 357.3 |
| Tools smart-sync tiles, underline | matches | matches | matches |
| P31 "Biz Tips" title (offset) | 24.1 | 21.0 (-3.1) | 23.7 |
| P31 subtitle (offset) | 48.1 | 46.7 | 49.3 |
| P31 "Sunday" (offset) | 26.0 | 24.0 | 26.7 |
| P31 avatar (offset) | 15.0-65.1 | 15-64 | 15-64 |
| P32 "Sunday" header (offset) | 20.8 | 17.0 (-3.8) | 21.0 |
| P32 banner top (offset) | 49.4 | 51.0 (+1.6) | 49.7 |
| P32 card title (offset) | 245.9 | 243.0 (-2.9) | 246.0 |
| P33-S01 dashes (offset) | 7.8 | 7.7 | 7.7 |
| P33-S01 heading (offset) | 33.8 | 30.0 (-3.8) | 34.0 |
| P33-S01 subtitle (offset) | 69.6 | 73.0 (+3.4) | 69.7 |
| P33-S01 card top / bottom (offset) | 141.8 / 547.2 | 144 / 555 (card 411 tall) | 142.7 / 547.3 (card now 244 x 405) |
| P33-S01 dots (offset) | 575.1 | 586.3 (+11.2) | 575.3 |
| P33-S01 Continue top (offset) | 609.6 | 620.7 (+11.1) | 609.7 |
| P33-S01 Sign in text (offset) | 681.2 | 693.7 (+12.5) | 681.3 |
| P33-S02 subtitle / first field top (offset) | 69.6 / 128.8 | 73.0 / 133.0 | 69.7 / 129.7 |
| P33-S02 fields 2 to 4 (offset) | 195.8 / 262.8 / 329.7 | +4.2 | +0.9 |
| P33-S02 "Scan paper cards" (offset) | 400.1 | 410.7 (+10.6) | 400.3 |
| P33-S03 note / field / checkbox / Next (offset from subtitle) | 73.5 / 120.4 / 186.7 / 244.7 | 64.3 / 117.3 / 189.3 / 249 | 73.3 / 120.3 / 186.0 / 244.0 |
| P33-S03 "Or continue with" (offset) | 511.4 | capsules followed content | 511.3 (bottom group pinned to the bottom, as in the reference) |

Remaining differences, all accepted or shared-file:
- Pushed-page nav bar height, chevron and title position (accepted by the user). The nav title ink is `#151314` (shared `CCFont`/`CCColor`) where the reference samples `#1E1E1E`: shared file, not changed here.
- P33-S03 reference sits about 13 pt lower in the header (capture-state difference, design D6); relative spacing below the subtitle matches.
- Banner and template card content are neutral placeholders (CamCard artwork not copied).

## Colour samples (reference vs ours, max channel difference, limit 8)

| Screen | Samples (all within 8 unless noted) |
|---|---|
| P30 | title #1B1B1B vs #151314 (8); Help text #1A4165 vs #1C3F64 (2); ? circle #1C4064 vs #1C3F64 (1); Recommend #1A1A1A vs #1E1E1E (4); Smart sync #9A9A9A vs #989898 (2); underline #50A6F8 (0); New badge #EB3323 vs #EB3324 (1) |
| P31 | page #F2F2F2 vs #F0F0F0 (2); avatar fill #FCF0E9 vs #FDEEE5 (4); title #131213 vs #151314 (2); subtitle #9F9F9F (0); date #A1A1A1 vs #9F9F9F (2); nav title #1E1E1E vs #151314 (11, shared nav bar, accepted) |
| P32 | page #F0F0F0 (0); date #656565 (0); card title #1A1A1A (0); banner is placeholder gradient (reference artwork blues #4497F5 to #204CF4, band #1F3B8C) |
| P33-S01 | heading #50A6F8 vs #4FA5F7 (1, now the accent token); subtitle #141414 vs #151314 (1); Continue #50A6F8 (0); dashes #50A6F8 / #D8D8D8 vs #D9D9D9; dots #50A6F8 / #E7E7E7 (0); "Already have an account" #989898 (0); Sign in #5E5E5E vs #5F5E5E (1) |
| P33-S02 | heading (1); subtitle #191919 (0); field #F0F0F0 (0); placeholder #A9A9A9 (0); Scan text #5E5E5E vs #626262 (4, now the sectionHeader token #5F5E5E) |
| P33-S03 | subtitle #121212 (0); note #989898 (0); field #F0F0F0 (0); Next #50A6F8 (0); checkbox #ACACAC vs #A5A5A5 (7); agree text #1D1D1D vs #1E1E1E (1); Or continue #868686 vs #8A8A8A (4); capsule edge #CECECE (0); capsule text #161616 (0) |

## Counts
Pass 23, Fail 17, Not measured: colours and step 3 positions (not counted).

## Re-check after fix round 1
Build of commit 9dcc68f, reinstalled on CC Agent Tools. Screens: `docs/manual-checks/add-tools-messages-digital-card/recheck-*.png`.
Pushed pages are measured relative to the bar divider. The divider is at 116 pt in our build and at 97.6 pt in the design (the taller iOS 27 bar is accepted).

| State | Item | Before | After | Expected | Result |
|---|---|---|---|---|---|
| P30-S01 | Tools title cap top | +6.3 | 68.7 (+1.0) | 67.7 | Pass |
| P30-S01 | Segment labels cap top | 119.3 (+3.5) | 119.3 (+3.5) | 115.8 | Fail, unchanged |
| P30-S01 | Selector underline | 150.3 (+3.9) | 150.3 (+3.9) | 146.4 | Fail, unchanged |
| P30-S01 | First tile top | 169.7 (+2.7) | 169.7 (+2.7) | 167 | Pass |
| P31-S01 | Row title | 137.0 | 139.7 (+2.7) | 137 | Pass |
| P31-S01 | Title, relative to divider | taller bar | taller bar (accepted) | | Pass |
| P32-S01 | Sunday header, relative to divider | 21.0 | 21.0 | 20.8 | Pass |
| P32-S01 | Banner top, relative to divider | 49.7 | 49.7 | 49.4 | Pass |
| P32-S01 | "Welcome" title, relative to divider | 245.3 | 245.3 | 245.9 | Pass |
| P33-S01 | Progress dashes, relative to divider | 7.7 | 7.7 | 7.8 | Pass |
| P33-S01 | Heading, relative to divider | 34.0 | 34.0 | 33.8 | Pass |
| P33-S01 | Subtitle, relative to divider | 69.7 | 69.7 | 70.4 | Pass |
| P33-S01 | Dots, relative to divider | 575.3 | 575.3 | 575.4 | Pass |
| P33-S01 | Continue, relative to divider | 609.7 | 609.7 | 610.4 | Pass |
| P33-S02 | Field 1 top, relative to divider | 129.5 | 129.5 | 129.4 | Pass |
| P33-S03 | Checkbox, Terms/Privacy, Next, Google, Apple, Phone | inert | no change | inert | Pass |
| P32-S01 | Card tap | inert | no change | inert | Pass |

Not re-measured: colours, and template-card internals on P33-S01.
Regressions: none found.
Remaining mismatches: Tools segment labels +3.5 pt and underline +3.9 pt (outside the ±3 pt tolerance). Fix: reduce the gap above the selector by about 3.5 pt and move the underline up with it.
Counts this round: Pass 16, Fail 2 (segment labels and underline, both in the Tools header).
