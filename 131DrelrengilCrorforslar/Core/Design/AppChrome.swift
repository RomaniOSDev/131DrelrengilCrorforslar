//
//  AppChrome.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

enum AppChrome {
    static let cornerLarge: CGFloat = 22
    static let cornerMedium: CGFloat = 18
    static let cornerSmall: CGFloat = 14

    static var screenBase: LinearGradient {
        LinearGradient(
            colors: [
                Color.appBackground,
                Color.appBackground.opacity(0.94),
                Color.appSurface.opacity(0.32)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var screenGlow: RadialGradient {
        RadialGradient(
            colors: [
                Color.appPrimary.opacity(0.16),
                Color.appAccent.opacity(0.07),
                Color.clear
            ],
            center: .topLeading,
            startRadius: 4,
            endRadius: 360
        )
    }

    static var surfaceRelief: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(1),
                Color.appSurface.opacity(0.9),
                Color.appBackground.opacity(0.42)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardEdge: LinearGradient {
        LinearGradient(
            colors: [
                Color.appPrimary.opacity(0.42),
                Color.appAccent.opacity(0.3),
                Color.appTextSecondary.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var innerSheen: LinearGradient {
        LinearGradient(
            colors: [Color.appTextPrimary.opacity(0.08), Color.clear],
            startPoint: .top,
            endPoint: UnitPoint(x: 0.5, y: 0.52)
        )
    }

    static var recessed: LinearGradient {
        LinearGradient(
            colors: [Color.appBackground.opacity(0.88), Color.appBackground.opacity(0.38)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var recessedRim: LinearGradient {
        LinearGradient(
            colors: [Color.appBackground.opacity(0.55), Color.appSurface.opacity(0.25)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var heroFill: LinearGradient {
        LinearGradient(
            colors: [
                Color.appSurface.opacity(0.98),
                Color.appSurface.opacity(0.75),
                Color.appBackground.opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryCTA: LinearGradient {
        LinearGradient(
            colors: [Color.appAccent, Color.appPrimary.opacity(0.95)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var progressFill: LinearGradient {
        LinearGradient(
            colors: [Color.appAccent, Color.appPrimary],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static func accentRim(_ accent: Color) -> LinearGradient {
        LinearGradient(
            colors: [accent.opacity(0.55), accent.opacity(0.18), Color.appPrimary.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var deepShadow: Color { Color.appBackground.opacity(0.68) }
    static var glowShadow: Color { Color.appPrimary.opacity(0.14) }
}

struct AppScreenChromeBackground: View {
    var body: some View {
        ZStack {
            AppChrome.screenBase
            AppChrome.screenGlow
                .offset(x: -36, y: -48)
        }
        .ignoresSafeArea()
    }
}

struct AppChromeElevatedModifier: ViewModifier {
    var cornerRadius: CGFloat = AppChrome.cornerLarge

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppChrome.surfaceRelief)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(AppChrome.cardEdge, lineWidth: 1)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppChrome.innerSheen)
                }
            )
            .shadow(color: AppChrome.deepShadow, radius: 18, x: 0, y: 12)
            .shadow(color: AppChrome.glowShadow, radius: 10, x: 0, y: 5)
    }
}

struct AppChromeAccentElevatedModifier: ViewModifier {
    var cornerRadius: CGFloat
    var accent: Color

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppChrome.surfaceRelief)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(AppChrome.accentRim(accent), lineWidth: 1.5)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppChrome.innerSheen)
                }
            )
            .shadow(color: AppChrome.deepShadow, radius: 14, x: 0, y: 9)
            .shadow(color: accent.opacity(0.18), radius: 8, x: 0, y: 4)
    }
}

struct AppChromeInsetModifier: ViewModifier {
    var cornerRadius: CGFloat = AppChrome.cornerSmall

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppChrome.recessed)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(AppChrome.recessedRim, lineWidth: 1)
                    )
            )
            .shadow(color: AppChrome.deepShadow.opacity(0.55), radius: 5, x: 0, y: 4)
    }
}

extension View {
    func appChromeElevated(cornerRadius: CGFloat = AppChrome.cornerLarge) -> some View {
        modifier(AppChromeElevatedModifier(cornerRadius: cornerRadius))
    }

    func appChromeAccentElevated(cornerRadius: CGFloat = AppChrome.cornerMedium, accent: Color) -> some View {
        modifier(AppChromeAccentElevatedModifier(cornerRadius: cornerRadius, accent: accent))
    }

    func appChromeInset(cornerRadius: CGFloat = AppChrome.cornerSmall) -> some View {
        modifier(AppChromeInsetModifier(cornerRadius: cornerRadius))
    }
}
