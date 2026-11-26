# polish-home-cardholder visual and flow check

Simulator: CC Agent Home (C369E26D-A560-47C3-AECE-1C241A4D9917). Build succeeded, app installed and launched with `-uiTestEmptyStore` and `-uiTestSeedCards`.

Measurement method: reference mockups converted with x_pt = (x_px - 8) / 1.537, y_pt = y_px / 1.537 + 3.1 (calibrated on the status-bar clock: reference 26.5 to 37.6 pt, simulator 25.7 to 38.7 pt). Simulator screenshots at 3 px per pt. Tolerance +/-3 pt, colours +/-8 per channel. Reference and simulator values are measured with PIL column scans; values marked "~" are read from the displayed image.

Screenshots: `docs/manual-checks/polish-home-cardholder/` (P00-S01-home-empty.png, P01-S01-cardholder-empty.png, P01-S02-cardholder-seeded.png, P01-S05-search-ortiz.png, P01-S05-search-company-FABRI.png, P01-S06-no-results.png, P01-S04-search-cancel.png, P09-S01-card-detail.png, P31-S01-bell-messages.png, P01-S08-add-menu.png).

Note: the design.md D1 values were not used as the comparison target for pass/fail. The mockup measurements are the authority here. Design.md's own numbers (for example Home bell centre 69, sheet top 247) differ from the same mockup converted with the calibration above (bell 77, sheet 257). Re-check design.md against the mockup before the next pass.

## P00-S01 Home (empty store)

| Item | Expected (reference) | Measured (simulator) | Pass/Fail |
|---|---|---|---|
| Status clock | 26.5 to 37.6 | 25.7 to 38.7 | Pass |
| Bell centre y | 77 (70.1 to 83.8) | 87 (77.3 to 97) | Fail (+10) |
| Promo tile top | 117.0 | 127 | Fail (+10) |
| Promo tile height | 123.6 | ~123 | Pass |
| Sheet top | 256.8 | ~267 to 269 | Fail (+10 to +12) |
| "My Digital Card" centre y | 285.5 | 295.5 | Fail (+10) |
| Empty text line 1 centre y | 563 | 551 | Fail (-12) |
| Empty text line 2 centre y | 581 | 568 | Fail (-13) |
| "Create New Card" button | 614.7 to 661.5 (h 47) | 600.7 to 648.7 (h 48) | Fail (-14) |
| Tab bar top | ~782 | 787 | Fail (+5) |
| Header tint colour | (243,247,248) | (243,247,248) | Pass |
| Sheet colour | white | (255,255,255) | Pass |
| Promo text lines, empty text wrap | 2 lines, "yet." break | 2 lines, same break | Pass |
| Empty illustration | CamCard artwork in reference | SF Symbol, grey | Accepted (not compared) |

## P01-S01 CardHolder (empty)

| Item | Expected (reference) | Measured (simulator) | Pass/Fail |
|---|---|---|---|
| Title "CardHolder" y | 71.4 to 85.7 (centre 78.5) | 77 to 90.3 (centre 83.6) | Fail (+5) |
| Bell | 70.1 to 83.8 | 73.3 to 95.3 | Fail (top +3, glyph larger) |
| Search pill | 117 to 156.6 | 124 to 162 | Fail (+7) |
| Sheet top | 172.9 | 179 | Fail (+6) |
| "Cards" label | 192.4 to 204.1 (centre 198) | centre ~203 | Fail (+5) |
| "No cards" centre y | ~380 | ~413 | Fail (+33) |
| Helper text top | ~403 | ~444 | Fail (+40) |
| Helper text wrap | 3 lines, centred | 3 lines, centred | Pass |
| Header tint and sheet colours | (243,247,248) / white | same | Pass |
| Empty illustration | CamCard artwork | SF Symbol | Accepted |

## CardHolder with seeded cards (no reference)

| Item | Expected | Measured | Pass/Fail |
|---|---|---|---|
| Rows in newest order | Avery Chen, Blair Ortiz, Casey Lund shown | Same three rows | Pass |
| Name and company lines | Name over company, company grey | Same | Pass |
| Thumbnail | Cropped image when stored | Grey placeholder symbol on all rows | Not verified (seed cards have no image; check with an image-bearing seed) |
| Chevron and separators | Present | Present | Pass |

## Flows

