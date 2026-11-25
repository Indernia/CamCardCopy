# Design

## Context

See proposal.md, Why. Current state:

- `SettingsView` is a `List(.insetGrouped)` with `.navigationTitle("Settings")`: a large system title that collapses on scroll, system grouped colors and default fonts. Only "General" is a `NavigationLink`. Every other row, the sign-in card and the Premium card are inert `Button`s with identifiers (`settings.signIn`, `settings.premium.*`, `settings.row.*`).
- `SettingsGeneralView` is a `List(.insetGrouped)` with disabled toggles bound to `.constant(false)`. T21 drives it through `app.navigationBars["General"]`.
- add-visual-foundation provides `CCColor`, `CCFont`, `CCIconButton`, `ccPushedNavigationBar(title:)`, `CCPlaceholderPage`, `AppRoute.settings(SettingsPage)`, `.login`, `.paywall`, and `settingsDestination(for:)` in `Features/Settings/SettingsRoutes.swift`. `.appRoutes()` is already applied to Settings' `NavigationStack`.
- Every reference screenshot of a pushed page (P11–P21, P31, P33) shows **no tab bar**, but `RootView` always draws `MainTabBar` under the content.
- Shared files (`AppRoute.swift`, `Support/Theme/*`, `MainTabBar`, `RootView`) are frozen in milestone 2. A needed edit goes to Opus on `main` (add-visual-foundation D7).

Measurements: 620 × 1312 px mockups, about 1.54 px per pt, screen area starting about 10 px from the left. Sizes are within about ±1 pt.

## Goals / Non-Goals

**Goals:**

- Settings root and General match P10-S01a/b and P11-S01.
- Each of P12–P21 is an inert visual copy built from the shared tokens, so the Haiku check can compare it against its screenshot.
- Only this change's own files are edited, apart from the one approved prerequisite (D2).

**Non-Goals:**

- Working settings, sign-in, payments, sharing, links or FAQ answers.
- Copying CamCard artwork: the coin, the phone mockup, category icons and brand logos.

## Decisions

### D1 — Measured values

| Element | Value |
|---|---|
| Settings page background | `#FFFFFF`; header "Settings" `CCFont.pageTitle` (24 pt), 16 pt left inset, pinned |
| Sign-in card | `#FAFAFA` (`CCColor.groupedCard`), 16 pt side insets, about 116 pt tall, corner radius 12; title row `row` font centered with chevron; 6 white tiles 41 × 40 pt, corner radius 10 |
| Premium card | `#FEF4D8` (`premiumCard`), about 157 pt tall, radius 12; crown `#DDAA5B`; "Premium" `sectionTitle`; "Upgrade +" capsule on `premiumGradient`, white 16 pt medium; item circles 40 pt on `#FCE8AD`, labels 13 pt |
| Section header | `CCFont.sectionHeader` 14 pt, `#5F5E5E`, 16 pt inset; "APP SETTINGS" and "ABOUT CAMCARD" in capitals, "Help and Feedback" in mixed case |
| Root rows | `#FAFAFA` group, radius 12, rows about 50 pt, title `row` 15 pt `textPrimary`, chevron 13 pt `#A1A1A1`, white 1 pt separators inset 16 pt; about 12 pt between groups |
| Pushed list pages (P11–P14, P18) | page `#F0F0F0` (`groupedBackground`), full-width white rows about 48–50 pt, 1 pt separators inset 16 pt, about 10 pt gap at the top and between sections; values `#A0A0A0` 15 pt; footer text 13 pt `#A0A0A0` |
| Toggle tint | on `#50A6F8` (`accent`), off track `#E9E9EB` |
| Blue text and buttons | links `#50A6F8` (sampled `#4EA6F9`–`#54A9F8`); P16 section titles `#4DADF7` with a 3 pt bar on `#F2F2F2`; "Contact Us" and "Next" capsules filled with `accent`, white 17 pt |
| P15 card | white card on `#F0F0F0`, radius 10, 16 pt insets |
| P16 category icons | `#6F8DA4` SF Symbols `gearshape.fill`, `person.text.rectangle.fill`, `camera.fill` |
| P17 | blue banner `#3A7CF7`; title "Invite Friends" 32 pt bold `#F5E27A`-ish (sampled anti-aliased `#D9D492`, ASSUMPTION ±); white card radius 16; tiles `#FAFAFA`; note box `#E7F4FD` |
| P18 | link color `#6292DC`; version and copyright 13 pt `#9F9F9F` |
| P20 | heading 24 pt `textPrimary`; subtitle 15 pt `#989898`; email box border `#D8D8D8` 1 pt radius 4; social buttons capsule border `#D3D3D3` 1 pt, about 46 pt tall |
| P21 | warm gradient `#FDF5DC` → white; "PRO" `#AF71F1`, "Premium" `#A76B40`; selected tile border `#F1A86E` with badge fill `#F1A86E`; "Continue" capsule `#F8D894` → `#D59137`, white 22 pt semibold |

