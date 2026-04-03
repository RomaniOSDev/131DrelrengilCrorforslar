//
//  AchievementsView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var progress: SimulationProgressStore

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenChromeBackground()
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(SimulationProgressStore.allAchievements) { achievement in
                            achievementCard(achievement)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func achievementCard(_ achievement: AchievementDefinition) -> some View {
        let unlocked = progress.achievementSnapshot().contains(achievement.id)
        return HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        unlocked
                            ? LinearGradient(
                                colors: [Color.appAccent.opacity(0.45), Color.appPrimary.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.appSurface.opacity(0.9), Color.appBackground.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                unlocked
                                    ? AppChrome.cardEdge
                                    : LinearGradient(
                                        colors: [Color.appTextSecondary.opacity(0.35), Color.appBackground.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: unlocked ? Color.appAccent.opacity(0.25) : AppChrome.deepShadow.opacity(0.3), radius: unlocked ? 8 : 4, x: 0, y: 4)
                StarShape()
                    .fill(
                        unlocked
                            ? LinearGradient(
                                colors: [Color.appPrimary, Color.appAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.appTextSecondary.opacity(0.35), Color.appTextSecondary.opacity(0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 22, height: 22)
                    .shadow(color: unlocked ? Color.appPrimary.opacity(0.35) : .clear, radius: 3, x: 0, y: 1)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                Text(unlocked ? "Unlocked" : "Locked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(unlocked ? Color.appAccent : Color.appTextSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .appChromeElevated(cornerRadius: 18)
    }
}
