# Design

## Context

See proposal.md. `ccPushedNavigationBar` lives in `Support/Theme/CCComponents.swift`; `MainTabBar` is drawn by `RootView` below the selected tab's content, outside every `NavigationStack`, so a pushed view cannot hide it directly.

## Goals / Non-Goals

**Goals:** pushed pages without a tab bar, the measured chevron and divider colors, all done on `main` in shared files before the milestone 2 worktrees exist.

**Non-Goals:** any screen body; scan-flow chrome.

## Decisions

### D1 — Tokens

`CCColor.navInk = #232323`, `CCColor.navDivider = #F1F1F1`, added to the `hex(_:)` table and asserted in `ThemeTests`.

### D2 — Tab bar visibility through an observable counter

New `Support/Theme/TabBarVisibility.swift`: an `@Observable @MainActor final class TabBarVisibility { private(set) var pushedPages = 0; var isHidden: Bool { pushedPages > 0 }; func pageAppeared(); func pageDisappeared() }` (the decrement never goes below 0). `RootView` owns one instance in `@State`, injects it with `.environment(_:)` and renders `MainTabBar` only when `!isHidden`. `ccPushedNavigationBar` reads it from the environment and calls `pageAppeared()` in `.onAppear` and `pageDisappeared()` in `.onDisappear`. A counter, not a Bool, so a page pushed on top of another pushed page does not show the tab bar when the top one is popped.

*Alternative:* a `PreferenceKey` read by `RootView`. Rejected: preferences set inside a `NavigationStack` destination do not reliably reach views outside the stack. *Alternative:* `.toolbar(.hidden, for: .tabBar)`. Not applicable: the tab bar is our own `MainTabBar`, not a system `TabView`.

### D3 — Chevron and divider

The leading `CCIconButton` in `ccPushedNavigationBar` gets a `tint` parameter (default `iconInk`) and is passed `navInk`. The divider is a `Rectangle().fill(CCColor.navDivider).frame(height: 0.5)` placed with `.safeAreaInset(edge: .top, spacing: 0)` on the content so it sits right under the bar.

### D4 — Verification

- Unit: `ThemeTests` (2 new hex values) and new `TabBarVisibilityTests` (appear → hidden; appear twice, disappear once → still hidden; disappear twice → visible; extra disappear never goes negative).
- Simulator: temporarily push a `CCPlaceholderPage` (DEBUG-only scaffold, removed before commit, as in add-visual-foundation task 2.2), screenshot it, confirm no tab bar, the `#232323` chevron by pixel sample and the divider; go back and confirm the tab bar returns. Recorded in `docs/manual-checks/fix-pushed-page-chrome.md`.
- UI: no route is reachable from the UI yet, so the "Pushed pages hide the tab bar" scenario is covered by the milestone 2 changes' UI tests, which each assert `tab.home` is absent on a pushed page and present after `nav.back`.

Unchanged: every screen file, `MainTabBar`, `AppRoute`, all tests except `ThemeTests`.

## Risks / Trade-offs

- [`onDisappear` ordering during an interactive back swipe could briefly show both] → the counter changes only after the transition completes; acceptable visual flicker, checked in the simulator.
- [Card detail (CardHolder push) will also hide the tab bar once polish-home-cardholder adopts the pushed bar] → consistent with every captured pushed page; P09 detail is not captured (ASSUMPTION).

## Migration Plan

UI only. Rollback means reverting the commit.
