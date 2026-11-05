# CamCard observations

Reference environment: see `environment.md`. Navigation flow: see `state-diagram.md`.

## ID convention

`P##-S##` = page, state on that page. The same ID is used in the screenshot filename, the state diagram, spec scenarios and test names.

- P00–P09: core slice (Home shell, CardHolder, scan flow, card management)
- P10–P21: Settings, login, paywall
- P30–P33: Tools, Messages, digital card creation

Scope values: **In** = must replicate; **Partial** = replicate the listed part only; **Reference** = not built, but its settings or behavior affect in-scope features; **Out** = not replicated.

## Captured states

| ID | Screenshot file | Source capture (2026-11-05) | State | Scope |
|---|---|---|---|---|
| P00-S01 | P00-S01_home-empty.png | 11.17.57 | Home tab, logged out, no digital card. Search bar "Search Card Holder", bell, crown, stats icon. Tab bar: Home, CardHolder, center scan button, Tools, Settings | Partial: tab bar, scan button, search entry |
| P01-S01 | P01-S01_cardholder-empty.png | 11.18.03 | CardHolder tab, empty. Title "CardHolder", search bar "Search", section "Cards", "No cards", helper text "You can use the business card recognition function to upload business cards and efficiently manage your contacts", ⊕ top right | In (T01) |
| P02-S01 | P02-S01_camera-basic-single.png | 11.23.06 | Camera, Basic mode, Single selected. Modes: Batch, Multiple, Single, QR Code. Close (X), ••• menu, card frame, "Tap to light up", Album, shutter, counter "5" | In (T02, T04) |
| P02-S02 | P02-S02_camera-high-accuracy.png | 11.23.02 | Camera, High Accuracy mode. Hint "Please move lens closer to card". Only Batch and Single offered | Partial: hint text; High Accuracy mode likely premium |
| P03-S01 | P03-S01_album-limited-access.png | 11.23.19 | Album picker with limited photo access. Banner "You did not allow Camcard to access all the pictures in the album,So only show the pictures you selected." Buttons "Select more photos", "Allow access to all pictures". Empty Recents, Cancel, Done disabled | In (T05) |
| P03-S02 | P03-S02_album-list.png | 11.23.25 | Album list: Recents plus one unnamed album, Cancel | In (T05) |
| P04-S01 | P04-S01_alert-card-not-found.png | 11.23.37 | Alert after capture: title "Card area not found", message "Move phone closer and rescan", buttons "Continue saving" / "Cancel saving". Camera controls hidden, shutter greyed | In (T06, T20) |
| P05-S01 | P05-S01_edit-card-empty.png | 11.23.44 | Edit Card after "Continue saving" with nothing recognized. Nav: "Retake" / "Edit Card" / "Save". Card image with crop button. "High Accuracy" toggle ("Save and Submit for High Accuracy Recognition"), "Recognition Languages" English + "Change", "Full Name" (empty), "Edit More Info", "Add Backside", "Cards autosaved to Contacts" Off, "Improve Recognition" | In (T08, T09, T11) |
| P06-S01 | P06-S01_card-saved.png | 11.24.08 | "Card Saved" with Done. Card thumbnail, actions Group, Note, Sync (premium), Export (premium), "Take the next". CC AI assistant panel below | Partial: AI assistant out |
| P07-S01 | P07-S01_add-to-group.png | 11.24.17 | "Add to group": Cancel / Confirm, search "Enter group name", "New a Group", "Ungrouped" checked, suggestions VIP, Customer, Supplier, Partner, Industry Peer. Toggle "Show group settings when saving cards" (on) with tooltip | In (T16) |
| P08-S01 | P08-S01_note.png | 11.24.22 | "Note": auto entry "Card Saved 2026-11-05 11:23", "From: Taking photo". Button "Create new memo" | In (notes) |
| P10-S01 | P10-S01a_settings-top.png, P10-S01b_settings-scrolled.png | 11.18.12, 11.18.20 | Settings root, logged out (two scroll positions) | Out |
| P11-S01 | P11-S01_settings-general.png | 11.18.31 | Settings › General: New cards autosaved to Contacts Off, Font Size, Recognition Languages, Show group settings when saving cards (off), Save Card Image (off), Sort Order "First, Last", Display Order "First, Last", Clear your space, App Lock | Reference |
| P12-S01 | P12-S01_settings-language.png | 11.18.36 | Language setting, System Default checked | Reference |
| P13-S01 | P13-S01_settings-notifications.png | 11.18.40 | Notifications, disabled at system level | Out |
| P14-S01 | P14-S01_settings-privacy.png | 11.18.47 | Privacy Settings, AI Data Processing Consent off | Reference |
| P15-S01 | P15-S01_settings-permissions.png | 11.18.52 | System permissions (ad tracking) | Out |
| P16-S01 | P16-S01_help-feedback.png | 11.19.01 | Help and Feedback | Out |
| P17-S01 | P17-S01_invite-friends.png | 11.19.07 | Recommend CamCard / invite friends | Out |
| P18-S01 | P18-S01_about.png | 11.19.11 | About, CamCard 8.65.0.2610161713 | Reference |
| P19-S01 | P19-S01_pi-checklist.png | 11.19.16 | Personal information collection checklist | Out |
| P20-S01 | P20-S01_login-email.png | 11.18.26 | Login via email | Out |
| P21-S01 | P21-S01_upgrade-paywall.png | 11.24.28 | Upgrade Plans paywall (from Sync / Export) | Out |
| P30-S01 | P30-S01_tools-recommend.png | 11.18.08 | Tools › Recommend | Out |
| P30-S02 | P30-S02_tools-smart-sync.png | 11.19.22 | Tools › Smart sync: Save to Contacts, Contacts Backup, Salesforce, Google Contacts, Outlook/Office365, Export to Excel/Vcf | Reference (T19) |
| P31-S01 | P31-S01_messages.png | 11.19.41 | Messages (from bell) | Out |
| P32-S01 | P32-S01_biz-tips.png | 11.19.44 | Biz Tips | Out |
| P33-S01 | P33-S01_create-digital-card.png | 11.19.53 | Create your card, step 1 template | Out |
| P33-S02 | P33-S02_create-digital-card-info.png | 11.19.58 | Create your card, step 2 fields + "Scan paper cards" | Out |
| P33-S03 | P33-S03_create-digital-card-signin.png | 11.22.00 | Create your card, step 3 sign in | Out |

