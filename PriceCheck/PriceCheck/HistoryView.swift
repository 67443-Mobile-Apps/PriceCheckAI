// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI
import SwiftData

struct HistoryView: View {

    @Query(sort: \PriceObservation.date, order: .reverse)
    private var observations: [PriceObservation]

    var body: some View {
        Group {
            if observations.isEmpty {
                emptyState
            } else {
                content
            }
        }
        .background(Color.surface.ignoresSafeArea())
        .navigationTitle("Price History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                ForEach(groupedObservations, id: \.barcode) { group in
                    section(for: group)
                }
            }
            .padding(AppSpacing.md)
        }
    }

    private func section(for group: ObservationGroup) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(group.itemName)
                    .appTextStyle(.title)
                    .foregroundStyle(Color.onSurface)
                Text(group.barcode)
                    .appTextStyle(.mono)
                    .foregroundStyle(Color.onSurfaceMuted)
            }
            .padding(.horizontal, AppSpacing.xs)

            VStack(spacing: AppSpacing.sm) {
                ForEach(group.observations) { observation in
                    observationRow(observation)
                }
            }
        }
    }

    private func observationRow(_ observation: PriceObservation) -> some View {
        let priceText = observation.price.formatted(.currency(code: "USD"))
        let dateText = observation.date.formatted(.dateTime.month().day().year())
        return Card {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    LocationBadge(location: observation.location)
                    Text(dateText)
                        .appTextStyle(.caption)
                        .foregroundStyle(Color.onSurfaceMuted)
                }
                Spacer()
                Text(priceText)
                    .appTextStyle(.title)
                    .foregroundStyle(Color.onSurface)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(priceText) at \(observation.location) on \(dateText)")
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.onSurfaceMuted)
            Text("No scans yet.")
                .appTextStyle(.title)
                .foregroundStyle(Color.onSurface)
            Text("Tap Scan to get started.")
                .appTextStyle(.body)
                .foregroundStyle(Color.onSurfaceMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.lg)
    }

    private var groupedObservations: [ObservationGroup] {
        let byBarcode = Dictionary(grouping: observations, by: \.barcode)
        return byBarcode
            .map { barcode, obs in
                let sorted = obs.sorted { $0.date > $1.date }
                return ObservationGroup(
                    barcode: barcode,
                    itemName: sorted.first?.itemName ?? barcode,
                    observations: sorted
                )
            }
            .sorted { $0.itemName.localizedCaseInsensitiveCompare($1.itemName) == .orderedAscending }
    }
}

private struct ObservationGroup {
    let barcode: String
    let itemName: String
    let observations: [PriceObservation]
}
