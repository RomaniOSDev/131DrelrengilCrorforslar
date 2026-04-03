//
//  ContentView.swift
//  131DrelrengilCrorforslar
//
//  Created by Роман Главацкий on 03.04.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var progress = SimulationProgressStore()

    var body: some View {
        Group {
            if progress.hasSeenOnboarding {
                MainTabRootView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(progress)
    }
}

#Preview {
    ContentView()
}
