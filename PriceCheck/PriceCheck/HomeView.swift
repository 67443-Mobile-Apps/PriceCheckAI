// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI

struct HomeView: View {

    @Environment(LocationStore.self) private var locationStore

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.surface.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("PriceCheck")
                .appTextStyle(.titleXL)
                .foregroundStyle(.white)
            Text("Scan a barcode. See what it costs.")
                .appTextStyle(.body)
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.xl)
        .background(
            LinearGradient.brandGradient
                .ignoresSafeArea(edges: .top)
        )
    }

    private var content: some View {
        VStack(spacing: AppSpacing.lg) {
            locationCard
            scanButton
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.lg)
    }

    private var locationCard: some View {
        @Bindable var store = locationStore
        return Card {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Your location")
                    .appTextStyle(.caption)
                    .foregroundStyle(Color.onSurfaceMuted)

                Menu {
                    ForEach(locationStore.all, id: \.self) { location in
                        Button {
                            store.current = location
                        } label: {
                            if location == locationStore.current {
                                Label(location, systemImage: "checkmark")
                            } else {
                                Text(location)
                            }
                        }
                    }
                } label: {
                    HStack {
                        LocationBadge(location: locationStore.current.isEmpty
                                      ? "Loading…"
                                      : locationStore.current)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundStyle(Color.onSurfaceMuted)
                            .accessibilityHidden(true)
                    }
                }
                .disabled(locationStore.all.isEmpty)
                .accessibilityLabel("Change location")
                .accessibilityValue(locationStore.current.isEmpty ? "Loading" : locationStore.current)
            }
        }
    }

    private var scanButton: some View {
        NavigationLink(value: ScanRoute.picker) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 22, weight: .semibold))
                    .accessibilityHidden(true)
                Text("Price Scan")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(locationStore.current.isEmpty)
        .accessibilityHint("Opens the barcode picker to look up a price at \(locationStore.current).")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(LocationStore(defaults: UserDefaults(suiteName: "preview")!))
}
