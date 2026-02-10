//
//  OnboardingItemView.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 09/02/26.
//

import SwiftUI

struct OnboardingItemView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var bleManager: BLEManager
    
    let onboardingItem: OnboardingModel
    let isLastItem: Bool
    @Binding var isSheetPresented: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(onboardingItem.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 20)
            
            Text(onboardingItem.title)
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text(onboardingItem.subTitle)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(.systemGray))
            
            VStack {
                if isLastItem {
                    if bleManager.isConnecting {
                        ProgressView()
                    } else {
                        Button {
                            if bleManager.connectedDevice != nil {
                                router.push(.HomeScreen)
                            } else {
                                isSheetPresented = true
                            }
                        } label: {
                            Text(bleManager.connectedDevice != nil ? "Continue" : "Connect")
                                .foregroundStyle(.white)
                                .padding(.vertical, 10)
                                .frame(width: 300)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.primary)
                                )
                        }
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    OnboardingItemView(
        onboardingItem: .init(
            id: 0,
            title: "Hi there!",
            subTitle:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            imageName: "charcoHi"
        ),
        isLastItem: true,
        isSheetPresented: .constant(false)
    )
    .environmentObject(Router.shared)
    .environmentObject(BLEManager.shared)
}
