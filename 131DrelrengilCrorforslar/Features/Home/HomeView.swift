//
//  HomeView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progress: SimulationProgressStore
    @Binding var selectedTab: Int
    @Binding var buildDeepLink: ActivityKind?

    @State private var heroPulse = false

    private var totalStages: Int { progress.totalStageCount() }
    private var clearedStages: Int { progress.stagesClearedWithAtLeastOneStar() }
    private var metroProgress: Double {
        guard totalStages > 0 else { return 0 }
        return Double(clearedStages) / Double(totalStages)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppScreenChromeBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        heroHeader
                        metroProgressCard
                        statGrid
                        scenariosSection
                        milestonesStrip
                        maintenanceCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .padding(.bottom, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                heroPulse.toggle()
            }
        }
    }

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AppChrome.heroFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(AppChrome.cardEdge, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(AppChrome.innerSheen)
                )
                .frame(height: 168)
                .overlay(alignment: .topTrailing) {
                    HomeHeroCanvas(pulse: heroPulse)
                        .frame(width: 160, height: 140)
                        .padding(.trailing, 8)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("Planning desk")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Shape corridors, balance districts, and steer the civic ledger from one place.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: AppChrome.deepShadow, radius: 22, x: 0, y: 14)
        .shadow(color: AppChrome.glowShadow, radius: 14, x: 0, y: 8)
    }

    private var metroProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Metro progress")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(clearedStages)/\(totalStages)")
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.appAccent)
            }
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppChrome.recessed)
                    .overlay(
                        Capsule()
                            .strokeBorder(AppChrome.recessedRim, lineWidth: 1)
                    )
                    .frame(height: 14)
                    .shadow(color: AppChrome.deepShadow.opacity(0.45), radius: 4, x: 0, y: 3)
                GeometryReader { geo in
                    Capsule()
                        .fill(AppChrome.progressFill)
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appTextPrimary.opacity(0.25), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        )
                        .frame(width: max(12, CGFloat(metroProgress) * geo.size.width))
                }
                .frame(height: 14)
            }
            .animation(DesignConstants.spring, value: metroProgress)

            Text(progressHint)
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .appChromeElevated(cornerRadius: 20)
    }

    private var progressHint: String {
        if clearedStages == 0 {
            return "Open a scenario and clear any stage to start filling the grid."
        }
        if clearedStages >= totalStages {
            return "Every stage shows at least one star—time to chase perfect runs."
        }
        return "Stages with at least one star count toward this bar."
    }

    private var statGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            statTile(
                title: "Stars",
                value: "\(progress.totalStarsAcrossAllActivities())",
                caption: "Across all tiers",
                accent: Color.appAccent
            )
            statTile(
                title: "Runs",
                value: "\(progress.totalActivitiesPlayed)",
                caption: "Successful clears",
                accent: Color.appPrimary
            )
            statTile(
                title: "Focus time",
                value: formattedTime(progress.totalPlaySeconds),
                caption: "Successful runs only",
                accent: Color.appAccent
            )
            statTile(
                title: "Milestones",
                value: "\(progress.unlockedMilestoneCount())/\(SimulationProgressStore.allAchievements.count)",
                caption: "Unlocked",
                accent: Color.appPrimary
            )
        }
    }

    private func statTile(title: String, value: String, caption: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Text(caption)
                .font(.caption2)
                .foregroundStyle(accent.opacity(0.9))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .appChromeAccentElevated(cornerRadius: 18, accent: accent)
    }

    private var scenariosSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Scenarios")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Button {
                    buildDeepLink = nil
                    selectedTab = 1
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(minHeight: DesignConstants.minTapTarget)
            }

            VStack(spacing: 12) {
                ForEach(ActivityKind.allCases, id: \.self) { kind in
                    scenarioRow(kind: kind)
                }
            }

            Button {
                buildDeepLink = nil
                selectedTab = 1
            } label: {
                Text("Open scenario roster")
            }
            .buttonStyle(PrimaryProminentButtonStyle())
        }
        .padding(18)
        .appChromeElevated(cornerRadius: 20)
    }

    private func scenarioRow(kind: ActivityKind) -> some View {
        let stars = progress.starsTotal(for: kind)
        return Button {
            buildDeepLink = kind
            selectedTab = 1
        } label: {
            HStack(spacing: 14) {
                HomeScenarioGlyph(activity: kind)
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(kind.titleKey)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(kind.detailKey)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        StarShape()
                            .fill(Color.appAccent)
                            .frame(width: 14, height: 14)
                        Text("\(stars) stars")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appAccent)
                    }
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .appChromeInset(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignConstants.minTapTarget)
    }

    private var milestonesStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Track badges earned from real runs—no shortcuts.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
            Button {
                selectedTab = 2
            } label: {
                HStack {
                    Text("Open achievements")
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.appPrimary)
                }
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, DesignConstants.buttonHorizontalPadding)
                .frame(minHeight: DesignConstants.minTapTarget)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppChrome.surfaceRelief)
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppChrome.innerSheen.opacity(0.7))
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(AppChrome.cardEdge, lineWidth: 2)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: AppChrome.deepShadow.opacity(0.4), radius: 8, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .appChromeElevated(cornerRadius: 20)
    }

    private var maintenanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Maintenance")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Clears stars, unlocks, and run statistics stored on this device.")
                .font(.footnote)
                .foregroundStyle(Color.appTextSecondary)
            Button(role: .destructive) {
                progress.resetAllProgress()
            } label: {
                Text("Reset all progress")
            }
            .buttonStyle(SecondaryOutlineButtonStyle())
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appChromeElevated(cornerRadius: 20)
        .padding(.bottom, 20)
    }

    private func formattedTime(_ interval: TimeInterval) -> String {
        let seconds = Int(interval.rounded())
        let minutes = seconds / 60
        let rem = seconds % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let m = minutes % 60
            return String(format: "%dh %02dm", hours, m)
        }
        return String(format: "%dm %02ds", minutes, rem)
    }
}

