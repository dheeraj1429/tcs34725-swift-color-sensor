//
//  NearByDevicesListView.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 08/02/26.
//

import SwiftUI
import CoreBluetooth

struct NearByDevicesListView: View {
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(bleManager.discoverDevices, id: \.self) { peripheral in
                        HStack {
                            Text(peripheral.name ?? "Unknown name")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if bleManager.isDeviceConnecting(with: peripheral) {
                                ProgressView()
                            } else {
                                Button {
                                    if bleManager.isDeviceConnected(with: peripheral) {
                                        bleManager.disconnect(to: peripheral)
                                    } else {
                                        bleManager.connect(with: peripheral)
                                    }
                                } label: {
                                    if bleManager.isDeviceConnected(with: peripheral) {
                                        Text("Disconnect")
                                    } else {
                                        Text("Connect")
                                    }
                                }
                                .disabled(bleManager.isConnecting)
                            }
                        }
                        .padding(.bottom, 2)
                        
                        Divider()
                    }
                }
                .padding()
            }
            .frame(maxHeight: 400)
        }
        .alert("Error", isPresented: bleManager.shouldPresentErrorAlert) {
        } message: {
            Text(bleManager.connectionErrorMessage ?? bleManager.disconnectionErrorMessage ?? "Unknown Error")
        }

    }
}

#Preview {
    NearByDevicesListView()
        .environmentObject(BLEManager.shared)
}
