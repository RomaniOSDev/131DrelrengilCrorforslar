//
//  ActivityKind.swift
//  131DrelrengilCrorforslar
//

import Foundation

enum ActivityKind: String, CaseIterable, Codable, Hashable {
    case urbanFlow
    case ecoBalance
    case resourceRush

    var titleKey: String {
        switch self {
        case .urbanFlow: return "Urban Flow"
        case .ecoBalance: return "Eco Balance"
        case .resourceRush: return "Resource Rush"
        }
    }

    var detailKey: String {
        switch self {
        case .urbanFlow:
            return "Tune corridors and junctions to keep movement smooth."
        case .ecoBalance:
            return "Balance districts and emissions for a healthier skyline."
        case .resourceRush:
            return "Review ledgers and steer the civic budget under pressure."
        }
    }
}
