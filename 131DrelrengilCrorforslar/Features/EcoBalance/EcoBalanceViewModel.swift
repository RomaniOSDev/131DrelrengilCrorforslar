//
//  EcoBalanceViewModel.swift
//  131DrelrengilCrorforslar
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class EcoBalanceViewModel: ObservableObject {
    let tier: DifficultyTier
    let levelIndex: Int

    @Published var canopyShare: Double
    @Published var housingShare: Double
    @Published var industryShare: Double
    @Published private(set) var airIndex: Double = 0
    @Published private(set) var wellnessIndex: Double = 0
    @Published private(set) var powerLoad: Double = 0
    @Published private(set) var residueLoad: Double = 0
    @Published private(set) var isComplete = false
    @Published private(set) var isFailed = false
    @Published private(set) var timeRemaining: TimeInterval

    private let initialDuration: TimeInterval
    private let startDate: Date
    private var timer: Timer?

    private let canopyTarget: ClosedRange<Double>
    private let housingTarget: ClosedRange<Double>
    private let industryCap: Double
    private let airCeil: Double
    private let powerCeil: Double
    private let residueCeil: Double

    init(tier: DifficultyTier, levelIndex: Int) {
        self.tier = tier
        self.levelIndex = levelIndex
        self.initialDuration = Self.timerDuration(tier: tier, level: levelIndex)
        self.timeRemaining = Self.timerDuration(tier: tier, level: levelIndex)
        self.startDate = Date()

        let tighten = Double(levelIndex) * 3
        self.canopyTarget = Self.range(base: 42, spread: 14, tighten: tighten)
        self.housingTarget = Self.range(base: 34, spread: 12, tighten: tighten)
        self.industryCap = tier == .easy ? 0 : max(10, 28 - tighten * 0.4)
        self.airCeil = tier == .hard ? 52 - tighten * 0.5 : 68 - tighten * 0.4
        self.powerCeil = tier == .hard ? 60 : 85
        self.residueCeil = tier == .hard ? 55 : 80

        self.canopyShare = 45
        self.housingShare = tier == .easy ? 55 : 35
        self.industryShare = tier == .easy ? 0 : 20
        rebalanceShares()
        recalc()
    }

    func start() {
        timer?.invalidate()
        guard isComplete == false, isFailed == false else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func adjustCanopy(_ value: Double) {
        canopyShare = min(100, max(0, value))
        rebalanceShares()
        recalc()
    }

    func adjustHousing(_ value: Double) {
        housingShare = min(100, max(0, value))
        rebalanceShares()
        recalc()
    }

    func adjustIndustry(_ value: Double) {
        guard tier != .easy else { return }
        industryShare = min(100, max(0, value))
        rebalanceShares()
        recalc()
    }

    func adjustPower(_ value: Double) {
        guard tier == .hard else { return }
        powerLoad = min(100, max(0, value))
        recalc()
    }

    func adjustResidue(_ value: Double) {
        guard tier == .hard else { return }
        residueLoad = min(100, max(0, value))
        recalc()
    }

    func commitPlan() {
        guard isFailed == false else { return }
        recalc()
        if isBalanced() {
            isComplete = true
            stop()
        } else {
            isFailed = true
            stop()
        }
    }

    func makeOutcome() -> ActivitySessionOutcome {
        let duration = Date().timeIntervalSince(startDate)
        let efficiency = Int((wellnessIndex * 100).rounded())
        let handled = Int((canopyShare + housingShare + industryShare).rounded())
        let stars = Self.stars(passed: isComplete, wellness: wellnessIndex, air: airIndex, timeLeft: timeRemaining, total: initialDuration)
        return ActivitySessionOutcome(
            starsEarned: stars,
            durationSeconds: duration,
            efficiencyPercent: min(100, max(0, efficiency)),
            resourcesHandled: handled,
            passed: isComplete
        )
    }

    private func tick() {
        guard isComplete == false, isFailed == false else { return }
        timeRemaining -= 0.1
        if timeRemaining <= 0 {
            timeRemaining = 0
            isFailed = true
            stop()
        }
    }

    private func rebalanceShares() {
        switch tier {
        case .easy:
            housingShare = 100 - canopyShare
            industryShare = 0
        case .normal, .hard:
            let sum = canopyShare + housingShare + industryShare
            guard sum > 0 else { return }
            if sum != 100 {
                let scale = 100 / sum
                canopyShare *= scale
                housingShare *= scale
                industryShare *= scale
            }
        }
    }

    private func recalc() {
        airIndex = industryShare * 1.15 - canopyShare * 0.65 + Double(levelIndex)
        wellnessIndex = (canopyShare / 100) * 0.45 + (housingShare / 100) * 0.35 + max(0, 1 - airIndex / 120) * 0.2
        if tier == .hard {
            wellnessIndex *= max(0.35, 1 - (powerLoad / 220) - (residueLoad / 240))
        }
    }

    private func isBalanced() -> Bool {
        recalc()
        let canopyOK = canopyTarget.contains(canopyShare)
        let housingOK = housingTarget.contains(housingShare)
        let industryOK = tier == .easy || industryShare <= industryCap
        let airOK = airIndex <= airCeil
        let powerOK = tier != .hard || powerLoad <= powerCeil
        let residueOK = tier != .hard || residueLoad <= residueCeil
        return canopyOK && housingOK && industryOK && airOK && powerOK && residueOK
    }

    private static func timerDuration(tier: DifficultyTier, level: Int) -> TimeInterval {
        let base: TimeInterval
        switch tier {
        case .easy: base = 70
        case .normal: base = 60
        case .hard: base = 50
        }
        return max(30, base - TimeInterval(level) * 5)
    }

    private static func range(base: Double, spread: Double, tighten: Double) -> ClosedRange<Double> {
        let half = max(4, (spread - tighten) / 2)
        let center = base + min(6, tighten * 0.2)
        return (center - half)...(center + half)
    }

    private static func stars(passed: Bool, wellness: Double, air: Double, timeLeft: TimeInterval, total: TimeInterval) -> Int {
        guard passed else { return 0 }
        let timeScore = total > 0 ? timeLeft / total : 0
        let airScore = max(0, 1 - air / 90)
        let composite = wellness * 0.5 + airScore * 0.25 + timeScore * 0.25
        if composite >= 0.78 { return 3 }
        if composite >= 0.52 { return 2 }
        return 1
    }
}
