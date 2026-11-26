# cardholder-search Specification

## Purpose
Lets a user find a saved card from CardHolder by typing part of its name or company. Covers entering and leaving search, how matching works, and what shows when nothing matches.

## Requirements

### Requirement: Entering and leaving search (P01-S04, ASSUMPTION)

When at least one card is saved, tapping the "Search" capsule on CardHolder SHALL replace it with a focused text field with placeholder "Search" and a "Cancel" button, and the keyboard SHALL appear. Tapping "Cancel" SHALL clear the query, dismiss the keyboard and restore the full list. With no saved cards, the "Search" capsule SHALL stay inert. This screen was not captured, so the layout is ASSUMPTION and marked `TODO(P01-S04)`.

#### Scenario: T15 — Tapping Search with saved cards opens a search field

- **WHEN** the store holds at least one card and the user taps "Search"
- **THEN** a text field with placeholder "Search" has keyboard focus and "Cancel" is visible

#### Scenario: T15 — Cancel restores the full list

- **WHEN** the user has typed a query and taps "Cancel"
- **THEN** the field is gone, the keyboard is dismissed and every saved card row is visible again

#### Scenario: T01 — Empty CardHolder search stays inert

- **WHEN** no cards are saved and the user taps "Search"
- **THEN** no keyboard and no text field appear

### Requirement: Matching on name and company (P01-S05, ASSUMPTION)

While a query is entered, CardHolder SHALL show only the cards whose name or company contains the query, ignoring case and surrounding whitespace. An empty or whitespace-only query SHALL show every card. Matching SHALL use only stored values and SHALL NOT read raw OCR text. Order SHALL stay as in the full list.

#### Scenario: T15 — Part of a name finds the card

- **WHEN** the saved cards are the three seed cards "Avery Chen" (Northwind Labs), "Blair Ortiz" (Contoso) and "Casey Lund" (Fabrikam) and the user types "ortiz"
- **THEN** only the "Blair Ortiz" row is shown

#### Scenario: T15 — Part of a company finds the card

- **WHEN** the user types "FABRI"
- **THEN** only the "Casey Lund" row is shown

#### Scenario: T15 — Whitespace-only query shows everything

- **WHEN** the user types "   "
- **THEN** every saved card row is shown

### Requirement: No results state (P01-S06, ASSUMPTION)

When a non-empty query matches no card, CardHolder SHALL show the text "No results" in place of the list (ASSUMPTION: exact CamCard wording not captured; marked `TODO(P01-S06)`).

#### Scenario: T15 — A query with no match shows "No results"

- **WHEN** the user types "zzqx"
- **THEN** "No results" is visible and no card row is shown
