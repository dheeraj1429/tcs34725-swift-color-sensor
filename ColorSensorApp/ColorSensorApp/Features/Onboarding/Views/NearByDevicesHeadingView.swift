//
//  NearByDevicesHeadingView.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 08/02/26.
//

import SwiftUI

struct NearByDevicesHeadingView: View {
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Nearby devices")
                    .font(.headline)
                Spacer()
                if bleManager.isScanning {
                    ProgressView()
                } else {
                    Button("Scan") {
                        bleManager.scanForDevices()
                    }
                }
            }

            Text(
                "You need to allow bluetooth access to use this feature."
            )
            .padding(.vertical, 5)
            .font(.callout)
            .foregroundStyle(Color(.systemGray))
        }
        .padding(.horizontal, 15)
    }
}

#Preview {
    NearByDevicesHeadingView()
        .environmentObject(BLEManager.shared)
}
