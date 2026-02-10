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
    @StateObject var router = Router.shared
    
    var body: some Scene {
        WindowGroup {
            RootApp()
                .environmentObject(bleManager)
                .environmentObject(router)
        }
    }
}
