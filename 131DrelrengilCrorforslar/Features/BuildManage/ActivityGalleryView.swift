//
//  ActivityGalleryView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct ActivityGalleryView: View {
    let onSelect: (ActivityKind) -> Void

    var body: some View {
        ZStack {
            AppScreenChromeBackground()
            ScrollView {
                VStack(spacing: 16) {
                    Text("Scenario roster")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 2, x: 0, y: 1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(ActivityKind.allCases, id: \.self) { kind in
                        Button {
                            onSelect(kind)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(kind.titleKey)
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.appPrimary)
                                }
                                Text(kind.detailKey)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .multilineTextAlignment(.leading)
                                HStack(spacing: 8) {
                                    StarShape()
                                        .fill(Color.appAccent)
                                        .frame(width: 18, height: 18)
                                    Text("\(aggregateStars(for: kind)) stars collected")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(Color.appTextSecondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appChromeElevated(cornerRadius: 20)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @EnvironmentObject private var progress: SimulationProgressStore

    private func aggregateStars(for kind: ActivityKind) -> Int {
        var total = 0
        for tier in DifficultyTier.allCases {
            for index in 0..<tier.levelsPerTier {
                total += progress.stars(activity: kind, tier: tier, levelIndex: index)
            }
        }
        return min(27, total)
    }
}