// MARK: - Hero illustration (SwiftUI shapes only)

private struct HomeHeroCanvas: View {
    var pulse: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.02, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let baseY = size.height * 0.72
                for index in 0..<6 {
                    let w = CGFloat(16 + index * 5)
                    let h = CGFloat(28 + index * 12 + (pulse ? 4 : 0))
                    let x = CGFloat(index) * (size.width / 6) + 8
                    let rect = CGRect(x: x, y: baseY - h, width: w, height: h)
                    let path = Path(roundedRect: rect, cornerRadius: 5)
                    context.fill(path, with: .color(Color.appPrimary.opacity(0.25 + Double(index) * 0.06)))
                    context.stroke(path, with: .color(Color.appAccent.opacity(0.45)), lineWidth: 1.5)
                }
                let arcY = baseY - 50 + sin(t * 2) * 5
                var arc = Path()
                arc.move(to: CGPoint(x: 0, y: arcY))
                for px in stride(from: 0, through: size.width, by: 5) {
                    let wave = sin(t * 2.5 + px / 18) * 6
                    arc.addLine(to: CGPoint(x: px, y: arcY + wave))
                }
                context.stroke(arc, with: .color(Color.appAccent.opacity(0.55)), lineWidth: 2)
            }
        }
    }
}

private struct HomeScenarioGlyph: View {
    let activity: ActivityKind

    var body: some View {
        Canvas { context, size in
            switch activity {
            case .urbanFlow:
                drawGrid(&context, size: size)
            case .ecoBalance:
                drawEco(&context, size: size)
            case .resourceRush:
                drawLedger(&context, size: size)
            }
        }
        .appChromeInset(cornerRadius: 14)
    }

    private func drawGrid(_ context: inout GraphicsContext, size: CGSize) {
        let step = size.width / 4
        for row in 0..<3 {
            for col in 0..<3 {
                let rect = CGRect(x: step * CGFloat(col) + 6, y: step * CGFloat(row) + 6, width: step - 8, height: step - 8)
                let path = Path(roundedRect: rect, cornerRadius: 4)
                context.fill(path, with: .color(Color.appPrimary.opacity(0.35)))
            }
        }
    }

    private func drawEco(_ context: inout GraphicsContext, size: CGSize) {
        let hill = Path(ellipseIn: CGRect(x: 6, y: size.height * 0.35, width: size.width - 12, height: size.height * 0.45))
        context.fill(hill, with: .color(Color.appAccent.opacity(0.35)))
        let trunkRect = CGRect(x: size.width * 0.55, y: size.height * 0.42, width: 6, height: size.height * 0.35)
        context.fill(Path(trunkRect), with: .color(Color.appPrimary.opacity(0.55)))
        let crown = Path(ellipseIn: CGRect(x: size.width * 0.42, y: size.height * 0.18, width: size.width * 0.36, height: size.height * 0.32))
        context.fill(crown, with: .color(Color.appAccent.opacity(0.55)))
    }

    private func drawLedger(_ context: inout GraphicsContext, size: CGSize) {
        for row in 0..<4 {
            let y = 10 + CGFloat(row) * (size.height - 20) / 4
            let barRect = CGRect(x: 10, y: y, width: size.width - 20, height: 5)
            context.fill(Path(barRect), with: .color(Color.appPrimary.opacity(0.35 + Double(row) * 0.08)))
        }
        let dot = Path(ellipseIn: CGRect(x: size.width - 18, y: 12, width: 8, height: 8))
        context.fill(dot, with: .color(Color.appAccent))
    }
}