## Missing states (not yet captured)

Not observed yet. Any spec based on these rows must mark its behavior as ASSUMPTION until a screenshot exists.

| ID | Planned file | Expected state | How to reach | Test |
|---|---|---|---|---|
| P00-S02 | P00-S02_home-after-save.png | Home after first save (does anything change?) | Done on P06, Home tab | T12 |
| P00-S03 | P00-S03_home-search.png | Search from Home | Tap Home search | T15 |
| P01-S02 | P01-S02_cardholder-one-card.png | List with one card, summary row content | Save first card | T12 |
| P01-S03 | P01-S03_cardholder-many.png | Several cards, sort order, section headers | Save 3+ cards | T12, T18 |
| P01-S04 | P01-S04_search-active.png | Search focused | Tap search | T15 |
| P01-S05 | P01-S05_search-results.png | Results for name/company query | Type part of a name | T15 |
| P01-S06 | P01-S06_search-no-results.png | No results message | Nonsense query | T15, T20 |
| P01-S07 | P01-S07_filtered-by-group.png | List filtered by group | Select a group | T16 |
| P01-S08 | P01-S08_plus-menu.png | What ⊕ opens | Tap ⊕ | — |
| P01-S09 | P01-S09_group-list.png | Group list / management | Group entry in CardHolder | T16 |
| P01-S10 | P01-S10_delete-group-confirm.png | Delete group confirmation | Delete a group | T16 |
| P01-S11 | P01-S11_select-mode.png | Multi-select / manage mode | Long-press or Manage | T17 |
| P02-S03 | P02-S03_camera-permission-prompt.png | System camera prompt and usage text | Reset privacy, tap scan | T03 |
| P02-S04 | P02-S04_camera-denied.png | Camera denied state | Deny prompt | T03, T20 |
| P02-S05 | P02-S05_card-detected.png | Live boundary overlay, auto-capture | Point at a card | T04, T06 |
| P02-S06 | P02-S06_more-menu.png | ••• menu | Tap ••• | — |
| P03-S03 | P03-S03_photo-permission-prompt.png | System photo prompt | Reset privacy, tap Album | T05 |
| P03-S04 | P03-S04_photo-denied.png | Photo access denied | Don't Allow | T05, T20 |
| P03-S05 | P03-S05_album-grid.png | Full-access grid | Allow full access | T05 |
| P03-S06 | P03-S06_album-selected.png | Image selected | Tap a photo | T05 |
| P04-S02 | P04-S02_recognizing.png | Recognition progress | Capture a real card | T07 |
| P04-S03 | P04-S03_recognition-failed.png | Recognition failure (e.g. offline) | Airplane mode, capture | T20 |
| P04-S04 | P04-S04_cancel-saving-result.png | Where "Cancel saving" lands | Tap Cancel saving | T20 |
| P05-S02 | P05-S02_edit-card-recognized.png | Edit Card with recognized fields | Scan a synthetic card | T07, T08 |
| P05-S03 | P05-S03_edit-field.png | Editing one field | Tap Full Name | T11 |
| P05-S04 | P05-S04_edit-more-info.png | Edit More Info field types | Tap Edit More Info | T08 |
| P05-S05 | P05-S05_multiple-phones.png | Mobile, office, fax, multiple emails | Scan multi-phone card | T10 |
| P05-S06 | P05-S06_crop-adjust.png | Manual crop / rotate | Tap crop button | T06 |
| P05-S07 | P05-S07_change-language.png | Recognition language picker | Tap Change | T07 |
| P05-S08 | P05-S08_retake-confirm.png | Discard confirmation on Retake | Edit, then Retake | T20 |
| P05-S09 | P05-S09_save-empty.png | Saving with all fields empty | Save on P05-S01 | T20 |
| P05-S10 | P05-S10_add-backside.png | Add Backside flow | Tap Add Backside | — |
| P06-S02 | P06-S02_card-saved-recognized.png | Card Saved with a real card | Save P05-S02 | T12 |
| P07-S02 | P07-S02_new-group-dialog.png | New group input | Tap New a Group | T16 |
| P07-S03 | P07-S03_group-selected.png | Group checked | Pick a group | T16 |
| P08-S02 | P08-S02_new-memo.png | Memo editor | Create new memo | Notes |
| P08-S03 | P08-S03_note-with-memo.png | Timeline with user memo | Save a memo | Notes, T18 |
| P09-S01 | P09-S01_card-detail.png | Card detail | Tap a card | T13 |
| P09-S02 | P09-S02_card-edit.png | Edit mode | Edit on detail | T14 |
| P09-S03 | P09-S03_original-image.png | Full-screen card image | Tap image | T13 |
| P09-S04 | P09-S04_more-menu.png | Detail ••• menu | Tap ••• | — |
| P09-S05 | P09-S05_delete-confirm.png | Delete confirmation | Delete | T17 |
| P09-S06 | P09-S06_tap-phone.png | Phone tap action | Tap phone | T13 |
| P09-S07 | P09-S07_tap-email.png | Email tap action | Tap email | T13 |
| P09-S08 | P09-S08_tap-website.png | Website tap action | Tap website | T13 |
| P09-S09 | P09-S09_save-to-contacts.png | Save to Contacts | Export from detail | T19 |
| P09-S10 | P09-S10_share-vcard.png | Share / vCard | Share from detail | T19 |
| P30-S03 | P30-S03_smart-sync-contacts.png | Tools › Save to Contacts (free or paywalled?) | Tap tile | T19 |

## Behavioral findings

- No preview/confirm screen after capture. Flow is capture → ("Card area not found" alert if detection fails) → Edit Card. Retake lives on Edit Card. This differs from the assignment's generic "preview → confirm" wording.
- Edit Card (P05) is the human verification screen. With nothing recognized, Full Name stays empty: no fabricated values.
- CamCard calls tags "Groups". Default is "Ungrouped", preselected. Group picker can appear after save.
- Notes are a timeline of timestamped entries. Saving a card auto-creates "Card Saved <date time>" with source "From: Taking photo".
- Sync and Export from Card Saved lead to the paywall. Free export path not yet found (check P09, P30-S03).
- "Show group settings when saving cards" was off in P11-S01 but on in P07-S01. Recheck which is the default.
- Camera counter "5" is probably the remaining High Accuracy quota. Unconfirmed.

## Open questions

- Is any export path free? If not, ask the instructor how T19 should be evaluated.
- Does recognition depend on the AI Data Processing Consent toggle (P14-S01)?
- Is matching CamCard's capture flow (no confirm step) preferred over the assignment's generic wording?
