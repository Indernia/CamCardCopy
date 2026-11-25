# Spec Delta

## Purpose

Defines the inert visual copies of the screens opened from Settings (P12–P21 and the uncaptured Account and Sync), what each one shows, that none of them performs a real action, and how the user gets back to Settings.

## ADDED Requirements

### Requirement: Settings pages are inert visual copies

Every page opened from Settings SHALL show the observed text and layout of its screenshot. It SHALL NOT sign in, register, purchase, restore purchases, share, rate, open links, change system settings or use the network. Toggles SHALL show their observed state and SHALL NOT change when tapped. Tappable-looking rows and buttons SHALL open nothing. Each page SHALL show the plain "‹" back control, which returns to Settings, and SHALL hide the tab bar.

#### Scenario: T25 — Controls on Settings pages do nothing

- **WHEN** the user taps any row, button, link or toggle on a Settings page other than "‹"
- **THEN** no new screen, sheet, alert, keyboard or system prompt appears
- **AND** every toggle keeps its observed state

#### Scenario: T25 — Back returns to Settings

- **WHEN** the user taps "‹" on any Settings page
- **THEN** the Settings root is shown and the tab bar is visible again

### Requirement: Language setting page (P12-S01)

The page SHALL be titled "Language setting" and list "System Default", "Simplified Chinese", "Traditional Chinese", "English", "Japanese" and "Korean", with a check mark on "System Default" only.

#### Scenario: T25 — Language setting shows the observed languages

- **WHEN** the user opens "Language setting"
- **THEN** the six languages are shown in that order and only "System Default" is checked
- **WHEN** the user taps "English"
- **THEN** the check mark stays on "System Default"

### Requirement: Notifications page (P13-S01)

The page SHALL be titled "Notifications" and show "Receive notifications" with the value "Disabled", the footer "Enable CamCard notifications via iPhone's Settings-> Notifications -> CamCard", and the toggles "Sound" and "Vibrate", both on.

#### Scenario: T25 — Notifications shows the observed rows

- **WHEN** the user opens "Notifications"
- **THEN** "Receive notifications", "Disabled", the footer text, "Sound" (on) and "Vibrate" (on) are shown

### Requirement: Privacy Settings page (P14-S01)

The page SHALL be titled "Privacy Settings" and show "AI Data Processing Consent" with a toggle off, and the footer "For information about CamCard's third-party AI services, tap Third Party List."

#### Scenario: T25 — Privacy Settings shows the consent toggle off

- **WHEN** the user opens "Privacy Settings"
- **THEN** "AI Data Processing Consent" is shown with its toggle off, plus the footer text

### Requirement: System permissions page (P15-S01)

The page SHALL be titled "System permissions" and show one card with "Ad tracking permission", the description "Personalized ads, cross-app tracking, attribution, ad fraud prevention" and a "Settings" link with a chevron. The link SHALL NOT open the iOS Settings app.

#### Scenario: T25 — System permissions shows the ad tracking card

- **WHEN** the user opens "System permissions"
- **THEN** "Ad tracking permission", its description and "Settings" are shown

### Requirement: Help and Feedback page (P16-S01)

The page SHALL be titled "Help and Feedback" and show the following:

- The section "Most Asked Questions" with the nine questions "How to redeem premium code?", "How to reset my login password?", "How to set the recognition languages?", "How can I get the support if I have problems or questions?", "How to add cards to phone contacts?", "How to sync cards on the phone to CamCard cloud?", "My phone has connected with WiFi. Why I got the message ”Sync failed”?", "How to continue the paid version if I changed my phone?" and "How to transfer my cards to my new phone?".
- The section "Question Categories" with "Account Setting", "CardHolder" and "Scan".
- A "Contact Us" button pinned at the bottom.

#### Scenario: T25 — Help and Feedback shows the observed questions

- **WHEN** the user opens "Help and Feedback"
- **THEN** both section titles, all nine questions, the three categories and "Contact Us" are shown

### Requirement: Recommend CamCard page (P17-S01)

Opening "Recommend to Friends" SHALL show a page titled "Recommend CamCard" with:

- The banner "Invite Friends" and the text "Invite friends & get up to 12 months Premium membership".
- A card reading "Get a 15-day Premium membership after new user register, up to a maximum of 12 months." with four tiles "15 days", "30 days", "180 days" and "360 days", and the progress labels "invited 1", "invited 2", "invited 12" and "invited 24".
- The note "You haven't invited friends yet. Don't miss out on free membership!".
- The fine print "The registration of the same device, the same mobile phone number or the same email address is regarded as a reward. CamCard reserves the right to interpret this event."
- The share buttons "facebook", "sms" and "email".

