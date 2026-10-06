# PriceCheck — Setup

## Create the Xcode project

1. Xcode → **File → New → Project** → **iOS → App**.
2. Product Name: `PriceCheck`. Interface: **SwiftUI**. Language: **Swift**. Minimum deployment: **iOS 17**.
3. Save it somewhere (e.g., `~/temp/exp/PriceCheckApp/`).
4. In the generated project, **delete** the auto-created `ContentView.swift` and the `PriceCheckApp.swift` that Xcode made (move to trash).

## Add the source files

Drag these files from `/Users/profh/temp/exp/` into the project navigator (check **Copy items if needed** and add to the `PriceCheck` target):

- `PriceCheckApp.swift`
- `Models.swift`
- `MockAPI.swift`
- `ScanStore.swift`
- `HomeView.swift`
- `ScanView.swift`
- `ResultsView.swift`
- `scan_by_location.json`  ← must be in the app target so `Bundle.main` can find it

Verify `scan_by_location.json` is listed under **Target → Build Phases → Copy Bundle Resources**.

## Run

Pick an iPhone simulator and press ⌘R. Flow:

- Home: pick a location from the menu, tap **Price Scan**.
- Scan: tap **Check Price** — picks a random item from that location's history.
- Results: shows item + latest price at that location. **Save This Scan** appends a new scan to the in-memory store (resets on relaunch).

## Notes

- No camera / AVFoundation — scanning is mocked per our discussion.
- Price lookup returns the most recent scan for the item at the current location.
- When you have a real API, swap `MockAPI` for a networking layer with the same shape.
