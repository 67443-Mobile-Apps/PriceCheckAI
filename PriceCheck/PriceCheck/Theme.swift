// Created by Prof. H in 2026
// Part of the PriceCheck project
// Using Swift 6.0
// Qapla'

import SwiftUI
import UIKit

// MARK: - Palette

extension Color {
    static let brand         = Color(light: 0x4F46E5, dark: 0x818CF8)
    static let brandMuted    = Color(light: 0xC7D2FE, dark: 0x3730A3)
    static let accent        = Color(light: 0x14B8A6, dark: 0x2DD4BF)
    static let surface           = Color(light: 0xF5F5F7, dark: 0x111113)
    static let surfaceElevated   = Color(light: 0xFFFFFF, dark: 0x1C1C1F)
    static let onSurface         = Color(light: 0x0B0B0F, dark: 0xF5F5F7)
    static let onSurfaceMuted    = Color(light: 0x6B7280, dark: 0x9CA3AF)
    static let danger        = Color(light: 0xDC2626, dark: 0xF87171)
    static let success       = Color(light: 0x16A34A, dark: 0x4ADE80)
    static let divider       = Color(light: 0xE5E7EB, dark: 0x2A2A2E)

    fileprivate init(light: UInt32, dark: UInt32) {
        self = Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red:   CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >>  8) & 0xFF) / 255.0,
            blue:  CGFloat( hex        & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

// MARK: - Gradients

extension LinearGradient {
    static let brandGradient = LinearGradient(
        colors: [.brand, .accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surfaceGradient = LinearGradient(
        colors: [.surfaceElevated, .surface],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Spacing & radii

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum AppRadius {
    static let small:  CGFloat = 8
    static let medium: CGFloat = 14
    static let large:  CGFloat = 20
    static let pill:   CGFloat = 999
}

// MARK: - Typography

enum AppTextStyle {
    case titleXL, title, body, caption, mono
}

extension View {
    func appTextStyle(_ style: AppTextStyle) -> some View {
        switch style {
        case .titleXL: return AnyView(self.font(.system(size: 34, weight: .bold, design: .rounded)))
        case .title:   return AnyView(self.font(.system(size: 22, weight: .semibold, design: .rounded)))
        case .body:    return AnyView(self.font(.system(size: 17, weight: .regular, design: .rounded)))
        case .caption: return AnyView(self.font(.system(size: 13, weight: .regular, design: .rounded)))
        case .mono:    return AnyView(self.font(.system(size: 13, weight: .regular, design: .monospaced)))
        }
    }
}

// MARK: - Button styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .appTextStyle(.title)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .fill(LinearGradient.brandGradient)
            )
            .shadow(color: Color.brand.opacity(configuration.isPressed ? 0.15 : 0.35),
                    radius: configuration.isPressed ? 4 : 12,
                    y: configuration.isPressed ? 2 : 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .appTextStyle(.title)
            .foregroundStyle(Color.brand)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .fill(Color.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .strokeBorder(Color.brand.opacity(0.4), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .appTextStyle(.title)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .fill(Color.danger)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Card container

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .fill(Color.surfaceElevated)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
    }
}

// MARK: - Location badge

struct LocationBadge: View {
    let location: String

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "mappin.and.ellipse")
            Text(location)
                .appTextStyle(.body)
                .fontWeight(.semibold)
        }
        .foregroundStyle(Color.brand)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            Capsule(style: .continuous)
                .fill(Color.brandMuted.opacity(0.4))
        )
    }
}

// MARK: - Price tag

struct PriceTag: View {
    let price: Double
    let location: String
    let currencyCode: String

    init(price: Double, location: String, currencyCode: String = "USD") {
        self.price = price
        self.location = location
        self.currencyCode = currencyCode
    }

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(price, format: .currency(code: currencyCode))
                .appTextStyle(.titleXL)
                .foregroundStyle(Color.onSurface)
            Text("at \(location)")
                .appTextStyle(.caption)
                .foregroundStyle(Color.onSurfaceMuted)
        }
    }
}
