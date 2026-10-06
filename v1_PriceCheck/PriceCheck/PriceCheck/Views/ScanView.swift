import SwiftUI

struct ScanView: View {
    @Environment(ScanStore.self) private var store
    @State private var result: ScanResult?
    @State private var isScanning = false

    struct ScanResult: Hashable {
        let item: String
        let price: Double
    }

    var body: some View {
        ZStack {
            BrandBackground()

            VStack(spacing: 28) {
                Text("Position bar code within the frame")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                Viewfinder()

                Button(action: performScan) {
                    HStack {
                        if isScanning {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "barcode")
                        }
                        Text(isScanning ? "Scanning…" : "Check Price")
                    }
                }
                .buttonStyle(.primaryGradient)
                .disabled(store.currentLocation == nil || isScanning)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Scan Bar Code")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Color.accentPrimary)
        .navigationDestination(item: $result) { result in
            ResultsView(item: result.item, price: result.price)
        }
    }

    private func performScan() {
        guard let location = store.currentLocation else { return }
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            defer { isScanning = false }
            do {
                let item = try MockAPI.simulateScan(at: location)
                let price = try MockAPI.lookupPrice(for: item, at: location)
                result = ScanResult(item: item, price: price)
            } catch {
                // Prototype: silently ignore.
            }
        }
    }
}

#Preview {
    NavigationStack { ScanView() }.environment(ScanStore())
}
