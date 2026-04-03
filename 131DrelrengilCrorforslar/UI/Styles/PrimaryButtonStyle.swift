//
//  PrimaryButtonStyle.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct PrimaryProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color.appBackground)
            .padding(.horizontal, DesignConstants.buttonHorizontalPadding)
            .frame(maxWidth: .infinity, minHeight: DesignConstants.minTapTarget)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppChrome.primaryCTA)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appTextPrimary.opacity(0.22), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .opacity(configuration.isPressed ? 0 : 1)
                }
                .opacity(configuration.isPressed ? 0.88 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: AppChrome.deepShadow, radius: 14, x: 0, y: 8)
            .shadow(color: Color.appPrimary.opacity(0.32), radius: 10, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(DesignConstants.spring, value: configuration.isPressed)
    }
}

struct SecondaryOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color.appPrimary)
            .padding(.horizontal, DesignConstants.buttonHorizontalPadding)
            .frame(maxWidth: .infinity, minHeight: DesignConstants.minTapTarget)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppChrome.surfaceRelief)
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppChrome.innerSheen.opacity(0.85))
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppChrome.cardEdge, lineWidth: 2)
                }
                .opacity(configuration.isPressed ? 0.92 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: AppChrome.deepShadow.opacity(0.45), radius: 10, x: 0, y: 6)
            .shadow(color: AppChrome.glowShadow.opacity(0.6), radius: 6, x: 0, y: 3)
            .animation(DesignConstants.spring, value: configuration.isPressed)
    }
}
