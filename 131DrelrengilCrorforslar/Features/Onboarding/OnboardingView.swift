//
//  OnboardingView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var progress: SimulationProgressStore
    @State private var page = 0

    var body: some View {
        ZStack {
            AppScreenChromeBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    introHeaderCard

                    carouselChromeShell

                    bottomDockCard
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
    }

    private var introHeaderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick tour")
                .font(.caption.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appAccent, Color.appPrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .textCase(.uppercase)
                .tracking(1.0)

            Text("Three moves that power every scenario")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 2, x: 0, y: 1)

            Text("No accounts or setup—just the desk essentials before you plan.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appChromeElevated(cornerRadius: 20)
    }

    private var carouselChromeShell: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                OnboardingPageView(
                    step: 1,
                    title: "Shape the Grid",
                    message: "Drag corridors into place so movement stays smooth across the city fabric.",
                    symbol: .gridPulse
                )
                .tag(0)
                OnboardingPageView(
                    step: 2,
                    title: "Balance the Districts",
                    message: "Tune parks, homes, and services to keep the skyline healthy and vibrant.",
                    symbol: .ecoWave
                )
                .tag(1)
                OnboardingPageView(
                    step: 3,
                    title: "Guide the Ledger",
                    message: "Approve the right civic actions and keep every budget decision intentional.",
                    symbol: .ledgerOrbit
                )
                .tag(2)
            }
            .frame(height: 448)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(DesignConstants.easeTransition, value: page)
        }
        .padding(14)
        .appChromeElevated(cornerRadius: AppChrome.cornerLarge)
    }

    private var bottomDockCard: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                onboardingPageDots
                Text(pageHint)
                    .font(.footnote)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: advance) {
                Text(page == 2 ? "Enter planning desk" : "Continue")
            }
            .buttonStyle(PrimaryProminentButtonStyle())
        }
        .padding(18)
        .appChromeElevated(cornerRadius: 20)
    }

    private var pageHint: String {
        switch page {
        case 0: return "Swipe the card or use Continue to move forward."
        case 1: return "Each screen mirrors a real scenario type in the roster."
        default: return "You are ready—open the desk and pick any scenario."
        }
    }

    private func advance() {
        if page < 2 {
            withAnimation(DesignConstants.spring) {
                page += 1
            }
        } else {
            progress.completeOnboarding()
        }
    }

    private var onboardingPageDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(
                        index == page
                            ? AppChrome.primaryCTA
                            : LinearGradient(
                                colors: [Color.appTextSecondary.opacity(0.42), Color.appTextSecondary.opacity(0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: index == page ? 26 : 8, height: 8)
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                index == page ? Color.appTextPrimary.opacity(0.25) : Color.clear,
                                lineWidth: 1
                            )
                    )
                    .shadow(color: index == page ? Color.appPrimary.opacity(0.45) : .clear, radius: 8, x: 0, y: 3)
                    .shadow(color: index == page ? AppChrome.deepShadow.opacity(0.4) : .clear, radius: 5, x: 0, y: 2)
                    .animation(DesignConstants.spring, value: page)
            }
        }
        .frame(minHeight: DesignConstants.minTapTarget)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Page \(page + 1) of 3"))
    }
}

private enum OnboardingSymbol {
    case gridPulse
    case ecoWave
    case ledgerOrbit
}

private struct OnboardingPageView: View {
    let step: Int
    let title: String
    let message: String
    let symbol: OnboardingSymbol

    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            illustrationPanel

