//
//  ActivitySessionOutcome.swift
//  131DrelrengilCrorforslar
//

import Foundation

struct ActivitySessionOutcome: Hashable {
    let starsEarned: Int
    let durationSeconds: TimeInterval
    let efficiencyPercent: Int
    let resourcesHandled: Int
    let passed: Bool
}
