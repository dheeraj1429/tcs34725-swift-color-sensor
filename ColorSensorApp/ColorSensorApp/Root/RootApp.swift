//
//  RootApp.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 09/02/26.
//

import SwiftUI

struct RootApp: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        NavigationStack(path: $router.path) {
            OnboardingScreenView()
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .HomeScreen:
                        HomeView()
                    case .OnboardingScreen:
                        OnboardingScreenView()
                    }
                }
        }
    }
}

#Preview {
    RootApp()
        .environmentObject(Router.shared)
}
