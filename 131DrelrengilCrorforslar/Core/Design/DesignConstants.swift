//
//  DesignConstants.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

enum DesignConstants {
    static let minTapTarget: CGFloat = 44
    static let buttonHorizontalPadding: CGFloat = 16
    static let springResponse: Double = 0.6
    static let springDamping: Double = 0.8
    static let starStagger: Double = 0.15
    static let easeTransition: Animation = .easeInOut(duration: 0.35)

    static var spring: Animation {
        .spring(response: springResponse, dampingFraction: springDamping)
    }
}
