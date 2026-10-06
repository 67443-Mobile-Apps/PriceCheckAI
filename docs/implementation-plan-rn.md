# PriceCheck RN — React Native / TypeScript Port Implementation Plan

**Baseline**: fresh Expo managed app, SDK 52+, TypeScript strict mode, no OS-level native changes. Location: `/Users/profh/temp/exp/PriceCheckRN/` (sibling to the iOS project).

**Deps** (installed as we hit each step; nothing speculative up front):

- `@react-navigation/native`, `@react-navigation/native-stack`, `@react-navigation/bottom-tabs`
- `react-native-screens`, `react-native-safe-area-context` (peer deps of React Navigation)
- `expo-sqlite`
- `drizzle-orm`, `drizzle-kit` (dev)
- `jest`, `jest-expo`, `@testing-library/react-native` (dev)

**Test runner**: Jest via `jest-expo` preset, `@testing-library/react-native` for component tests. Add once step 2's unit tests arrive.

**Shared data**: `prices.json` is copied into `PriceCheckRN/assets/prices.json`. The file's shape is the contract the two apps share; same content, independent files on disk.

Each step is sized so you can see it working before moving on. `verify` is the signal that step is done. Where it maps cleanly to the iOS plan, the step number lines up so you can diff the two sides.

---

## 1. Project scaffold

`npx create-expo-app@latest PriceCheckRN --template blank-typescript` from `/Users/profh/temp/exp/`. Confirm `tsconfig.json` has `"strict": true`. Drop a copy of `prices.json` into `PriceCheckRN/assets/`.

**verify**: `npx expo start` launches; the default "Open up App.tsx to start working on your app!" renders in the iOS simulator; a quick `console.log(require('./assets/prices.json').length)` prints `6`.

## 2. API-shape types (`src/api/types.ts`)

TypeScript equivalents of the iOS `APITypes.swift`:

```ts
type APIPrice = { location: string; price: number; daysAgo: number };
type APIItem  = { barcode: string; item: string; prices: APIPrice[] };

type PriceLookup = {
  barcode: string;
  itemName: string;
  price: number;
  location: string;
  date: Date;
};
```

**verify**: a Jest test parses the bundled JSON (`require('../../assets/prices.json') as APIItem[]`) and asserts barcode/item/prices for the first entry.

## 3. `PriceAPI` interface + `MockPriceAPI` (`src/api/priceAPI.ts`)