| Flow | Result |
|---|---|
| Home tab opens with empty store | Pass |
| CardHolder tab from tab bar | Pass |
| CardHolder bell pushes Messages (P31-S01), no tab bar, back returns | Pass |
| ⊕ opens menu with "Scan card" and "Import from album" | Pass (menu shown; item taps not checked) |
| Search with seeded cards: "ortiz" shows only Blair Ortiz | Pass |
| Search: "FABRI" shows only Casey Lund (company match) | Pass |
| Search: "zzqx" shows "No results" | Pass |
| Search: Cancel restores all three rows | Pass |
| Row tap opens detail; detail shows only filled fields and a back chevron; no edit controls | Pass |
| Home bell, crown, Create New Card, search bar, promo cards | Not run in this pass |
| Empty CardHolder search stays inert | Not run in this pass |
| ⊕ menu items do nothing when tapped | Not run in this pass |

## Mismatches (ranked by visibility)

1. Home header row and sheet sit about 10 pt low. The bell, promo tiles, sheet and "My Digital Card" all share the offset. Fix in `CamCard Copy/Features/Shell/HomeView.swift`: header top padding `.padding(.top, 8)` (line 11) and the `.padding(.top, 23)` at line 9 need a combined reduction of about 10 pt. Re-measure after the change.
2. Home empty block is about 12 to 14 pt high relative to the reference (text and button), so after fix 1 it still needs about +22 pt. Fix in `HomeView.swift` line 167 `.padding(.top, 120)` (verify this is the empty-block spacer), target about 142.
3. CardHolder empty state is about 33 to 40 pt low ("No cards" and helper text). Fix in the CardHolder empty-state spacing (CardHolderView file not located in this pass; reduce the top padding above the empty block by about 33 pt).
4. CardHolder header is 5 to 7 pt low: title +5, search pill +7, sheet +6, "Cards" +5. Fix in `CamCard Copy/Support/Theme/CCComponents.swift` `CCTintedHeaderLayout` or the CardHolder header padding. Re-measure after fix 3 and 4 together.
5. Tab bar top at 787 against about 782 in the reference (+5). `MainTabBar` is frozen. Escalate rather than edit.
6. Bell glyph on CardHolder is about 22 pt tall against about 14 pt in the reference. Likely a symbol size or font difference. Check `CCIconButton` size, with `.font` at 20 pt.
7. Seeded row thumbnails show the placeholder symbol. Verify with a seed that has an image; if the image path is broken, fix the thumbnail helper in `CardHolderRow.swift`.

## Totals

Measured items: 13 pass, 15 fail (Home 4 pass / 7 fail; CardHolder empty 2 pass / 7 fail). Flows: 8 pass, 3 not run from the Home list plus 2 not run on CardHolder.

Nothing committed. No Swift, test or openspec files were edited.


## Fix round 1: before -> after (re-measured by the implementing agent, same method)

Screenshots: `P00-S01-home-empty-fix1.png`, `P01-S01-cardholder-empty-fix1.png`.

| Item | Reference | Before | After | Result |
|---|---|---|---|---|
| Home bell / search / crown / stats centre y | 78 | 87 | 79 | Pass |
| Home bell glyph | 15.6 x 16.3 | 18 x 20 | 14.3 x 16 | Pass |
| Home promo title text top | 189.8 | 200.0 | 190.0 | Pass |
| Home "My Digital Card" text top | 278.3 | 288.3 | 278.3 | Pass |
| Home empty text line 1 / 2 top | 556.1 / 575.0 | 544.7 / 562.7 | 555.7 / 573.7 | Pass |
| Home "Create New Card" text centre | ~638 | 625 | 638 | Pass |
| CardHolder title / bell / plus centre y | 78.5 | 84 | 78.7 | Pass |
| CardHolder bell glyph | 15.6 x 16.3 | 23 x 25 | 15 x 16.3 | Pass |
| CardHolder search pill top | 117 | 124 | 117 | Pass |
| CardHolder "Cards" text top | 192.4 | 197.3 | 192.3 | Pass |
| CardHolder "No cards" top | 374.6 | 406.7 | 373.7 | Pass |
| CardHolder helper text top | 403.9 | 439.3 | 403.3 | Pass |
| Tab bar (+5) | n/a | n/a | frozen, ignored | n/a |
| Seed row thumbnail | n/a | placeholder | seed cards have no image; T24 coverage is the unit test `testDisplayImagePrefersProcessedThenOriginalThenNil` | Not visual |

