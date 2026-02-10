import Combine
import SwiftUI

enum Screen: Hashable {
    case OnboardingScreen, HomeScreen
}

final class Router: ObservableObject {
    static let shared = Router()
    
    @Published var path = NavigationPath()
    
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToTop() {
        path.removeLast(path.count - 1)
    }
}
