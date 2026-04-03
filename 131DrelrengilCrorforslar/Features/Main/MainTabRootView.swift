//
//  MainTabRootView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI
import UIKit

struct MainTabRootView: View {
    @State private var tabSelection = 0
    @State private var buildDeepLink: ActivityKind?

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appSurface)
        appearance.shadowColor = UIColor(Color.appBackground.opacity(0.55))

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = UIColor(Color.appTextSecondary)
        normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.appTextSecondary)]

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = UIColor(Color.appPrimary)
        selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.appPrimary)]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        let navigation = UINavigationBarAppearance()
        navigation.configureWithOpaqueBackground()
        navigation.backgroundColor = UIColor(Color.appSurface)
        navigation.shadowColor = UIColor(Color.appBackground.opacity(0.45))
        navigation.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(Color.appTextPrimary),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigation.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(Color.appTextPrimary)
        ]
        UINavigationBar.appearance().standardAppearance = navigation
        UINavigationBar.appearance().scrollEdgeAppearance = navigation
        UINavigationBar.appearance().compactAppearance = navigation
    }

    var body: some View {
        TabView(selection: $tabSelection) {
            HomeView(selectedTab: $tabSelection, buildDeepLink: $buildDeepLink)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            BuildManageCoordinator(deepLinkActivity: $buildDeepLink)
                .tabItem {
                    Label("Build & Manage", systemImage: "hammer.fill")
                }
                .tag(1)

            AchievementsView()
                .tabItem {
                    Label("Achievements", systemImage: "star.circle.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color.appPrimary)
    }
}
