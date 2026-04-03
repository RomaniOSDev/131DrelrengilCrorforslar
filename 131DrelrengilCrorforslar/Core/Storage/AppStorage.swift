//
//  AppStorage.swift
//  131DrelrengilCrorforslar
//

import Combine
import Foundation

extension Notification.Name {
    static let simulationProgressDidReset = Notification.Name("simulationProgressDidReset")
}

struct AchievementDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
}

@MainActor
final class SimulationProgressStore: ObservableObject {
    private let defaults: UserDefaults

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalPlaySeconds = "totalPlaySeconds"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let starsPrefix = "stars_v1_"
    }

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var totalPlaySeconds: TimeInterval
    @Published private(set) var totalActivitiesPlayed: Int

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalPlaySeconds = defaults.double(forKey: Keys.totalPlaySeconds)
        let played = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalActivitiesPlayed = played
    }

    func completeOnboarding() {
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
        hasSeenOnboarding = true
    }

    func stars(activity: ActivityKind, tier: DifficultyTier, levelIndex: Int) -> Int {
        let key = Self.starsKey(activity: activity, tier: tier, levelIndex: levelIndex)
        return defaults.integer(forKey: key)
    }

    func updateStarsIfHigher(activity: ActivityKind, tier: DifficultyTier, levelIndex: Int, stars: Int) {
        let key = Self.starsKey(activity: activity, tier: tier, levelIndex: levelIndex)
        let current = defaults.integer(forKey: key)
        let next = max(0, min(3, stars))
        if next > current {
            defaults.set(next, forKey: key)
            objectWillChange.send()
        }
    }

    func recordSessionCompletion(duration: TimeInterval, passed: Bool) {
        guard passed else { return }
        totalPlaySeconds += max(0, duration)
        totalActivitiesPlayed += 1
        defaults.set(totalPlaySeconds, forKey: Keys.totalPlaySeconds)
        defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed)
        objectWillChange.send()
    }

    func isLevelUnlocked(activity: ActivityKind, tier: DifficultyTier, levelIndex: Int) -> Bool {
        guard levelIndex >= 0, levelIndex < tier.levelsPerTier else { return false }
        switch tier {
        case .easy:
            if levelIndex == 0 { return true }
            return stars(activity: activity, tier: .easy, levelIndex: levelIndex - 1) >= 1
        case .normal:
            if levelIndex == 0 {
                return stars(activity: activity, tier: .easy, levelIndex: tier.levelsPerTier - 1) >= 1
            }
            return stars(activity: activity, tier: .normal, levelIndex: levelIndex - 1) >= 1
        case .hard:
            if levelIndex == 0 {
                return stars(activity: activity, tier: .normal, levelIndex: tier.levelsPerTier - 1) >= 1
            }
            return stars(activity: activity, tier: .hard, levelIndex: levelIndex - 1) >= 1
        }
    }

    func totalStarsAcrossAllActivities() -> Int {
        var sum = 0
        for activity in ActivityKind.allCases {
            for tier in DifficultyTier.allCases {
                for index in 0..<tier.levelsPerTier {
                    sum += stars(activity: activity, tier: tier, levelIndex: index)
                }
            }
        }
        return sum
    }

    func hasAnyPerfectThreeStarLevel() -> Bool {
        for activity in ActivityKind.allCases {
            for tier in DifficultyTier.allCases {
                for index in 0..<tier.levelsPerTier {
                    if stars(activity: activity, tier: tier, levelIndex: index) >= 3 {
                        return true
                    }
                }
            }
        }
        return false
    }

    func eachActivityHasAtLeastOneThreeStar() -> Bool {
        ActivityKind.allCases.allSatisfy { activity in
            DifficultyTier.allCases.contains { tier in
                (0..<tier.levelsPerTier).contains { index in
                    stars(activity: activity, tier: tier, levelIndex: index) >= 3
                }
            }
        }
    }

    func allLevelsClearedWithOneStar() -> Bool {
        ActivityKind.allCases.allSatisfy { activity in
            DifficultyTier.allCases.allSatisfy { tier in
                (0..<tier.levelsPerTier).allSatisfy { index in
                    stars(activity: activity, tier: tier, levelIndex: index) >= 1
                }
            }
        }
    }

    func achievementSnapshot() -> Set<String> {
        var set = Set<String>()
        if totalActivitiesPlayed >= 1 { set.insert("first_clear") }
        if totalStarsAcrossAllActivities() >= 10 { set.insert("star_collector") }
        if hasAnyPerfectThreeStarLevel() { set.insert("perfect_block") }
        if eachActivityHasAtLeastOneThreeStar() { set.insert("triple_focus") }
        if totalPlaySeconds >= 600 { set.insert("deep_run") }
        if totalActivitiesPlayed >= 20 { set.insert("veteran") }
        if allLevelsClearedWithOneStar() { set.insert("metro_complete") }
        return set
    }

    func stagesClearedWithAtLeastOneStar() -> Int {
        var count = 0
        for activity in ActivityKind.allCases {
            for tier in DifficultyTier.allCases {
                for index in 0..<tier.levelsPerTier {
                    if stars(activity: activity, tier: tier, levelIndex: index) >= 1 {
                        count += 1
                    }
                }
            }
        }
        return count
    }

    func totalStageCount() -> Int {
        ActivityKind.allCases.count * DifficultyTier.allCases.count * DifficultyTier.easy.levelsPerTier
    }

    func starsTotal(for activity: ActivityKind) -> Int {
        var sum = 0
        for tier in DifficultyTier.allCases {
            for index in 0..<tier.levelsPerTier {
                sum += stars(activity: activity, tier: tier, levelIndex: index)
            }
        }
        return sum
    }

    func unlockedMilestoneCount() -> Int {
        achievementSnapshot().count
    }

    static let allAchievements: [AchievementDefinition] = [
        AchievementDefinition(id: "first_clear", title: "First Blueprint", description: "Finish any scenario once."),
        AchievementDefinition(id: "star_collector", title: "Constellation", description: "Earn 10 stars across all scenarios."),
        AchievementDefinition(id: "perfect_block", title: "Flawless Block", description: "Score three stars on any single stage."),
        AchievementDefinition(id: "triple_focus", title: "Balanced Portfolio", description: "Earn three stars in each activity type."),
        AchievementDefinition(id: "deep_run", title: "Night Shift", description: "Accumulate 10 minutes of successful runs."),
        AchievementDefinition(id: "veteran", title: "Seasoned Planner", description: "Complete 20 successful scenarios."),
        AchievementDefinition(id: "metro_complete", title: "Full Grid", description: "Clear every stage with at least one star.")
    ]

    func resetAllProgress() {
        let keys = Array(defaults.dictionaryRepresentation().keys)
        for key in keys {
            if key == Keys.hasSeenOnboarding { continue }
            if key.hasPrefix(Keys.starsPrefix) || key == Keys.totalPlaySeconds || key == Keys.totalActivitiesPlayed {
                defaults.removeObject(forKey: key)
            }
        }
        totalPlaySeconds = 0
        totalActivitiesPlayed = 0
        objectWillChange.send()
        NotificationCenter.default.post(name: .simulationProgressDidReset, object: nil)
    }

    private static func starsKey(activity: ActivityKind, tier: DifficultyTier, levelIndex: Int) -> String {
        "\(Keys.starsPrefix)\(activity.rawValue)_\(tier.rawValue)_\(levelIndex)"
    }
}