Flows run on the simulator: Home bell, crown push a page, back returns Home with the tab bar; Home search, stats and both promo cards do nothing; CardHolder tab opens. Empty CardHolder search, the add menu items and Create New Card are asserted by T01, T21 and T24.

## Re-check after fix round 1

Build: commit 1491aee ("Fix round 1 for polish-home-cardholder") on worktree agent-a228e1c7dd094ddca (branch of this change). The coordinator's path agent-acf4a5aa32c919004 is a different branch (add-settings-pages, HEAD 42e58dd), so it was not used. Rebuilt, installed and launched with the same flags. Screenshots: `R1-*.png` in this folder.

### Before/after: Home (P00-S01), pt, reference calibration

| Item | Reference | Before | After | Pass/Fail |
|---|---|---|---|---|
| Bell centre y | 77.0 (70.1 to 83.8) | 87 | 79.2 (71.3 to 87.0) | Pass (+2.2) |
| Promo tile top | 117.0 | 127 | 117.0 | Pass |
| Promo tile bottom | 240.6 | ~250 | 240.0 | Pass |
| Sheet top | 256.8 | ~267 to 269 | 257.0 | Pass |
| "My Digital Card" | 279.6 to 291.3 | 289.3 to 301.7 | 279.3 to 291.7 | Pass |
| Empty text line 1 | 556.1 to 569.8 | 544.7 to 558.0 | 555.7 to 569.0 | Pass |
| Empty text line 2 | 575.0 to 586.1 | 563.0 to 573.7 | 574.0 to 584.7 | Pass |
| Create New Card button | 614.7 to 661.5 | 600.7 to 648.7 | 613.7 to 661.7 | Pass |
| Stats icon y range | 69.5 to 88.3 | 69.3 to 88.3 | 69.3 to 88.3 | Pass (y); x from right edge not re-measured |
| Status clock | 26.5 to 37.6 | 25.7 to 38.7 | unchanged | Pass |

### Before/after: CardHolder empty (P01-S01)

| Item | Reference | Before | After | Pass/Fail |
|---|---|---|---|---|
| Title "CardHolder" | 71.4 to 85.7 | 77 to 90.3 | 72.0 to 85.3 | Pass |
| Bell | 70.1 to 83.8 | 73.3 to 95.3 | 71.0 to 87.3 (centre +2.2) | Pass |
| Search pill | 117 to 156.6 | 124 to 162 | 117 to 155 | Pass |
| Sheet top | 172.9 | 179 | 172 | Pass |
| "Cards" label | 192.4 to 204.1 | centre ~203 | 192.7 to 204.3 | Pass |
| "No cards" | 374.6 to 386.3 | centre ~413 | 373.7 to 385.7 | Pass |
| Helper line 1 | 403.9 to 416.2 | ~444 | 403.3 to 415.0 | Pass |
| Helper line 2 | 420.8 to 432.5 | ~444 to 478 | 419.0 to 430.7 | Pass |
| Helper line 3 | 437.1 to 449.4 | ~444 to 478 | 434.7 to 446.3 | Pass (-2.4) |
| ⊕ right edge (from right) | 26.5 from right | ~27 | 27.3 from right | Pass |

Regressions: none found. Home and CardHolder header, sheet and text positions all now sit within tolerance. Colours were not re-sampled in this round; the screenshots show the same header tint and white sheet.

### Flows (fixed build)

| Flow | Result |
|---|---|
| Home → Create New Card pushes "Create your card" (P33-S01), back returns to Home | Pass |
| `-uiTestEmptyStore`: tap empty CardHolder search does nothing (no keyboard, no field) | Pass |
| `-uiTestEmptyStore`: ⊕ opens menu with "Scan card" and "Import from album"; tapping "Scan card" closes the menu and opens nothing | Pass (only "Scan card" tapped; "Import from album" not tapped) |
| `-uiTestSeedCards`: "ortiz" shows only Blair Ortiz | Pass |
| `-uiTestSeedCards`: "FABRI" shows only Casey Lund | Pass |
| `-uiTestSeedCards`: "zzqx" shows "No results" | Pass |
| `-uiTestSeedCards`: Cancel restores three rows | Pass |
| `-uiTestSeedCards`: tap Avery Chen opens detail; back returns to the list | Pass |

### Remaining mismatches

None above tolerance on the measured items.

Not verified: seeded row thumbnails still show the placeholder symbol, so the cropped-image path is unverified (seed has no image). "Import from album" was not tapped. Header x positions were not re-measured from the right edge, except the ⊕.
