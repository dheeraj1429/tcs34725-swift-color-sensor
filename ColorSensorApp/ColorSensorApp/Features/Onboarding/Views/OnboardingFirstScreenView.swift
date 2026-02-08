//
//  OnboardingFirstScreen.swift
//  ColorSensorApp
//
//  Created by DHEERAJ on 08/02/26.
//

import SwiftUI

struct OnboardingFirstScreenView: View {
    @StateObject var onboardingVM = OnboardingViewModel()
    
    var body: some View {
        VStack {
            TabView(selection: $onboardingVM.currentStep) {
                ForEach(0..<onboardingVM.onboardingItems.count, id: \.self) { index in
                    VStack(spacing: 10) {
                        Image(onboardingVM.onboardingItems[index].imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.bottom, 20)
                        
                        Text(onboardingVM.onboardingItems[index].title)
                            .font(.largeTitle)
                            .fontWeight(.semibold)

                        Text(onboardingVM.onboardingItems[index].subTitle)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(.systemGray))

                        if index == onboardingVM.onboardingItems.count - 1 {
                            Button {
                                
                            } label: {
                                Text("Connect")
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 10)
                                    .frame(width: 300)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.secondary)
                                    )
                            }
                            .padding(.top, 20)
                        }
                    }
                    .tag(onboardingVM.onboardingItems[index].id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .sheet(isPresented: $onboardingVM.isSheetPresented, content: {
            
        })
        .padding()
    }
}

#Preview {
    OnboardingFirstScreenView()
}
