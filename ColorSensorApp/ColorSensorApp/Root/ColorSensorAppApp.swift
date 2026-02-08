//
//  ColorSensorAppApp.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 08/02/26.
//

import SwiftUI

@main
struct ColorSensorAppApp: App {
    @StateObject var bleManager = BLEManager.shared
    
    var body: some Scene {
        WindowGroup {
            OnboardingScreenView()
                .environmentObject(bleManager)
        }
    }
}
