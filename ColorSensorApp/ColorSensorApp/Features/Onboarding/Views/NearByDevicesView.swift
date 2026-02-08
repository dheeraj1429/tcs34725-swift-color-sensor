//
//  NearByDevices.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 08/02/26.
//

import SwiftUI

struct NearByDevicesView: View {
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 5,
            content: {
                NearByDevicesHeadingView()
                Divider()
                NearByDevicesListView()
            }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }
}

#Preview {
    NearByDevicesView()
}
