# PriceCheck — iOS Implementation Plan

**Baseline**: new Xcode project, iOS 18+, SwiftUI, SwiftData, no external packages.

Each step is sized so you can see it working before moving on. `verify` is the signal that step is done.

---

## 1. Project scaffold

Create `PriceCheck` app target. Add `prices.json` to the bundle (Build Phases → Copy Bundle Resources).

**verify**: app launches to a blank `ContentView`; `Bundle.main.url(forResource: "prices.json", ...)` returns non-nil in a quick print.

## 2. API-shape types (`APITypes.swift`)

`Codable` structs mirroring `prices.json`:

- `APIItem { barcode, item, prices: [APIPrice] }`
- `APIPrice { location, price, daysAgo }`

Plus a view type `PriceLookup { barcode, itemName, price, location, date }` returned by the API client (the shape the UI actually consumes).

**verify**: unit test decodes the bundled JSON into `[APIItem]` without error.

## 3. `PriceAPI` protocol + `MockPriceAPI` (`PriceAPI.swift`)

```swift
protocol PriceAPI {
    func lookup(barcode: String, at location: String) async throws -> PriceLookup?
    func allBarcodes() async throws -> [(barcode: String, item: String)]
    func knownLocations() async throws -> [String]
}
```

`MockPriceAPI` loads `prices.json` once (cached), computes dates as `Date.now - daysAgo`, resolves barcodes and locations from the decoded data. Returns `nil` for unknown barcode or no price at the requested location.

**verify**: tests cover (a) known barcode + known location → price, (b) known barcode + absent location → `nil`, (c) unknown barcode → `nil`, (d) `knownLocations()` returns sorted unique chains.

## 4. `PriceObservation` SwiftData model (`PriceObservation.swift`)

`@Model` with `barcode`, `itemName`, `location`, `price`, `date`, and `dayKey` (stored `yyyy-MM-dd` string set at save time). Composite uniqueness via `#Unique<PriceObservation>([\.barcode, \.location, \.dayKey])` (iOS 18+) so `context.insert(...)` with a matching key upserts rather than appends.

**verify (step 4)**: in-memory round-trip + `dayKey` formatting + convenience init from `PriceLookup`. The upsert-leaves-one-row behavior is verified in step 5 where the save path lives.

## 5. Launch-time purge (`HistoryStore.swift`)

Thin wrapper around the model context: `save(_ lookup:)`, `purgeOlderThan(days: 90)`, `allObservations()`. Call `purgeOlderThan(90)` from the app's `init` or the root view's `.task`.

**verify**: seed one 100-day-old and one 5-day-old observation; after launch only the recent one remains.

## 6. `LocationStore` observable (`LocationStore.swift`)

`@Observable` holding `current: String` and `all: [String]`. Populated from `PriceAPI.knownLocations()` on launch; default `current` = `all.first` (alphabetical). Persisted across launches via `@AppStorage`-backed property.

**verify**: changing `current` propagates to a label in a scratch view and survives relaunch.

## 7. `Theme.swift` — design system foundation

Centralizes the look so view code stays free of ad-hoc colors, paddings, and corner radii. Goals: modern, calm, high-contrast, dark-mode-correct, built from SwiftUI primitives (no third-party UI kits).

Contents:

- **`extension Color`** — semantic palette, each resolved from an asset catalog color set with light/dark variants:
  - `brand`, `brandMuted`, `accent`, `surface`, `surfaceElevated`, `onSurface`, `onSurfaceMuted`, `danger`, `success`, `divider`.
- **`extension LinearGradient`** — reusable gradients:
  - `brandGradient` (brand → accent, diagonal) for primary CTAs and the Home hero.
  - `surfaceGradient` (surface → surfaceElevated) for subtle card backgrounds.
