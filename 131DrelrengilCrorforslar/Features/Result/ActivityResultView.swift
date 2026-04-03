//
//  ActivityResultView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct ActivityResultView: View {
    let stage: ActiveStageRoute
    let outcome: ActivitySessionOutcome
    let freshAchievementIDs: [String]
    @Binding var path: NavigationPath
    @EnvironmentObject private var progress: SimulationProgressStore

    @State private var starVisible = [false, false, false]
    @State private var bannerOffset: CGFloat = -220
    @State private var showBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            AppScreenChromeBackground()
            ScrollView {
                VStack(spacing: 22) {
                    Text(outcome.passed ? "Scenario complete" : "Scenario needs tuning")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .shadow(color: AppChrome.deepShadow.opacity(0.4), radius: 3, x: 0, y: 2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    starSection

                    statsCard

                    VStack(spacing: 12) {
                        if outcome.passed, let next = nextStage(), canPlay(next) {
                            Button {
                                goNext(next)
                            } label: {
                                Text("Next stage")
                            }
                            .buttonStyle(PrimaryProminentButtonStyle())
                        } else if outcome.passed, nextStage() == nil {
                            Text("All stages in this path are cleared. Explore another scenario.")
                                .font(.footnote)
                                .foregroundStyle(Color.appTextSecondary)
                                .multilineTextAlignment(.center)
                        }

                        Button {
                            retry()
                        } label: {
                            Text("Retry stage")
                        }
                        .buttonStyle(SecondaryOutlineButtonStyle())

                        Button {
                            backToLevels()
                        } label: {
                            Text("Levels overview")
                        }
                        .buttonStyle(SecondaryOutlineButtonStyle())
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 28)
            }

            if showBanner, let badge = bannerAchievement() {
                achievementBanner(badge)
                    .padding(.top, 12)
                    .offset(y: bannerOffset)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateStars()
            prepareBanner()
        }
    }

    private var starSection: some View {
        HStack(spacing: 18) {
            ForEach(0..<3, id: \.self) { index in
                let earned = index < outcome.starsEarned
                StarShape()
                    .fill(
                        earned
                            ? LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.appTextSecondary.opacity(0.32), Color.appBackground.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 52, height: 52)
                    .scaleEffect(starVisible[index] ? 1 : 0.25)
                    .shadow(color: earned && starVisible[index] ? Color.appAccent.opacity(0.7) : .clear, radius: 16, y: 2)
                    .shadow(color: earned && starVisible[index] ? AppChrome.deepShadow.opacity(0.4) : .clear, radius: 8, y: 4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance log")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            statRow(title: "Time", value: formattedDuration(outcome.durationSeconds))
            statRow(title: "Efficiency rating", value: "\(outcome.efficiencyPercent)%")
            statRow(title: "Resources handled", value: "\(outcome.resourcesHandled)")
            if outcome.passed == false {
                Text("Adjust your approach and run the scenario again.")
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appChromeElevated(cornerRadius: 20)
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(Color.appTextPrimary)
                .font(.body.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func achievementBanner(_ badge: AchievementDefinition) -> some View {
        HStack(spacing: 12) {
            StarShape()
                .fill(Color.appBackground)
                .frame(width: 26, height: 26)
            VStack(alignment: .leading, spacing: 4) {
                Text("New milestone")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appBackground)
                Text(badge.title)
                    .font(.headline)
                    .foregroundStyle(Color.appBackground)
                Text(badge.description)
                    .font(.footnote)
                    .foregroundStyle(Color.appBackground.opacity(0.85))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppChrome.primaryCTA)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.appTextPrimary.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: AppChrome.deepShadow, radius: 16, x: 0, y: 10)
        .shadow(color: Color.appPrimary.opacity(0.35), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
    }

    private func bannerAchievement() -> AchievementDefinition? {
        guard let id = freshAchievementIDs.first else { return nil }
        return SimulationProgressStore.allAchievements.first { $0.id == id }
    }

    private func animateStars() {
        for index in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * DesignConstants.starStagger) {
                withAnimation(.spring(response: DesignConstants.springResponse, dampingFraction: DesignConstants.springDamping)) {
                    starVisible[index] = true
                }
            }
        }
    }

    private func prepareBanner() {
        guard bannerAchievement() != nil else { return }
        showBanner = true
        DispatchQueue.main.async {
            withAnimation(.spring(response: DesignConstants.springResponse, dampingFraction: DesignConstants.springDamping)) {
                bannerOffset = 0
            }
        }
    }

    private func formattedDuration(_ interval: TimeInterval) -> String {
        let seconds = Int(interval.rounded())
        let minutes = seconds / 60
        let rem = seconds % 60
        return String(format: "%dm %02ds", minutes, rem)
    }

    private func nextStage() -> ActiveStageRoute? {
        StageNavigator.nextStage(after: stage)
    }

    private func canPlay(_ route: ActiveStageRoute) -> Bool {
        progress.isLevelUnlocked(activity: route.activity, tier: route.tier, levelIndex: route.levelIndex)
    }

    private func goNext(_ route: ActiveStageRoute) {
        path.removeLast()
        path.append(BuildStackRoute.play(route))
    }

    private func retry() {
        path.removeLast()
        path.append(BuildStackRoute.play(stage))
    }

    private func backToLevels() {
        path.removeLast()
    }
}
