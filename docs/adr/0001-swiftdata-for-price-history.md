# 1. SwiftData for local Price History storage

Date: 2026-10-05
Status: Accepted

## Context

The iOS app persists the user's [Price History](../../GLOSSARY.md#price-history) — their saved [Price Observations](../../GLOSSARY.md#price-observation) — locally. The mock [Price API](../../GLOSSARY.md#price-api-mocked) already uses a bundled JSON file (`prices.json`) decoded through a `Codable` + `async` client, with the explicit intent that a React Native/TypeScript port will decode the *same* file through its own client.

The persistence layer is a separate concern from the API layer, and the two don't have to use the same storage mechanism. Three options were on the table:

1. **JSON file in Documents** — symmetrical with `prices.json`; `Codable` + `FileManager`; ~30 lines; same decoding muscle students exercise for the API.
2. **SwiftData** — Apple's current declarative persistence framework; model macros, typed queries, automatic schema; iOS 17+.
3. **UserDefaults** — rejected (wrong tool, wrong lesson).

The symmetry argument favored option 1: one shared mental model ("everything is a Codable array") across read-from-bundle and read-from-disk. The pedagogical argument favored option 2: SwiftData is the current Apple idiom students will encounter in real codebases, and the course has room to teach it as a distinct unit.

## Decision

Use **SwiftData** for Price History. Keep `prices.json` as a bundled `Codable` resource for the mock API — the two layers remain independent.

## Consequences

**Positive**

- Students see a real-world persistence framework rather than a hand-rolled file writer.
- Save-time deduplication (one observation per `(barcode, location, day)`) maps naturally to a SwiftData unique constraint — this is a feature students should know exists.
- Queries for the History view (grouped by item, sorted by date) are declarative via `@Query` / `FetchDescriptor` instead of in-memory filtering.
- Purge-on-launch (observations older than 90 days) is a one-liner against the model context.

**Negative**

- Breaks the "everything is a `Codable` JSON array" symmetry a reader might expect given the mock API design. This ADR exists so that reader isn't left wondering.
- Schema changes carry migration cost; adding/renaming fields on `PriceObservation` is no longer a free edit.
- Introduces iOS 18+ as a minimum deployment target floor — chosen (rather than iOS 17) so we can use the `#Unique` macro for the `(barcode, location, dayKey)` composite uniqueness constraint. On iOS 17 we would have to hand-roll the upsert in `HistoryStore`; on iOS 18 `context.insert(...)` merges into the existing row automatically. The tradeoff is a narrower install base against a cleaner persistence layer and one less piece of bespoke logic for students to read.
- The React Native port cannot reuse this layer; it will need its own equivalent (e.g., AsyncStorage + a thin wrapper, or SQLite via `expo-sqlite`). This is acceptable because the API layer — the actual "process API data" lesson — *is* portable; persistence was never meant to be.
