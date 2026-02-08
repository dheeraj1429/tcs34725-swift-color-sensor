import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var onboardingItems: [OnboardingModel] = [
        .init(
            id: 0,
            title: "Hi there!",
            subTitle:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            imageName: "charcoHi"
        ),
        .init(
            id: 1,
            title: "We’re all set!",
            subTitle:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            imageName: "charcoGoodJob"
        ),
    ]
    
    @Published var currentStep: Int = 0
    @Published var isSheetPresented: Bool = false
}
