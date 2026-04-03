//
//  EcoBalanceView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct EcoBalanceView: View {
    @StateObject private var viewModel: EcoBalanceViewModel
    @Binding var path: NavigationPath
    private let stage: ActiveStageRoute
    @EnvironmentObject private var progress: SimulationProgressStore
    @State private var hasFinished = false

    init(stage: ActiveStageRoute, path: Binding<NavigationPath>) {
        self.stage = stage
        self._path = path
        _viewModel = StateObject(wrappedValue: EcoBalanceViewModel(tier: stage.tier, levelIndex: stage.levelIndex))
    }

    var body: some View {
        ZStack {
            AppScreenChromeBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    sliders
                    metrics
                    commitSection
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
            Text("Eco Balance")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 2, x: 0, y: 1)
            Text("\(stage.tier.titleKey) · Stage \(stage.levelIndex + 1)")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
            timerRow
        }
        .padding(16)
        .appChromeElevated(cornerRadius: 20)
    }

    private var timerRow: some View {
        HStack {
            Text("Planning window")
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(String(format: "%.0fs", viewModel.timeRemaining))
                .foregroundStyle(Color.appPrimary)
                .font(.headline.monospacedDigit())
        }
    }

    private var sliders: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("District mix")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            sliderRow(title: "Canopy cover", value: viewModel.canopyShare) { viewModel.adjustCanopy($0) }
            sliderRow(title: "Residential share", value: viewModel.housingShare) { viewModel.adjustHousing($0) }
            if viewModel.tier != .easy {
                sliderRow(title: "Industrial footprint", value: viewModel.industryShare) { viewModel.adjustIndustry($0) }
            }
            if viewModel.tier == .hard {
                sliderRow(title: "Power draw", value: viewModel.powerLoad) { viewModel.adjustPower($0) }
                sliderRow(title: "Waste load", value: viewModel.residueLoad) { viewModel.adjustResidue($0) }
            }
        }
        .padding(16)
        .appChromeElevated(cornerRadius: 18)
    }

    private func sliderRow(title: String, value: Double, onChange: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(Int(value.rounded())) pts")
                    .foregroundStyle(Color.appTextPrimary)
                    .font(.subheadline.monospacedDigit())
            }
            Slider(value: Binding(
                get: { value },
                set: { onChange($0) }
            ), in: 0...100, step: 1)
            .tint(Color.appAccent)
            .frame(minHeight: DesignConstants.minTapTarget)
        }
    }

    private var metrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live indicators")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            metricRow(title: "Air strain index", value: viewModel.airIndex, inverted: true)
            metricRow(title: "Wellness composite", value: viewModel.wellnessIndex * 100, inverted: false)
        }
        .padding(16)
        .appChromeElevated(cornerRadius: 18)
    }

    private func metricRow(title: String, value: Double, inverted: Bool) -> some View {
        let clamped = min(100, max(0, value))
        let healthy = inverted ? clamped < 55 : clamped > 55
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(Int(clamped.rounded()))")
                    .foregroundStyle(healthy ? Color.appAccent : Color.appPrimary)
                    .font(.subheadline.weight(.semibold))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppChrome.recessed)
                        .overlay(Capsule().strokeBorder(AppChrome.recessedRim, lineWidth: 1))
                    Capsule()
                        .fill(
                            healthy
                                ? LinearGradient(
                                    colors: [Color.appAccent, Color.appPrimary.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [Color.appPrimary.opacity(0.75), Color.appPrimary.opacity(0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
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
                        .frame(width: max(10, CGFloat(clamped / 100) * geo.size.width))
                }
            }
            .frame(height: 10)
        }
    }

    private var commitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lock the plan when every indicator sits inside the scenario brief.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
            Button {
                viewModel.commitPlan()
            } label: {
                Text("Commit balanced plan")
            }
            .buttonStyle(PrimaryProminentButtonStyle())
        }
        .padding(.bottom, 28)
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