Implementers may add page-local constants for values that aren't tokens. Shared tokens are used wherever a value matches one.

### D2 — Prerequisite: hide the tab bar on pushed pages (shared files, Opus on `main`)

> **Superseded by the prerequisite change `fix-pushed-page-chrome`** (Opus implements it on `main` before this change starts): `navInk` #232323, `navDivider` #F1F1F1, and tab-bar hiding through an observable `TabBarVisibility` counter that `ccPushedNavigationBar` updates. This change depends on it and must not edit those shared files. The text below is kept as the original finding.

Every pushed reference screen lacks the tab bar. This is a shared behavior, so it belongs in the shared files:

- `CCComponents.swift`: add a `CCHidesTabBarKey: PreferenceKey` (Bool, reduced with `||`). Make `ccPushedNavigationBar(title:)` set it to `true`. Add a public `View.ccHidesTabBar()` for pages that don't use the shared bar.
- `RootView.swift`: read the preference with `.onPreferenceChange` and draw `MainTabBar` only when it is `false`.

Opus makes this edit on `main` and runs T01, T02, T21 and T22 before the worktree for this change is created. This change then just uses `ccPushedNavigationBar`.

*Fallback if preferences don't propagate out of `NavigationStack` destinations on iOS 27:* an `@Observable TabBarVisibility` in the environment, toggled in `onAppear`/`onDisappear` by the same modifier. Opus picks one while making the prerequisite; this change doesn't depend on which.

*Alternative:* each page calls a Settings-local hack. Rejected because Messages and Create Card need the same behavior.

### D3 — Settings root layout

Replace the `List` with `VStack(spacing: 0) { header; ScrollView { cards and groups } }` inside the existing `NavigationStack`, with `.toolbar(.hidden, for: .navigationBar)` on the root. The header (`Text("Settings")`, `pageTitle`) stays pinned, as in P10-S01b. Groups are a small local `SettingsGroup` view (rounded `#FAFAFA` container with separators), not `List` sections. That's needed to hit the measured colors and heights.

Rows become `NavigationLink(value: AppRoute.…)`, except:

- General stays a `NavigationLink { SettingsGeneralView() }`. There's no route for it, and add-visual-foundation's `AppRoute` is frozen.
- "Resume In-APP Purchases" stays an inert `Button`.

All existing identifiers are kept. Each row keeps `.accessibilityIdentifier` on the link.

*Alternative:* keep `List(.insetGrouped)` and restyle it. Rejected: you can't remove the system section spacing and large-title behavior precisely enough to match.

### D4 — What "inert" means for controls (DECIDED 2026-11-25)

- **Toggles** (P11, P13, P14): show the observed state through `.constant(<observed>)` and are **not** `.disabled`. Disabling them dims the knob and breaks the visual match. A constant binding doesn't move when tapped. This matches how General's existing T21 test checks toggles ("The toggle must not change"). General's two toggles currently use `.disabled(true)` and change to the same approach, so the dimmed look goes away.
- **Login email box** (P20): a `TextField` with the placeholder in `#C4C4C4`. It accepts typing in local `@State` that is never saved, the same rule as Create your card step 2 (DECIDED at approval, 2026-11-25). "Next" and every sign-in button stay inert.
- **Plan tiles, tabs, check marks and the agree box**: fixed at the observed state, and taps do nothing.

**DECIDED at approval (2026-11-25):** toggles as above; form fields accept typing and save nothing.

### D5 — Files and identifiers

New files in `CamCard Copy/Features/Settings/`:

| File | Page | Root identifier |
|---|---|---|
| `SettingsLanguageView.swift` | P12 | `settings.page.language` |
| `SettingsNotificationsView.swift` | P13 | `settings.page.notifications` |
| `SettingsPrivacyView.swift` | P14 | `settings.page.privacy` |
| `SettingsPermissionsView.swift` | P15 | `settings.page.permissions` |
| `SettingsHelpFeedbackView.swift` | P16 | `settings.page.helpFeedback` |
| `SettingsInviteFriendsView.swift` | P17 | `settings.page.inviteFriends` |
| `SettingsAboutView.swift` | P18 | `settings.page.about` |
| `SettingsPIChecklistView.swift` | P19 | `settings.page.piChecklist` |
| `LoginEmailView.swift` | P20 | `settings.page.login` |
| `UpgradePlansView.swift` | P21 | `settings.page.paywall` |
| `SettingsPageComponents.swift` | shared within Settings: `SettingsGroup`, white list row, value row, footer text, toggle row | — |

Rules:

