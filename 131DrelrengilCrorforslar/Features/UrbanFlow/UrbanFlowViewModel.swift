//
//  UrbanFlowViewModel.swift
//  131DrelrengilCrorforslar
//

import Combine
import CoreGraphics
import Foundation
import SwiftUI

@MainActor
final class UrbanFlowViewModel: ObservableObject {
    let tier: DifficultyTier
    let levelIndex: Int

    @Published var segmentCenters: [CGPoint]
    @Published var segmentAngles: [Angle]
    @Published private(set) var timeRemaining: TimeInterval
    @Published private(set) var flowQuality: Double = 0
    @Published private(set) var parcelsMoved: Double = 0
    @Published private(set) var phase: Double = 0
    @Published private(set) var isComplete = false
    @Published private(set) var isFailed = false

    private(set) var alignmentTargets: [CGPoint]
    let parcelQuota: Double
    private let initialDuration: TimeInterval
    private var timer: AnyCancellable?
    private let startDate: Date

    init(tier: DifficultyTier, levelIndex: Int) {
        self.tier = tier
        self.levelIndex = levelIndex
        let count = Self.segmentCount(for: tier)
        self.alignmentTargets = (0..<count).map { _ in
            CGPoint(x: Double.random(in: 0.18...0.82), y: Double.random(in: 0.22...0.82))
        }
        self.segmentCenters = (0..<count).map { _ in
            CGPoint(x: Double.random(in: 0.12...0.88), y: Double.random(in: 0.18...0.88))
        }
        let angleChoices: [Angle] = [.degrees(0), .degrees(90), .degrees(180), .degrees(270)]
        self.segmentAngles = (0..<count).map { _ in angleChoices.randomElement() ?? .degrees(0) }
        let duration = Self.duration(for: tier, level: levelIndex)
        self.initialDuration = duration
        self.timeRemaining = duration
        self.parcelQuota = Self.quota(for: tier, level: levelIndex)
        self.startDate = Date()
    }

    func start() {
        guard timer == nil, isComplete == false, isFailed == false else { return }
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func dragSegment(index: Int, normalizedPoint: CGPoint, arenaSize: CGSize) {
        guard index >= 0, index < segmentCenters.count else { return }
        let margin: CGFloat = 0.08
        let nx = min(max(normalizedPoint.x, margin), 1 - margin)
        let ny = min(max(normalizedPoint.y, margin), 1 - margin)
        segmentCenters[index] = CGPoint(x: nx, y: ny)
        _ = arenaSize
    }

    func rotateSegment(index: Int) {
        guard tier != .easy, index >= 0, index < segmentAngles.count else { return }
        segmentAngles[index] = .degrees(segmentAngles[index].degrees + 90)
    }

    func makeOutcome() -> ActivitySessionOutcome {
        let duration = Date().timeIntervalSince(startDate)
        let efficiency = Int((flowQuality * 100).rounded())
        let handled = Int(parcelsMoved.rounded())
        let stars = Self.stars(forPassed: isComplete, timeLeft: timeRemaining, total: initialDuration, quality: flowQuality)
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
        timeRemaining -= 0.05
        phase += 0.08
        if timeRemaining <= 0 {
            timeRemaining = 0
            isFailed = true
            stop()
            return
        }
        recalcQuality()
        let throughput = parcelsPerTick()
        parcelsMoved += throughput
        if parcelsMoved >= parcelQuota {
            isComplete = true
            stop()
        }
    }

    private func parcelsPerTick() -> Double {
        var q = flowQuality
        if tier == .hard {
            for center in segmentCenters {
                let hx = 0.35 + Double(levelIndex) * 0.08
                let hy = 0.55
                let d = hypot(center.x - hx, center.y - hy)
                if d < 0.12 {
                    q *= 0.72
                }
            }
        }
        if tier == .normal {
            let alignment = alignmentBonus()
            q *= 0.85 + 0.15 * alignment
        }
        let base: Double
        switch tier {
        case .easy: base = 2.4
        case .normal: base = 2.1
        case .hard: base = 1.9
        }
        return base * q * 0.05
    }

    private func alignmentBonus() -> Double {
        guard segmentAngles.count == segmentCenters.count else { return 0 }
        var score = 0.0
        for index in segmentAngles.indices {
            let target = Double((index * 47 + levelIndex * 13) % 360)
            let current = segmentAngles[index].degrees.truncatingRemainder(dividingBy: 360)
            let delta = abs(current - target)
            let wrapped = min(delta, 360.0 - delta)
            score += max(0, 1 - wrapped / 90)
        }
        return score / Double(max(1, segmentAngles.count))
    }

    private func recalcQuality() {
        guard !alignmentTargets.isEmpty else {
            flowQuality = 0
            return
        }
        var total = 0.0
        for index in alignmentTargets.indices {
            let dx = Double(segmentCenters[index].x - alignmentTargets[index].x)
            let dy = Double(segmentCenters[index].y - alignmentTargets[index].y)
            let delta = hypot(dx, dy)
            total += max(0, 1 - min(1, delta / 0.45))
        }
        flowQuality = total / Double(alignmentTargets.count)
    }

    private static func segmentCount(for tier: DifficultyTier) -> Int {
        switch tier {
        case .easy: return 3
        case .normal: return 5
        case .hard: return 7
        }
    }

    private static func duration(for tier: DifficultyTier, level: Int) -> TimeInterval {
        let base: TimeInterval
        switch tier {
        case .easy: base = 48
        case .normal: base = 42
        case .hard: base = 36
        }
        return max(24, base - TimeInterval(level) * 3)
    }

    private static func quota(for tier: DifficultyTier, level: Int) -> Double {
        let base: Double
        switch tier {
        case .easy: base = 38
        case .normal: base = 48
        case .hard: base = 58
        }
        return base + Double(level) * 4
    }

    private static func stars(forPassed passed: Bool, timeLeft: TimeInterval, total: TimeInterval, quality: Double) -> Int {
        guard passed else { return 0 }
        let timeScore = total > 0 ? timeLeft / total : 0
        let composite = timeScore * 0.55 + quality * 0.45
        if composite >= 0.72 { return 3 }
        if composite >= 0.45 { return 2 }
        return 1
    }
}
