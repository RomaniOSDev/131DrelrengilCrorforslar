//
//  ActiveStageRoute.swift
//  131DrelrengilCrorforslar
//

import Foundation

struct ActiveStageRoute: Hashable {
    let activity: ActivityKind
    let tier: DifficultyTier
    let levelIndex: Int
}

enum BuildStackRoute: Hashable {
    case levels(ActivityKind)
    case play(ActiveStageRoute)
    case outcome(ActiveStageRoute, ActivitySessionOutcome, [String])
}

enum StageNavigator {
    static func nextStage(after stage: ActiveStageRoute) -> ActiveStageRoute? {
        if stage.levelIndex + 1 < stage.tier.levelsPerTier {
            return ActiveStageRoute(activity: stage.activity, tier: stage.tier, levelIndex: stage.levelIndex + 1)
        }
        let tiers = DifficultyTier.allCases
        guard let idx = tiers.firstIndex(of: stage.tier), idx + 1 < tiers.count else { return nil }
        let upcoming = tiers[idx + 1]
        return ActiveStageRoute(activity: stage.activity, tier: upcoming, levelIndex: 0)
    }
}
