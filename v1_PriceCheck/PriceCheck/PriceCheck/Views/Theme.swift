import SwiftUI

// MARK: - Colors

extension Color {
    static let accentPrimary = Color(red: 0.26, green: 0.44, blue: 0.95)
    static let accentSecondary = Color(red: 0.52, green: 0.33, blue: 0.93)
}

extension LinearGradient {
    static let brand = LinearGradient(
        colors: [.accentPrimary, .accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let brandHorizontal = LinearGradient(
        colors: [.accentPrimary, .accentSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Background

struct BrandBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(.systemBackground), Color.accentPrimary.opacity(0.08)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Button styles

struct PrimaryGradientButtonStyle: ButtonStyle {
    var colors: [Color] = [.accentPrimary, .accentSecondary]

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct TintedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundStyle(Color.accentPrimary)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentPrimary.opacity(0.12))
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension ButtonStyle where Self == PrimaryGradientButtonStyle {
    static var primaryGradient: PrimaryGradientButtonStyle { .init() }
    static func primaryGradient(colors: [Color]) -> PrimaryGradientButtonStyle { .init(colors: colors) }
}

extension ButtonStyle where Self == TintedButtonStyle {
    static var tinted: TintedButtonStyle { .init() }
}

// MARK: - Location header (used on Home)

struct LocationHeader: View {
    @Environment(ScanStore.self) private var store

    var body: some View {
        if let error = store.loadError {
            Text(error).foregroundStyle(.red)
        } else {
            @Bindable var store = store
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentPrimary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Location")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("Location", selection: $store.currentLocationID) {
                        ForEach(store.locations) { loc in
                            Text(loc.location).tag(Optional(loc.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .tint(.primary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Price scan button (used on Home)

struct PriceScanButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 72, weight: .light))
                Text("Price Scan")
                    .font(.title.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 260)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient.brand)
                    .shadow(color: Color.accentPrimary.opacity(0.35), radius: 20, y: 10)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Viewfinder (used on Scan)

struct Viewfinder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))

            Image(systemName: "barcode")
                .resizable()
                .scaledToFit()
                .padding(60)
                .foregroundStyle(.quaternary)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(LinearGradient.brand, lineWidth: 3)

            CornerBrackets()
                .stroke(Color.accentPrimary, lineWidth: 4)
                .padding(16)
        }
        .aspectRatio(1, contentMode: .fit)
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
    }
}

struct CornerBrackets: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let len = min(rect.width, rect.height) * 0.15
        // top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + len))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + len, y: rect.minY))
        // top-right
        path.move(to: CGPoint(x: rect.maxX - len, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + len))
        // bottom-left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - len))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + len, y: rect.maxY))
        // bottom-right
        path.move(to: CGPoint(x: rect.maxX - len, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - len))
        return path
    }
}
