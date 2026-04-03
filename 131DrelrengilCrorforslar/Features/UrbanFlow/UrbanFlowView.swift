//
//  UrbanFlowView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct UrbanFlowView: View {
    @StateObject private var viewModel: UrbanFlowViewModel
    @Binding var path: NavigationPath
    private let stage: ActiveStageRoute
    @EnvironmentObject private var progress: SimulationProgressStore
    @State private var hasFinished = false

    init(stage: ActiveStageRoute, path: Binding<NavigationPath>) {
        self.stage = stage
        self._path = path
        _viewModel = StateObject(wrappedValue: UrbanFlowViewModel(tier: stage.tier, levelIndex: stage.levelIndex))
    }

    var body: some View {
        ZStack {
            AppScreenChromeBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    flowArena
                    controls
                    legend
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .onChange(of: viewModel.isComplete) { completed in
            if completed {
                finalizeSession()
            }
        }
        .onChange(of: viewModel.isFailed) { failed in
            if failed {
                finalizeSession()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Urban Flow")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 2, x: 0, y: 1)
            Text("\(stage.tier.titleKey) · Stage \(stage.levelIndex + 1)")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
            ParcelProgressBar(value: viewModel.parcelsMoved, quota: viewModel.parcelQuota, label: "Parcels cleared")
            timerRow
        }
        .padding(16)
        .appChromeElevated(cornerRadius: 20)
    }

    private var timerRow: some View {
        HStack {
            Text("Time remaining")
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(String(format: "%.0fs", viewModel.timeRemaining))
                .foregroundStyle(Color.appPrimary)
                .font(.headline.monospacedDigit())
        }
    }

    private var flowArena: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(AppChrome.surfaceRelief)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(AppChrome.cardEdge, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(AppChrome.innerSheen)
                    )
                Canvas { context, canvasSize in
                    drawTargets(context: &context, size: canvasSize)
                    drawMotionDots(context: &context, size: canvasSize)
                }
                ForEach(Array(viewModel.segmentCenters.indices), id: \.self) { index in
                    FlowSegmentDraggable(
                        index: index,
                        arenaSize: size,
                        viewModel: viewModel
                    )
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: AppChrome.deepShadow, radius: 20, x: 0, y: 12)
        .shadow(color: AppChrome.glowShadow, radius: 12, x: 0, y: 6)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Flow quality")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            ParcelProgressBar(value: viewModel.flowQuality * 100, quota: 100, label: "Smoothness index", percentStyle: true)
            Text("Drag segments toward the glowing guides. In higher tiers, use the rotate chip to align one-way flow.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(16)
        .appChromeElevated(cornerRadius: 18)
    }

    private var legend: some View {
        Text("Hard stages highlight congestion wells—keep segments away to protect throughput.")
            .font(.footnote)
            .foregroundStyle(Color.appTextSecondary)
            .padding(.bottom, 24)
    }

    private func drawTargets(context: inout GraphicsContext, size: CGSize) {
        for target in viewModel.alignmentTargets {
            let center = CGPoint(x: target.x * size.width, y: target.y * size.height)
            let rect = CGRect(x: center.x - 22, y: center.y - 14, width: 44, height: 28)
            let rounded = Path(roundedRect: rect, cornerRadius: 8)
            context.stroke(rounded, with: .color(Color.appAccent.opacity(0.65)), lineWidth: 2)
        }
        if viewModel.tier == .hard {
            let hotspot = CGPoint(x: (0.35 + CGFloat(stage.levelIndex) * 0.08) * size.width, y: 0.55 * size.height)
            let zone = Path(ellipseIn: CGRect(x: hotspot.x - 40, y: hotspot.y - 40, width: 80, height: 80))
            context.fill(zone, with: .color(Color.appPrimary.opacity(0.12)))
        }
    }

    private func drawMotionDots(context: inout GraphicsContext, size: CGSize) {
        guard viewModel.segmentCenters.count > 1 else { return }
        let centers = viewModel.segmentCenters.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
        for index in centers.indices.dropLast() {
            let start = centers[index]
            let end = centers[index + 1]
            let t = (sin(viewModel.phase + Double(index)) + 1) / 2
            let pos = CGPoint(x: start.x + (end.x - start.x) * t, y: start.y + (end.y - start.y) * t)
            let dot = Path(ellipseIn: CGRect(x: pos.x - 4, y: pos.y - 4, width: 8, height: 8))
            context.fill(dot, with: .color(Color.appAccent))
        }
    }

    private func finalizeSession() {
        guard hasFinished == false else { return }
        hasFinished = true
        viewModel.stop()
        let outcome = viewModel.makeOutcome()
        let before = progress.achievementSnapshot()
        if outcome.passed {
            progress.updateStarsIfHigher(activity: stage.activity, tier: stage.tier, levelIndex: stage.levelIndex, stars: outcome.starsEarned)
            progress.recordSessionCompletion(duration: outcome.durationSeconds, passed: true)
        }
        let after = progress.achievementSnapshot()
        let fresh = Array(after.subtracting(before)).sorted()
        path.removeLast()
        path.append(BuildStackRoute.outcome(stage, outcome, fresh))
    }
}

private struct FlowSegmentDraggable: View {
    let index: Int
    let arenaSize: CGSize
    @ObservedObject var viewModel: UrbanFlowViewModel
    @GestureState private var dragTranslation: CGSize = .zero

    var body: some View {
        let base = viewModel.segmentCenters[index]
        let dragPoint = CGPoint(
            x: base.x * arenaSize.width + dragTranslation.width,
            y: base.y * arenaSize.height + dragTranslation.height
        )
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary.opacity(0.5), Color.appPrimary.opacity(0.22)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Rectangle()
                        .fill(AppChrome.progressFill)
                        .frame(width: 48, height: 3)
                )
                .frame(width: 86, height: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(AppChrome.cardEdge, lineWidth: 1)
                )
                .shadow(color: AppChrome.deepShadow.opacity(0.45), radius: 5, x: 0, y: 3)
                .rotationEffect(viewModel.segmentAngles[safe: index] ?? .degrees(0))
            if viewModel.tier != .easy {
                Button {
                    viewModel.rotateSegment(index: index)
                } label: {
                    Text("Turn")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.appBackground)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule()
                                .fill(AppChrome.primaryCTA)
                                .overlay(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.appTextPrimary.opacity(0.2), Color.clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                )
                        )
                        .shadow(color: AppChrome.deepShadow.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .offset(y: 34)
                .frame(minHeight: DesignConstants.minTapTarget)
            }
        }
        .position(dragPoint)
        .gesture(
            DragGesture()
                .updating($dragTranslation) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    let nx = base.x + value.translation.width / arenaSize.width
                    let ny = base.y + value.translation.height / arenaSize.height
                    viewModel.dragSegment(index: index, normalizedPoint: CGPoint(x: nx, y: ny), arenaSize: arenaSize)
                }
        )
    }
}

private struct ParcelProgressBar: View {
    let value: Double
    let quota: Double
    let label: String
    var percentStyle: Bool = false

    var body: some View {
        let progress = min(1, value / max(quota, 1))
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                if percentStyle {
                    Text("\(Int((progress * 100).rounded()))%")
                        .foregroundStyle(Color.appPrimary)
                        .font(.subheadline.weight(.semibold))
                } else {
                    Text("\(Int(value.rounded())) / \(Int(quota.rounded()))")
                        .foregroundStyle(Color.appPrimary)
                        .font(.subheadline.weight(.semibold))
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppChrome.recessed)
                        .overlay(Capsule().strokeBorder(AppChrome.recessedRim, lineWidth: 1))
                        .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 3, x: 0, y: 2)
                    Capsule()
                        .fill(AppChrome.progressFill)
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appTextPrimary.opacity(0.22), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        )
                        .frame(width: max(8, CGFloat(progress) * geo.size.width))
                }
            }
            .frame(height: 12)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
