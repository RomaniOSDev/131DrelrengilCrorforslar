//
//  ResourceRushViewModel.swift
//  131DrelrengilCrorforslar
//

import Combine
import Foundation

@MainActor
final class ResourceRushViewModel: ObservableObject {
    struct LedgerLine: Identifiable, Hashable {
        let id = UUID()
        let caption: String
        let delta: Int
    }

    let tier: DifficultyTier
    let levelIndex: Int

    @Published private(set) var lines: [LedgerLine] = []
    @Published private(set) var balance: Int = 500
    @Published private(set) var cursor: Int = 0
    @Published private(set) var isComplete = false
    @Published private(set) var isFailed = false
    @Published private(set) var timeRemaining: TimeInterval

    private let lowerBound: Int
    private let upperBound: Int

    var displayLowerBound: Int { lowerBound }
    var displayUpperBound: Int { upperBound }
    private let initialDuration: TimeInterval
    private let startDate: Date
    private var timer: Timer?

    init(tier: DifficultyTier, levelIndex: Int) {
        self.tier = tier
        self.levelIndex = levelIndex
        self.initialDuration = Self.timerDuration(tier: tier, level: levelIndex)
        self.timeRemaining = Self.timerDuration(tier: tier, level: levelIndex)
        self.startDate = Date()
        let span = 140 - levelIndex * 12
        self.lowerBound = 420 - levelIndex * 15
        self.upperBound = lowerBound + span + (tier == .hard ? 40 : tier == .normal ? 25 : 10)
        rebuildLines()
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

    func approveCurrent() {
        guard isComplete == false, isFailed == false, cursor < lines.count else { return }
        apply(delta: lines[cursor].delta)
        advance()
    }

    func declineCurrent() {
        guard isComplete == false, isFailed == false, cursor < lines.count else { return }
        let penalty: Int
        switch tier {
        case .easy: penalty = 0
        case .normal: penalty = -12
        case .hard: penalty = -22
        }
        apply(delta: penalty)
        advance()
    }

    func makeOutcome() -> ActivitySessionOutcome {
        let duration = Date().timeIntervalSince(startDate)
        let efficiency = Self.efficiencyScore(balance: balance, lower: lowerBound, upper: upperBound)
        let handled = cursor
        let stars = Self.stars(passed: isComplete, balance: balance, lower: lowerBound, upper: upperBound, timeLeft: timeRemaining, total: initialDuration)
        return ActivitySessionOutcome(
            starsEarned: stars,
            durationSeconds: duration,
            efficiencyPercent: efficiency,
            resourcesHandled: handled,
            passed: isComplete
        )
    }

    private func tick() {
        guard isComplete == false, isFailed == false else { return }
        timeRemaining -= 0.1
        if timeRemaining <= 0 {
            timeRemaining = 0
            if cursor < lines.count {
                isFailed = true
            } else {
                evaluateFinal()
            }
            stop()
        }
    }

    private func apply(delta: Int) {
        balance += delta
        if balance < lowerBound - 40 || balance > upperBound + 60 {
            isFailed = true
            stop()
        }
    }

    private func advance() {
        cursor += 1
        if cursor >= lines.count {
            evaluateFinal()
        }
    }

    private func evaluateFinal() {
        stop()
        if isFailed { return }
        if balance >= lowerBound && balance <= upperBound {
            isComplete = true
        } else {
            isFailed = true
        }
    }

    private func rebuildLines() {
        var generated: [LedgerLine] = []
        let count = 8 + levelIndex
        for index in 0..<count {
            generated.append(Self.randomLine(tier: tier, level: levelIndex, seed: index))
        }
        lines = generated
        cursor = 0
    }

    private static func randomLine(tier: DifficultyTier, level: Int, seed: Int) -> LedgerLine {
        let volatility = tier == .hard ? 28 : tier == .normal ? 18 : 10
        let base = [120, 95, -60, -45, 80, -30, 110, -55, 70, -40]
        let raw = base[(seed + level) % base.count]
        let jitter = Int.random(in: -volatility...volatility)
        let delta = (raw + jitter) * (tier == .hard && seed.isMultiple(of: 3) ? 2 : 1)
        let caption: String
        if delta >= 0 {
            caption = "Incoming civic support package #\(seed + 1)"
        } else {
            caption = "Infrastructure upkeep request #\(seed + 1)"
        }
        return LedgerLine(caption: caption, delta: delta)
    }

    private static func timerDuration(tier: DifficultyTier, level: Int) -> TimeInterval {
        let base: TimeInterval
        switch tier {
        case .easy: base = 55
        case .normal: base = 48
        case .hard: base = 42
        }
        return max(28, base - TimeInterval(level) * 4)
    }

    private static func efficiencyScore(balance: Int, lower: Int, upper: Int) -> Int {
        let mid = (lower + upper) / 2
        let span = max(1, upper - lower)
        let closeness = 100 - abs(balance - mid) * 100 / span
        return min(100, max(0, closeness))
    }

    private static func stars(passed: Bool, balance: Int, lower: Int, upper: Int, timeLeft: TimeInterval, total: TimeInterval) -> Int {
        guard passed else { return 0 }
        let mid = (lower + upper) / 2
        let span = max(1, upper - lower)
        let centered = 1 - Double(abs(balance - mid)) / Double(span)
        let timeScore = total > 0 ? timeLeft / total : 0
        let composite = centered * 0.65 + timeScore * 0.35
        if composite >= 0.74 { return 3 }
        if composite >= 0.48 { return 2 }
        return 1
    }
}
