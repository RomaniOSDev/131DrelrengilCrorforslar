//
//  SettingsView.swift
//  131DrelrengilCrorforslar
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenChromeBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerCard

                        VStack(spacing: 12) {
                            Button(action: rateApp) {
                                settingsRow(
                                    title: "Rate us",
                                    subtitle: "Share feedback on the App Store",
                                    systemImage: "star.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            Button {
                                openLegalLink(.privacyPolicy)
                            } label: {
                                settingsRow(
                                    title: LegalLink.privacyPolicy.titleKey,
                                    subtitle: "How we handle data",
                                    systemImage: "hand.raised.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            Button {
                                openLegalLink(.termsOfUse)
                            } label: {
                                settingsRow(
                                    title: LegalLink.termsOfUse.titleKey,
                                    subtitle: "Rules for using the app",
                                    systemImage: "doc.text.fill"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .appChromeElevated(cornerRadius: AppChrome.cornerLarge)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                    .padding(.bottom, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 2, x: 0, y: 1)
            Text("Feedback, ratings, and legal documents.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appChromeElevated(cornerRadius: 20)
    }

    private func settingsRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppChrome.recessed)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(AppChrome.recessedRim, lineWidth: 1)
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
            }
            .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(minHeight: DesignConstants.minTapTarget)
        .appChromeInset(cornerRadius: 16)
    }

    private func openLegalLink(_ link: LegalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