            VStack(spacing: 14) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 2, x: 0, y: 1)
                    .padding(.top, 18)

                Text(message)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppChrome.cornerMedium, style: .continuous)
                            .fill(AppChrome.recessed)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppChrome.cornerMedium, style: .continuous)
                                    .strokeBorder(AppChrome.recessedRim, lineWidth: 1)
                            )
                    )
                    .shadow(color: AppChrome.deepShadow.opacity(0.35), radius: 6, x: 0, y: 4)
            }
            .padding(.horizontal, 10)

            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }

    private var illustrationPanel: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: AppChrome.cornerLarge, style: .continuous)
                .fill(AppChrome.heroFill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppChrome.cornerLarge, style: .continuous)
                        .strokeBorder(AppChrome.cardEdge, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppChrome.cornerLarge, style: .continuous)
                        .fill(AppChrome.innerSheen)
                )
                .frame(height: 232)
                .overlay(symbolCanvas)
                .overlay(alignment: .topLeading) {
                    stepBadge
                        .padding(14)
                }
        }
        .padding(.horizontal, 6)
        .clipShape(RoundedRectangle(cornerRadius: AppChrome.cornerLarge, style: .continuous))
        .shadow(color: AppChrome.deepShadow, radius: 20, x: 0, y: 12)
        .shadow(color: AppChrome.glowShadow, radius: 12, x: 0, y: 7)
    }

    private var stepBadge: some View {
        Text(String(format: "%02d", step))
            .font(.caption.weight(.heavy).monospacedDigit())
            .foregroundStyle(Color.appBackground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(AppChrome.primaryCTA)
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
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.appTextPrimary.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: AppChrome.deepShadow.opacity(0.45), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private var symbolCanvas: some View {
        TimelineView(.animation(minimumInterval: 0.016, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                switch symbol {
                case .gridPulse:
                    drawGridPulse(context: &context, size: size, t: t, animate: animate)
                case .ecoWave:
                    drawEcoWave(context: &context, size: size, t: t)
                case .ledgerOrbit:
                    drawLedgerOrbit(context: &context, size: size, t: t)
                }
            }
        }
    }

    private func drawGridPulse(context: inout GraphicsContext, size: CGSize, t: TimeInterval, animate: Bool) {
        let cols = 4
        let rows = 4
        let stepX = size.width / CGFloat(cols + 1)
        let stepY = size.height / CGFloat(rows + 1)
        for row in 1...rows {
            for col in 1...cols {
                let base = CGPoint(x: stepX * CGFloat(col), y: stepY * CGFloat(row))
                let wave = sin(t * 3 + Double(col + row)) * 6
                let rect = CGRect(x: base.x - 18, y: base.y - 10 + wave, width: 36, height: 20)
                let path = Path(roundedRect: rect, cornerRadius: 6)
                context.fill(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.appAccent.opacity(0.45 + (animate ? 0.2 : 0)),
                            Color.appPrimary.opacity(0.28 + (animate ? 0.12 : 0))
                        ]),
                        startPoint: CGPoint(x: rect.minX, y: rect.minY),
                        endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                    )
                )
                context.stroke(path, with: .color(Color.appPrimary.opacity(0.85)), lineWidth: 1.5)
                let lane = Path { p in
                    p.move(to: CGPoint(x: rect.midX - 10, y: rect.midY))
                    p.addLine(to: CGPoint(x: rect.midX + 10, y: rect.midY))
                }
                context.stroke(lane, with: .color(Color.appPrimary), lineWidth: 2.5)
            }
        }
    }

    private func drawEcoWave(context: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let wavePath = Path { path in
            path.move(to: CGPoint(x: 0, y: size.height * 0.65))
            for x in stride(from: 0, through: size.width, by: 5) {
                let relative = x / max(size.width, 1)
                let y = size.height * 0.55 + sin((relative * 6) + t * 2) * 18
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.stroke(
            wavePath,
            with: .linearGradient(
                Gradient(colors: [Color.appAccent, Color.appPrimary.opacity(0.85)]),
                startPoint: CGPoint(x: 0, y: size.height * 0.5),
                endPoint: CGPoint(x: size.width, y: size.height * 0.6)
            ),
            lineWidth: 4
        )

        let canopy = Path(ellipseIn: CGRect(x: size.width * 0.2, y: size.height * 0.22, width: 92, height: 52))
        context.fill(
            canopy,
            with: .linearGradient(
                Gradient(colors: [Color.appPrimary.opacity(0.55), Color.appAccent.opacity(0.35)]),
                startPoint: CGPoint(x: canopy.boundingRect.minX, y: canopy.boundingRect.minY),
                endPoint: CGPoint(x: canopy.boundingRect.maxX, y: canopy.boundingRect.maxY)
            )
        )

        let blockRect = CGRect(x: size.width * 0.55, y: size.height * 0.34, width: 70, height: 92)
        let block = Path(roundedRect: blockRect, cornerRadius: 12)
        context.fill(
            block,
            with: .linearGradient(
                Gradient(colors: [Color.appSurface.opacity(0.95), Color.appBackground.opacity(0.55)]),
                startPoint: CGPoint(x: blockRect.minX, y: blockRect.minY),
                endPoint: CGPoint(x: blockRect.maxX, y: blockRect.maxY)
            )
        )
        context.stroke(block, with: .color(Color.appAccent.opacity(0.45)), lineWidth: 1.5)
    }

    private func drawLedgerOrbit(context: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let ring = Path(ellipseIn: CGRect(x: center.x - 62, y: center.y - 62, width: 124, height: 124))
        context.stroke(
            ring,
            with: .linearGradient(
                Gradient(colors: [Color.appAccent.opacity(0.65), Color.appPrimary.opacity(0.35)]),
                startPoint: CGPoint(x: center.x - 62, y: center.y - 62),
                endPoint: CGPoint(x: center.x + 62, y: center.y + 62)
            ),
            lineWidth: 3
        )

        for index in 0..<3 {
            let angle = t + Double(index) * (2 * .pi / 3)
            let radius = min(size.width, size.height) * 0.28
            let point = CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius)
            let rect = CGRect(x: point.x - 12, y: point.y - 12, width: 24, height: 24)
            let diamond = Path { path in
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
                path.closeSubpath()
            }
            context.fill(
                diamond,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.appPrimary.opacity(0.85 - Double(index) * 0.12),
                        Color.appAccent.opacity(0.5 - Double(index) * 0.08)
                    ]),
                    startPoint: CGPoint(x: rect.minX, y: rect.minY),
                    endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                )
            )
            context.stroke(diamond, with: .color(Color.appTextPrimary.opacity(0.12)), lineWidth: 0.8)
        }
    }
}
