//
//  HomeView.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 09/02/26.
//

import SwiftUI
import CoreBluetooth

struct HomeView: View {
    @EnvironmentObject var bleManager: BLEManager
    @State var sensorData: SensorColorResponse?
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if let connectedDevice = bleManager.connectedDevice {
                    HStack(spacing: 10, content: {
                        Text("Connected Device")
                        
                        Text(connectedDevice.name ?? "Unknown device")
                    })
                    .font(.subheadline)
                } else {
                    Text("Please scan for devices")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let sensorData {
                ColorSensorCard(data: sensorData)
                    .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding()
        .onReceive(bleManager.eventPublisher) { events in
            switch events {
            case .colorSensorReadingEvent(let data):
                sensorData = data
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(BLEManager.shared)
}
