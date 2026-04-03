//
//  BuildManageCoordinator.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct BuildManageCoordinator: View {
    @Binding var deepLinkActivity: ActivityKind?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ActivityGalleryView { kind in
                path.append(BuildStackRoute.levels(kind))
            }
            .navigationDestination(for: BuildStackRoute.self) { route in
                switch route {
                case .levels(let kind):
                    LevelGridView(activity: kind, path: $path)
                case .play(let stage):
                    ActivityHostView(stage: stage, path: $path)
                case .outcome(let stage, let outcome, let fresh):
                    ActivityResultView(stage: stage, outcome: outcome, freshAchievementIDs: fresh, path: $path)
                }
            }
        }
        .onChange(of: deepLinkActivity) { kind in
            guard let kind else { return }
            path = NavigationPath()
            path.append(BuildStackRoute.levels(kind))
            DispatchQueue.main.async {
                deepLinkActivity = nil
            }
        }
    }
}