- **`extension ShapeStyle`** / radii constants — `AppRadius.small/medium/large/pill` and `AppSpacing.xs/sm/md/lg/xl` so spacing is consistent.
- **`PrimaryButtonStyle: ButtonStyle`** — gradient fill, white label, large tap target, press-state scale + opacity.
- **`SecondaryButtonStyle: ButtonStyle`** — surface fill, brand label, 1pt stroke.
- **`DestructiveButtonStyle: ButtonStyle`** — danger fill variant (reserved; not used in v1 flow).
- **`Card<Content>: View`** — padded, rounded, surface-elevated container with a soft shadow for grouping content on screens.
- **`LocationBadge: View`** — pill-style chip showing current location with the SF Symbol `mappin.and.ellipse`.
- **`PriceTag: View`** — large money display formatted via `.currency(code: "USD")`, with the chain shown underneath in muted type.
- **Typography helpers** — `Text` modifier chains or a small `AppTextStyle` enum (`.titleXL`, `.title`, `.body`, `.caption`) so font choices are centralized.

**verify**: a one-off `ThemeSamplerView` renders every button style, both gradients, a `Card`, a `LocationBadge`, and a `PriceTag` — in both light and dark mode. Delete the sampler before shipping.

## 8. Root `TabView` (`PriceCheckApp.swift` + `AppView.swift`)

Two tabs: **Scan** (`barcode.viewfinder`) and **History** (`clock.arrow.circlepath`). Each wraps a `NavigationStack`. Inject `PriceAPI`, `HistoryStore`, `LocationStore` into the environment. Tab bar tint = `Color.brand`.

**verify**: tabs switch; stub screens render with themed tint.

## 9. Scan tab — `HomeView`

- Hero header on `brandGradient` with app name and short tagline.
- `LocationBadge` + menu picker (options from `LocationStore.all`) to switch chain.
- Big "Price Scan" button using `PrimaryButtonStyle`, navigates to `ScanPickerView`.

**verify**: changing the location via picker updates the badge; CTA pushes.

## 10. Scan tab — `ScanPickerView`

Grouped list of all barcodes + item names from `PriceAPI.allBarcodes()`, plus one trailing row **"Simulate unknown barcode."** Tapping any row calls `api.lookup(...)` for the current location and navigates to `ResultsView` with the result (optional).

Rows styled as `Card`s with item name on top, barcode (muted, monospaced) underneath.

**verify**: picking a known barcode in-stock at current location → price shown; picking the "unknown" row or an item not stocked at current location → not-found path.

## 11. Scan tab — `ResultsView`

Two states, both centered in a `Card`:

- **Found**: `PriceTag`, item name above, date below. Buttons: "Save This Scan" (`PrimaryButtonStyle`), "Scan Another Item" (`SecondaryButtonStyle`).
- **Not found**: SF Symbol `questionmark.circle`, "No price found for this item." One button: "Scan Another Item."

Save calls `HistoryStore.save(lookup)` with today's date, pops back to Home.

**verify**: save creates/updates a `PriceObservation`; pop lands on Home.

## 12. History tab — `HistoryView`

`@Query` all `PriceObservation`s. Group by `barcode` in-view (`Dictionary(grouping:)`); each section header shows the item name (take from any observation in the group); rows within a section are observations sorted newest-first, each row rendered as a mini `Card` showing `location — $price — date`.

Empty state: SF Symbol illustration + *"No scans yet. Tap Scan to get started."*

**verify**: after saving scans across locations, groups render correctly, newest at top of each group.

## 13. Polish pass

- Money formatting (`.formatted(.currency(code: "USD"))`), date formatting (`.formatted(date: .abbreviated, time: .omitted)`).
- Accessibility labels on tappable rows and all icons.
- Dynamic Type spot-check at XL sizes.
- Dark mode spot-check on every screen.
- Delete `ThemeSamplerView` and any `print` scaffolding.

**verify**: nothing shows a raw `3.5900000001` or ISO date string; VoiceOver reads each row sensibly.

---

## Out of scope (deliberately deferred)

- React Native / TypeScript port — begins after this iOS version is landed.
- Real AVFoundation scanner.
- Settings tab, item search, price-trend charts.
- Any real networking layer; `MockPriceAPI` is the only `PriceAPI` implementation.

## Open micro-decisions (resolved inline unless flagged)

- `LocationStore` default persistence: `@AppStorage` on the chosen chain.
- `dayKey` format: `yyyy-MM-dd` in the user's current calendar.
- Error surface: thrown errors from the mock aren't expected; any that occur bubble to a simple alert on the active screen.
- Asset catalog colors use HSB values picked for ~AA contrast on both light and dark backgrounds; exact values chosen during step 7.
