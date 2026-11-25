# Manual check: fix-pushed-page-chrome

Date: 2026-11-25. Simulator: iPhone 17 (iOS 27). Done by Opus with a temporary DEBUG scaffold (`-debugPush` pushed `.messages` onto the Home stack). The scaffold was removed before commit.

| Check | Result |
|---|---|
| Pushed page (`CCPlaceholderPage` for P31-S01) has no tab bar | Pass. The bottom 100 pt are all white (`pushed.png`) |
| Back chevron color | Pass. The darkest chevron pixel is `#232323` |
| Divider under the bar | Pass. `#F1F1F1` at y ≈ 116 pt |
| Tapping `nav.back` returns to Home with the tab bar | Pass (`after-back.png`) |

Screenshots: `fix-pushed-page-chrome/pushed.png`, `fix-pushed-page-chrome/after-back.png`.
