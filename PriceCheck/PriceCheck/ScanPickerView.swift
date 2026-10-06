// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI

enum ScanResult: Hashable, Identifiable {
    case found(PriceLookup)
    case notFound(barcode: String, location: String)

    var id: String {
        switch self {
        case .found(let lookup):     return "found-\(lookup.barcode)-\(lookup.location)"
        case .notFound(let b, let l): return "notfound-\(b)-\(l)"
        }
    }
}

struct ScanPickerView: View {

    @Environment(\.priceAPI) private var api
    @Environment(\.scanPath) private var scanPath
    @Environment(LocationStore.self) private var locationStore

    @State private var entries: [BarcodeEntry] = []
    @State private var isLoading = true
    @State private var loadError: String?

    private static let unknownBarcode = "000000000000"

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                if isLoading {
                    ProgressView().padding(.top, AppSpacing.xl)
                } else if let loadError {
                    Text(loadError)
                        .appTextStyle(.body)
                        .foregroundStyle(Color.danger)
                        .multilineTextAlignment(.center)
                        .padding(.top, AppSpacing.xl)
                } else {
                    header
                    ForEach(entries, id: \.barcode) { entry in
                        knownRow(entry)
                    }
                    unknownRow
                }
            }
            .padding(AppSpacing.md)
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Scan an item")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadEntries() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Pick a barcode to simulate scanning.")
                .appTextStyle(.body)
                .foregroundStyle(Color.onSurfaceMuted)
            Text("Scanning at \(locationStore.current)")
                .appTextStyle(.caption)
                .foregroundStyle(Color.onSurfaceMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func knownRow(_ entry: BarcodeEntry) -> some View {
        Button {
            Task { await scan(barcode: entry.barcode) }
        } label: {
            Card {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "barcode")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Color.brand)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(entry.item)
                            .appTextStyle(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.onSurface)
                        Text(entry.barcode)
                            .appTextStyle(.mono)
                            .foregroundStyle(Color.onSurfaceMuted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.onSurfaceMuted)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.item), barcode \(entry.barcode)")
        .accessibilityHint("Looks up the price at \(locationStore.current).")
    }

    private var unknownRow: some View {
        Button {
            Task { await scan(barcode: Self.unknownBarcode) }
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.onSurfaceMuted)
                    .accessibilityHidden(true)
                Text("Simulate unknown barcode")
                    .appTextStyle(.body)
                    .foregroundStyle(Color.onSurfaceMuted)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.onSurfaceMuted)
                    .accessibilityHidden(true)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .strokeBorder(
                        Color.divider,
                        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("Exercises the not-found path with a barcode that isn't in the catalog.")
    }

    private func loadEntries() async {
        do {
            entries = try await api.allBarcodes()
            isLoading = false
        } catch {
            loadError = "Couldn't load barcodes: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func scan(barcode: String) async {
        let location = locationStore.current
        do {
            let result: ScanResult
            if let lookup = try await api.lookup(barcode: barcode, at: location) {
                result = .found(lookup)
            } else {
                result = .notFound(barcode: barcode, location: location)
            }
            scanPath?.wrappedValue.append(ScanRoute.result(result))
        } catch {
            loadError = "Lookup failed: \(error.localizedDescription)"
        }
    }
}
