//
//  LevelGridView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct LevelGridView: View {
    let activity: ActivityKind
    @Binding var path: NavigationPath
    @EnvironmentObject private var progress: SimulationProgressStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            AppScreenChromeBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text(activity.titleKey)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 2, x: 0, y: 1)

                    ForEach(DifficultyTier.allCases, id: \.self) { tier in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(tier.titleKey)
                                    .font(.headline)
                                    .foregroundStyle(Color.appTextPrimary)
                                Spacer()
                                Text(difficultyHint(for: tier))
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(0..<tier.levelsPerTier, id: \.self) { index in
                                    levelCell(tier: tier, index: index)
                                }
                            }
                        }
                        .padding(16)
                        .appChromeElevated(cornerRadius: 18)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func difficultyHint(for tier: DifficultyTier) -> String {
        switch tier {
        case .easy: return "Gentle pacing"
        case .normal: return "Added constraints"
        case .hard: return "Dense simulation"
        }
    }

    private func levelCell(tier: DifficultyTier, index: Int) -> some View {
        let unlocked = progress.isLevelUnlocked(activity: activity, tier: tier, levelIndex: index)
        let stars = progress.stars(activity: activity, tier: tier, levelIndex: index)
        return Button {
            let stage = ActiveStageRoute(activity: activity, tier: tier, levelIndex: index)
            path.append(BuildStackRoute.play(stage))
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppChrome.recessed)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AppChrome.recessedRim, lineWidth: 1)
                        )
                        .frame(height: 72)
                        .shadow(color: AppChrome.deepShadow.opacity(0.4), radius: 5, x: 0, y: 3)
                    if unlocked {
                        VStack(spacing: 6) {
                            Text("Stage \(index + 1)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            StarRowView(filled: stars, maximum: 3)
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .padding(8)
        }
        .buttonStyle(.plain)
        .disabled(unlocked == false)
        .opacity(unlocked ? 1 : 0.55)
    }
}
