//
//  ActivityHostView.swift
//  131DrelrengilCrorforslar
//

import SwiftUI

struct ActivityHostView: View {
    let stage: ActiveStageRoute
    @Binding var path: NavigationPath

    var body: some View {
        Group {
            switch stage.activity {
            case .urbanFlow:
                UrbanFlowView(stage: stage, path: $path)
            case .ecoBalance:
                EcoBalanceView(stage: stage, path: $path)
            case .resourceRush:
                ResourceRushView(stage: stage, path: $path)
            }
        }
    }
}
