//
//  DifficultyTier.swift
//  131DrelrengilCrorforslar
//

import Foundation

enum DifficultyTier: Int, CaseIterable, Codable, Hashable {
    case easy = 0
    case normal = 1
    case hard = 2

    var titleKey: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }

    var levelsPerTier: Int { 3 }
}