Interface + an injectable data-source function (mirrors the iOS actor's `dataSource` closure, which lets tests pass a literal JSON string):

```ts
interface PriceAPI {
  lookup(barcode: string, location: string): Promise<PriceLookup | null>;
  allBarcodes(): Promise<BarcodeEntry[]>;
  knownLocations(): Promise<string[]>;
}
```

`makeMockPriceAPI(dataSource)` returns a `PriceAPI`. A `bundledMockPriceAPI()` factory wires `dataSource` to `require('../../assets/prices.json')`.

**verify**: Jest tests cover (a) known barcode + known location → price, (b) known barcode + absent location → `null`, (c) unknown barcode → `null`, (d) `knownLocations()` returns sorted unique chains, (e) `allBarcodes()` is sorted alphabetically by item name.

## 4. SQLite + Drizzle schema (`src/db/schema.ts`, `src/db/client.ts`)

Drizzle schema for `price_observations`:

```ts
export const priceObservations = sqliteTable('price_observations', {
  id: integer('id').primaryKey({ autoIncrement: true }),
  barcode: text('barcode').notNull(),
  itemName: text('item_name').notNull(),
  location: text('location').notNull(),
  price: real('price').notNull(),
  date: integer('date', { mode: 'timestamp' }).notNull(),
  dayKey: text('day_key').notNull(),
}, (t) => ({
  uniqueByDay: uniqueIndex('obs_barcode_loc_day').on(t.barcode, t.location, t.dayKey),
}));
```

`client.ts` opens `expo-sqlite` with `openDatabaseSync('pricecheck.db')`, wraps it in `drizzle(...)`, and runs a `CREATE TABLE IF NOT EXISTS` from the Drizzle schema on first open.

**verify**: integration test using an in-memory DB (`:memory:`) inserts a row, reads it back, asserts fields.

## 5. `HistoryStore` with upsert + purge (`src/db/historyStore.ts`)

Thin module exporting async functions bound to the Drizzle client:

- `save(lookup: PriceLookup, when = new Date()): Promise<void>` — `INSERT ... ON CONFLICT(barcode, location, day_key) DO UPDATE SET price = ?, item_name = ?, date = ?`.
- `allObservations(): Promise<PriceObservation[]>` — ordered by date descending.
- `purgeOlderThan(days: number, now = new Date()): Promise<void>` — single `DELETE WHERE date < ?`.

**verify**: Jest integration tests with a `:memory:` SQLite DB cover (a) saving same `(barcode, location, day)` twice leaves one row with latest price, (b) saving different locations on same day keeps both, (c) purge drops old rows, (d) `allObservations` returns newest-first.

## 6. `LocationStore` context (`src/stores/LocationStore.tsx`)

React Context + a `useLocationStore()` hook. Shape:

```ts
type LocationStoreValue = {
  all: string[];
  current: string;
  setCurrent: (chain: string) => void;
};
```

`LocationStoreProvider` component takes a `PriceAPI` and loads `knownLocations()` on mount; keeps `current` in `useState`, persists it to `AsyncStorage` on change, hydrates on first launch (falling back to `all[0]` alphabetically if nothing is stored or the stored value disappeared).

**(SwiftUI parallel: `@Observable LocationStore` → React Context; `@AppStorage` → `AsyncStorage` write in a `useEffect` on `current`.)**

Adds `@react-native-async-storage/async-storage` to deps.

**verify**: component tests via `@testing-library/react-native` cover (a) `all` populated after load, (b) `current` defaults to first alphabetical on first mount, (c) `current` persists across simulated remount, (d) persisted `current` resets when no longer in `all`.

## 7. Design tokens (`src/theme/theme.ts`, `src/theme/components.tsx`)

Direct parallel to `Theme.swift`. `theme.ts` exports plain-object tokens:

```ts
export const colors = {
  brand: '#4F46E5',  brandMuted: '#C7D2FE',  accent: '#14B8A6',
  surface: '#F5F5F7', surfaceElevated: '#FFFFFF',
  onSurface: '#0B0B0F', onSurfaceMuted: '#6B7280',
  danger: '#DC2626', success: '#16A34A', divider: '#E5E7EB',
};
export const spacing = { xs: 4, sm: 8, md: 16, lg: 24, xl: 32 };
export const radius  = { small: 8, medium: 14, large: 20, pill: 999 };
export const text    = { titleXL: {...}, title: {...}, body: {...}, caption: {...}, mono: {...} };
```

Dark-mode variants deferred (iOS parity: light-only for now). `components.tsx` exports:

- `<PrimaryButton>`, `<SecondaryButton>`, `<DestructiveButton>` — `Pressable` with internal `StyleSheet` + press-state style.
- `<Card>` — rounded, shadowed surface container.
- `<LocationBadge>` — pill with `mappin.and.ellipse` from `@expo/vector-icons/Ionicons`.
- `<PriceTag>` — `Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' })` for the price, muted "at <location>" below.
- `<BrandGradient>` — `expo-linear-gradient` wrapper for the Home header band. Adds `expo-linear-gradient` to deps.

**verify**: a `ThemeSamplerScreen` renders every component. Shown as a dev-only screen (toggled via a comment in the root navigator, deleted at step 13).

## 8. Root navigation (`src/navigation/AppNavigator.tsx`, `App.tsx`)

Bottom-tab navigator with two tabs: **Scan** (barcode-outline icon) and **History** (time-outline icon). Each tab wraps a native stack navigator. The Scan stack has routes `Home → ScanPicker → Results`.

`App.tsx` composes the provider tree: `GestureHandlerRootView > SafeAreaProvider > LocationStoreProvider > NavigationContainer > AppNavigator`. The `PriceAPI` instance is created once at the top and threaded through context (`PriceAPIContext`).

**(SwiftUI parallel: `TabView` → bottom tabs; `NavigationStack` → native stack; `.environment(\.priceAPI, ...)` → `PriceAPIContext.Provider`; `.environment(\.scanPath, $path)` is unnecessary because `navigation.popToTop()` is a built-in.)**

**verify**: tabs switch; stub screens render with brand-tinted tab icons.

## 9. `HomeScreen` (`src/screens/HomeScreen.tsx`)

- `<BrandGradient>` band at top with "PriceCheck" title + tagline.
- `<Card>` with "Your location" label + a chain picker that opens the native `ActionSheet` on iOS (via `ActionSheetIOS`) — or a modal `<Picker>` fallback. Shows `<LocationBadge>` + chevron.
- `<PrimaryButton>` labeled "Price Scan" with `barcode.viewfinder` icon; navigates to `ScanPicker`.

**verify**: picker opens, selecting a chain updates the badge; button pushes.

## 10. `ScanPickerScreen` (`src/screens/ScanPickerScreen.tsx`)

Scrollable list sourced from `priceAPI.allBarcodes()`:

- Each row is a `<Pressable>` wrapped `<Card>` with barcode icon · item name · UPC in monospaced font · right chevron.
- Trailing row with dashed border: "Simulate unknown barcode" — scans the fixed string `"000000000000"`.

Tap → `await priceAPI.lookup(barcode, location)` → `navigation.navigate('Results', { result })` where `result` is `{ kind: 'found' | 'notFound', ... }` discriminated union.

**verify**: tapping a known barcode in-stock at current chain → found; tapping an out-of-stock item or the unknown row → not-found.

## 11. `ResultsScreen` (`src/screens/ResultsScreen.tsx`)

Two states inside a `<Card>`:

- **Found**: item name title, `<PriceTag>`, date (`Intl.DateTimeFormat`). Buttons: "Save This Scan" (primary), "Scan Another Item" (secondary).
- **Not found**: `help-circle-outline` icon, "No price found for this item.", "Scan Another Item".

Save calls `historyStore.save(lookup)` then `navigation.popToTop()`. "Scan Another Item" also `popToTop()`s.

**verify**: save creates/updates a row; pop lands on Home.

## 12. `HistoryScreen` (`src/screens/HistoryScreen.tsx`)

- Fetches via `useEffect` + `useFocusEffect` so the list refreshes on tab focus (parallel to SwiftData's `@Query` auto-refresh, which React doesn't give for free).
- Groups observations by `barcode` using a `reduce` into a `Map<string, PriceObservation[]>`; sorts groups alphabetically by item name; within each group, newest-first.
- Each row is a mini `<Card>` with `<LocationBadge>`, date, and price.
- Empty state: `time-outline` icon + "No scans yet." / "Tap Scan to get started."

**verify**: after saving a few scans, groups render correctly; dedup still enforced; empty state appears after `DELETE FROM price_observations`.

## 13. Polish pass

- Currency formatting via `Intl.NumberFormat`, dates via `Intl.DateTimeFormat` — no raw numbers or ISO strings in the UI.
- Accessibility: `accessibilityRole`, `accessibilityLabel`, `accessibilityHint` on tappable rows; decorative icons marked `accessibilityElementsHidden`.
- Dynamic Type / font scaling spot-check (`PixelRatio.getFontScale()`).
- Remove `ThemeSamplerScreen` from the root navigator and delete the file.
- Any leftover `console.log` scaffolding gone; real error logs stay.

**verify**: VoiceOver reads each row sensibly; nothing shows a raw `3.5900000001` or ISO date string.

---

## Out of scope (deliberately deferred)

- Real `expo-camera` scanner.
- Dark mode (iOS deferred this too; add to both apps together later).
- Android testing / layout fixes (iOS simulator only).
- Shared package / monorepo for `prices.json`.
- Settings screen, item search, price-trend charts.
- Any real networking layer; `MockPriceAPI` is the only `PriceAPI` implementation.

## Open micro-decisions (resolved inline unless flagged)

- `LocationStore` AsyncStorage key: `"PriceCheck.LocationStore.current"`.
- `dayKey` format: `yyyy-MM-dd` in device local time, via a small formatter.
- Error surface: thrown errors from mock/DB bubble to a simple `<Text>` on the active screen (parity with iOS).
- iOS / Android: develop and verify on iOS simulator; Android verification deferred.
- Node version: whatever Expo SDK 52 requires (currently Node 20+).
