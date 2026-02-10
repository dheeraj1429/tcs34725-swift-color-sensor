//
//  OnboardingScreen.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 08/02/26.
//

import SwiftUI

struct OnboardingScreenView: View {
    @EnvironmentObject var bleManager: BLEManager
    @StateObject var onboardingVM = OnboardingViewModel()
    
    var body: some View {
        VStack {
            TabView(selection: $onboardingVM.currentStep) {
                ForEach(0..<onboardingVM.onboardingItems.count, id: \.self) { index in
                    OnboardingItemView(
                        onboardingItem: onboardingVM.onboardingItems[index],
                        isLastItem: index == onboardingVM.onboardingItems.count - 1,
                        isSheetPresented: $onboardingVM.isSheetPresented
                    )
                    .tag(onboardingVM.onboardingItems[index].id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .sheet(isPresented: $onboardingVM.isSheetPresented, content: {
            NearByDevicesView()
                .presentationDetents([.medium])
                .presentationBackground(.ultraThinMaterial)
        })
        .onChange(of: onboardingVM.isSheetPresented, { oldValue, newValue in
            if newValue {
                bleManager.scanForDevices()
            } else {
                bleManager.stop()
            }
        })
        .padding()
    }
}

#Preview {
    OnboardingScreenView()
        .environmentObject(BLEManager.shared)
}
