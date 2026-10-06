// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI

struct ResultsView: View {
    let result: ScanResult

    @Environment(\.historyStore) private var historyStore
    @Environment(\.scanPath) private var scanPath

    @State private var saveError: String?

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Card {
                content
                    .frame(maxWidth: .infinity)
            }
            buttons
            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Price Check Results")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch result {
        case .found(let lookup):
            VStack(spacing: AppSpacing.md) {
                Text(lookup.itemName)
                    .appTextStyle(.title)
                    .foregroundStyle(Color.onSurface)
                    .multilineTextAlignment(.center)

                PriceTag(price: lookup.price, location: lookup.location)

                Text(lookup.date, format: .dateTime.month().day().year())
                    .appTextStyle(.caption)
                    .foregroundStyle(Color.onSurfaceMuted)
            }
            .padding(.vertical, AppSpacing.md)

        case .notFound:
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 56, weight: .regular))
                    .foregroundStyle(Color.onSurfaceMuted)
                    .accessibilityHidden(true)
                Text("No price found for this item.")
                    .appTextStyle(.body)
                    .foregroundStyle(Color.onSurface)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, AppSpacing.lg)
        }
    }

    @ViewBuilder
    private var buttons: some View {
        if case .found(let lookup) = result {
            Button {
                save(lookup)
            } label: {
                Text("Save This Scan")
            }
            .buttonStyle(PrimaryButtonStyle())
        }

        Button {
            popToHome()
        } label: {
            Text("Scan Another Item")
        }
        .buttonStyle(SecondaryButtonStyle())

        if let saveError {
            Text(saveError)
                .appTextStyle(.caption)
                .foregroundStyle(Color.danger)
        }
    }

    private func save(_ lookup: PriceLookup) {
        guard let store = historyStore else {
            saveError = "History store unavailable."
            return
        }
        do {
            try store.save(lookup)
            popToHome()
        } catch {
            saveError = "Couldn't save: \(error.localizedDescription)"
        }
    }

    private func popToHome() {
        scanPath?.wrappedValue = NavigationPath()
    }
}
