import SwiftUI

struct ResultsView: View {
    @Environment(ScanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let item: String
    let price: Double
    @State private var saved = false

    var body: some View {
        ZStack {
            BrandBackground()

            VStack(spacing: 24) {
                priceCard
                    .padding(.top, 16)

                VStack(spacing: 12) {
                    Button {
                        store.saveScan(item: item, price: price)
                        withAnimation(.spring) { saved = true }
                    } label: {
                        Label(saved ? "Saved" : "Save This Scan",
                              systemImage: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                    }
                    .buttonStyle(.primaryGradient(colors: saved ? [.green, .green.opacity(0.8)]
                                                                : [.accentPrimary, .accentSecondary]))
                    .disabled(saved)

                    Button {
                        dismiss()
                    } label: {
                        Label("Scan Another Item", systemImage: "barcode.viewfinder")
                    }
                    .buttonStyle(.tinted)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Price Check")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .tint(Color.accentPrimary)
    }

    private var priceCard: some View {
        VStack(spacing: 16) {
            if let locationName = store.currentLocation?.location {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                    Text(locationName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Text(item)
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)

            Text(price, format: .currency(code: "USD"))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(LinearGradient.brandHorizontal)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
        )
    }
}

#Preview {
    NavigationStack {
        ResultsView(item: "Charmin Toilet Tissues (12 pk)", price: 7.99)
    }
    .environment(ScanStore())
}
