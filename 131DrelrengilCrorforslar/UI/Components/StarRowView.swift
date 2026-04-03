//
//  StarRowView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct StarRowView: View {
    let filled: Int
    let maximum: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<maximum, id: \.self) { index in
                let active = index < filled
                StarShape()
                    .fill(
                        active
                            ? LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.appTextSecondary.opacity(0.35), Color.appTextSecondary.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: 18, height: 18)
                    .shadow(color: active ? Color.appAccent.opacity(0.45) : .clear, radius: 4, x: 0, y: 2)
                    .shadow(color: active ? AppChrome.deepShadow.opacity(0.35) : .clear, radius: 2, x: 0, y: 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(filled) of \(maximum) stars"))
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        let points = 5
        for index in 0..<(points * 2) {
            let angle = CGFloat(index) * .pi / CGFloat(points) - .pi / 2
            let r = index.isMultiple(of: 2) ? radius : radius * 0.45
            let point = CGPoint(
                x: center.x + cos(angle) * r,
                y: center.y + sin(angle) * r
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