- `SettingsRoutes.swift` switches on the route and returns these views. `.settings(.accountSync)` keeps `CCPlaceholderPage`.
- Each view carries a `TODO(P##-S##)` comment where a control is inert.
- Each page uses `ccPushedNavigationBar(title:)`:
  - P17 uses "Recommend CamCard" and P19 uses "CamCard App Collect personal information list", their observed titles rather than the row names.
  - P20 passes `""` (empty bar).
  - P21 is the exception: its title is bold over a gradient, so it uses `ccPushedNavigationBar(title: "")`, its own centered "Upgrade Plans" text in 17 pt semibold, and `.toolbarBackground(.hidden)`.
- Identifiers go on the page's root container with `.accessibilityElement(children: .contain)`, as `CCPlaceholderPage` does.

`SettingsView.swift` and `SettingsGeneralView.swift` are rewritten in place. General keeps `.navigationTitle("General")` alongside `ccPushedNavigationBar(title: "General")`, so `app.navigationBars["General"]` still resolves in T21.

Interfaces that stay unchanged: `AppRoute`, `SettingsPage`, `settingsDestination(for:)`'s signature, every existing `settings.*` identifier, and `SettingsGeneralView`'s identifiers.

### D6 — Version, legal and brand text on About (DECIDED 2026-11-25)

P18 shows "CamCard 8.65.0.2610161713", "CamCardTerms of Service and CamCardPrivacy Policy" and "© 2009-2026 IntSig. All Rights Reserved."

**Recommendation:** keep the layout but show our app's own version from the bundle (`CamCard Copy <CFBundleShortVersionString>`). Keep the two link labels as inert text, and **omit the IntSig copyright line**, replacing it with an empty line of the same height. Putting a real company's copyright notice in our app would misattribute it.

The alternative is verbatim text, which is what the "quote exact UI text" rule implies. **DECIDED at approval (2026-11-25): our own version, no IntSig copyright line.**

The same applies to the sign-in tiles and P20's "Sign in with Apple". `apple.logo` is an SF Symbol, so it's allowed by the artwork rule. Google, LinkedIn and Facebook stay as the letters "G", "in" and "f", as today.

### D7 — Artwork stand-ins

- P17 coin: `crown.fill` in `#F4BA47` inside a 96 pt circle of `#FCE8AD`.
- P17 share icons: `f` letter, `ellipsis.message.fill` and `envelope.fill` in 44 pt white circles.
- P21 phone mockup and card image: a rounded `#2B2B2B` rectangle, 150 × 300 pt, with a white inner card shape. Its 4 page dots are static.
- Premium item icons: SF Symbols (`viewfinder`, `icloud`, `tablecells`, `person.crop.circle.badge.clock`) in `#EF8C44`.

### D8 — Tests

- **T25 `T25SettingsPagesUITests.swift` (new):**
  - Opens each row and checks its page identifier and its key texts from the settings-pages scenarios. Then it taps one control per page and asserts nothing opened (no `sheets`, no `alerts`, toggle `value` unchanged; no keyboard except on the Login email box). Then it taps `nav.back` and asserts the Settings root with `tab.settings` visible.
  - Sign-in leads to Login, and Upgrade plus the 4 Premium items lead to Upgrade Plans.
  - The tab bar is hidden on a pushed page: `tab.settings` doesn't exist while Language setting is open.
- **T21 and T22:** edited exactly as listed in proposal.md, "Tests that change", and nothing else.
- **Visual check (Haiku, per screen):** screenshot each page on the agent's simulator and compare it with its reference: colors sampled with PIL, text present, row heights about ±2 pt, tab bar hidden. P10 is checked at both scroll positions. Results go in `docs/manual-checks/add-settings-pages.md`.
- **Flow check (Haiku):** following `reference/state-diagram.md`'s navigation shell, open each P10 → P11–P20 edge and come back, plus Upgrade → P21 (ASSUMPTION edge).

## Risks / Trade-offs

- [The D2 prerequisite may not propagate the preference through `NavigationStack`] → Opus verifies it on `main` before this change starts, using the environment fallback if needed.
- [Merge conflict in `T22VisualFoundationUITests.testT22InertControlsStayInert`, which `polish-home-cardholder` and `add-tools-messages-digital-card` also edit] → This change deletes only the Language block, the last lines of the function. Opus merges the three branches one at a time and resolves conflicts there.
- [A pinned header plus `ScrollView` loses the system's scroll-edge effects] → Matches P10-S01b, which shows a static header.
- [Long verbatim texts (FAQ, P17 fine print, P19 table) can drift from the screenshot] → T25 asserts the key texts, and the Haiku check compares the rest.
- [Constant-binding toggles still animate a little when tapped] → Accepted. The value never changes.

## Migration Plan

UI only. No data migration. Rollback means reverting the merge commit.

## Open Questions

None. D4 and D6 were decided at approval on 2026-11-25.
