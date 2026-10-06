import SwiftUI

struct HomeView: View {
    @Environment(ScanStore.self) private var store
    @State private var showScan = false

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()

                VStack(spacing: 32) {
                    LocationHeader()
                        .padding(.top, 8)

                    Spacer()

                    PriceScanButton { showScan = true }
                        .disabled(store.currentLocation == nil)

                    Spacer()

                    Text("Tap to scan a bar code and check the price.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("PriceCheck")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showScan) {
                ScanView()
            }
        }
        .tint(Color.accentPrimary)
    }
}

#Preview {
    HomeView().environment(ScanStore())
}
