//
//  ResourceRushView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct ResourceRushView: View {
    @StateObject private var viewModel: ResourceRushViewModel
    @Binding var path: NavigationPath
    private let stage: ActiveStageRoute
    @EnvironmentObject private var progress: SimulationProgressStore
    @State private var hasFinished = false

    init(stage: ActiveStageRoute, path: Binding<NavigationPath>) {
        self.stage = stage
        self._path = path
        _viewModel = StateObject(wrappedValue: ResourceRushViewModel(tier: stage.tier, levelIndex: stage.levelIndex))
    }

    var body: some View {
        ZStack {
            AppScreenChromeBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    balanceCard
                    ledgerList
                    actions
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
            Text("Resource Rush")
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
            Text("Decision window")
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(String(format: "%.0fs", viewModel.timeRemaining))
                .foregroundStyle(Color.appPrimary)
                .font(.headline.monospacedDigit())
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Civic balance")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Keep the ledger inside the shaded band by approving supportive entries and declining risky ones.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
            HStack {
                Text("Current")
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text("\(viewModel.balance) units")
                    .foregroundStyle(Color.appPrimary)
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            GeometryReader { geo in
                let lower = viewModel.displayLowerBound
                let upper = viewModel.displayUpperBound
                let span = CGFloat(upper - lower)
                let marker = CGFloat(viewModel.balance - lower) / max(1, span)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppChrome.recessed)
                        .overlay(Capsule().strokeBorder(AppChrome.recessedRim, lineWidth: 1))
                        .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 3, x: 0, y: 2)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.45), Color.appPrimary.opacity(0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.horizontal, geo.size.width * 0.15)
                    Circle()
                        .fill(AppChrome.primaryCTA)
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appTextPrimary.opacity(0.35), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .frame(width: 16, height: 16)
                        .shadow(color: AppChrome.deepShadow.opacity(0.45), radius: 4, x: 0, y: 2)
                        .offset(x: min(max(8, marker * geo.size.width), geo.size.width - 8))
                }
            }
            .frame(height: 18)
        }
        .padding(16)
        .appChromeElevated(cornerRadius: 18)
    }

    private var ledgerList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Incoming ledger lines")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            ForEach(Array(viewModel.lines.enumerated()), id: \.offset) { item in
                ledgerRow(offset: item.offset, line: item.element)
            }
        }
        .padding(16)
        .appChromeElevated(cornerRadius: 18)
    }

    private func ledgerRow(offset: Int, line: ResourceRushViewModel.LedgerLine) -> some View {
        let active = offset == viewModel.cursor && viewModel.isFailed == false && viewModel.isComplete == false
        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(line.caption)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text(line.delta >= 0 ? "+\(line.delta)" : "\(line.delta)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(line.delta >= 0 ? Color.appAccent : Color.appPrimary)
            }
            if active {
                Capsule()
                    .fill(AppChrome.progressFill)
                    .frame(height: 4)
                    .shadow(color: Color.appAccent.opacity(0.35), radius: 4, x: 0, y: 1)
            }
        }
        .padding(12)
        .background(
            Group {
                if active {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppChrome.recessed)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AppChrome.cardEdge, lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface.opacity(0.58), Color.appBackground.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(AppChrome.recessedRim, lineWidth: 1)
                        )
                }
            }
        )
        .shadow(color: active ? AppChrome.deepShadow.opacity(0.35) : .clear, radius: 6, x: 0, y: 3)
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.approveCurrent()
            } label: {
                Text("Approve line")
            }
            .buttonStyle(PrimaryProminentButtonStyle())
            .disabled(viewModel.cursor >= viewModel.lines.count || viewModel.isFailed || viewModel.isComplete)

            Button {
                viewModel.declineCurrent()
            } label: {
                Text("Decline line")
            }
            .buttonStyle(SecondaryOutlineButtonStyle())
            .disabled(viewModel.cursor >= viewModel.lines.count || viewModel.isFailed || viewModel.isComplete)
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