No invitation SHALL be sent.

#### Scenario: T25 — Recommend CamCard shows the observed invitation layout

- **WHEN** the user opens "Recommend to Friends"
- **THEN** the title "Recommend CamCard", "Invite Friends", the four day tiles, the four invited labels and the three share buttons are shown
- **WHEN** the user taps "email"
- **THEN** no mail composer or share sheet appears

### Requirement: About page (P18-S01)

The page SHALL be titled "About" and show the rows "Rate It Now", "Follow us" and "Contact Us", followed by the version, terms and copyright lines described in design D6.

#### Scenario: T25 — About shows the observed rows

- **WHEN** the user opens "About"
- **THEN** "Rate It Now", "Follow us" and "Contact Us" are shown above the version and legal lines

### Requirement: Personal information collection checklist page (P19-S01)

Opening "Personal Information Collection Checklist" SHALL show a page whose bar title reads "CamCard App Collect personal information list" (truncated by the bar as observed). The page shows a bordered table titled "CamCard App Collect personal information list" with the columns "Scenario/Business Function", "Types of personal information" and "Objective". The table holds the observed rows "Registration and login", "Third party account login", "One click login", "Business card scanning, storage, reading, and management", "OCR recognition" and "Address book import Network analysis", each with its observed cell text. Rows below the captured area are not shown (ASSUMPTION: not captured; marked `TODO(P19-S01)`).

#### Scenario: T25 — The checklist shows the observed table

- **WHEN** the user opens "Personal Information Collection Checklist"
- **THEN** the table title, the three column headers and the six observed row titles are shown

### Requirement: Login via email page (P20-S01)

Opening "Sign in to access more features" SHALL show a page with:

- An empty bar except "‹".
- The heading "Login via email" and the text "The Unregistered mailbox will be automatically registered".
- An email box with the placeholder "Please enter email".
- An unchecked box with "Agree to Terms of Service and Privacy Policy".
- A "Next" button.
- The divider "Or continue with".
- The buttons "Sign in with phone", "Sign in with Facebook", "Sign in with Linkedin", "Sign in with Google" and "Sign in with Apple".

The email box SHALL accept typing that is never saved (design D4). No button SHALL sign in.

#### Scenario: T25 — Login via email shows the observed form and signs in nothing

- **WHEN** the user opens "Login via email"
- **THEN** all texts above are shown
- **WHEN** the user taps the agree box, "Next" or any "Sign in with" button
- **THEN** no check mark change, screen or system sign-in prompt appears

#### Scenario: T25 — The email box accepts typing that is never saved

- **WHEN** the user types into the email box, leaves the page and opens "Login via email" again
- **THEN** the email box is empty and shows "Please enter email"

### Requirement: Upgrade Plans page (P21-S01)

Opening Upgrade Plans SHALL show a page titled "Upgrade Plans" on a warm gradient with:

- The heading "Business Card Scanner" and the text "Unlimited paper business card transcriptions".
- The tabs "PRO" and "Premium", with "Premium" selected.
- Three plan tiles: "1 Month" ($9.99/mo, $9.99), "12 Months" ($4.17/mo, $49.99, badge "3-day Free Trial", selected) and "36 Months" ($3.05/mo, $109.99).
- The text "Free for 3 days,then $49.99 per year.Cancel anytime.".
- A feature table starting with "Feature", "Pro", "Premium", "AI Scanner" and "Business Card Scanner" / "Unlimited".
- A pinned "Continue" button.

No purchase, trial or App Store prompt SHALL start.

#### Scenario: T25 — Upgrade Plans shows the observed plans and buys nothing

- **WHEN** Upgrade Plans is shown
- **THEN** the heading, both tabs, the three plans with their prices, the trial badge, the trial text and "Continue" are shown
- **WHEN** the user taps a plan, "PRO" or "Continue"
- **THEN** the selection does not change and no purchase or App Store sheet appears

### Requirement: Account and Sync placeholder

"Account and Sync" was not captured. It SHALL open the barebones "Not built yet" page titled "Account and Sync", which carries `TODO(P10-S01)`.

#### Scenario: T25 — Account and Sync opens the barebones page

- **WHEN** the user taps "Account and Sync"
- **THEN** a page titled "Account and Sync" shows "Not built yet"
