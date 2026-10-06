# Glossary

## Barcode
A UPC/EAN code physically present on a product. **The identity of an Item** — two Price Observations with the same barcode refer to the same product, regardless of how the display name was typed or formatted.

## Item
A product the user can scan. Identified by its [Barcode](#barcode). Carries a mutable display name (e.g., "Charmin Soft 12 Mega Rolls"); the name can change over time without fragmenting the Item's history.

## Scan
The **user action** of pointing the device at a barcode to look up its price. Ephemeral — a scan is not stored. Contrast with [Price Observation](#price-observation), which is the record left behind.

## Price Observation
A stored record that, at a given moment, a specific [Item](#item) was priced at a specific amount at a specific [Location](#location). Shape: `{ barcode, itemName, location, price, date }`. The `itemName` is **snapshotted at save time** — observations are self-contained historical facts and do not re-resolve names through the Price API when displayed. Produced when a [Scan](#scan) resolves against the Price API and the user saves the result. Powers the [Price History](#price-history).

Observations are **deduplicated at save time**: saving the same `(barcode, location, day)` twice overwrites the earlier entry rather than appending. A [Scan](#scan) that returns no price (barcode absent from the Price API) **cannot** produce a Price Observation — the Save action is unavailable in that case.

## Location
A retail **chain** where prices are observed (e.g., "Target", "Giant Eagle"). Specific storefronts (e.g., "Target — Pine Creek Road") are **out of scope**; the wireframe's parenthetical storefront is flavor text only.

## Price API (mocked)
A **fictitious** backend that, given a [Barcode](#barcode), returns the [Item](#item) and its known prices across all [Locations](#location). Response shape:
```json
{ "item": "Charmin Soft 12 Mega Rolls",
  "prices": [ { "location": "Target", "price": 14.79, "date": "..." }, ... ] }
```
Implemented as a shared bundled JSON file (`prices.json` — not the existing `scan_by_location.json`), loaded by each platform's `PriceAPI` client behind an `async` interface. Same data, two language-specific decoders. Swapping to a real HTTP backend is intended to be a one-file change.

## Price History
The user's own saved [Price Observations](#price-observation), kept locally in a **SwiftData** store (iOS) / equivalent (RN). **Purged on app launch**: observations older than **90 days** are deleted. Distinct from the Price API's data, which represents "what the world knows"; Price History represents "what *I* have scanned."

## Current Location
The [Location](#location) the user has selected as the context for scanning. Chosen from a picker whose options are **derived from `prices.json`** (every chain that appears in the data). Scanning resolves prices for this Location.
