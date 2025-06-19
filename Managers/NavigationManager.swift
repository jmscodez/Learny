import SwiftUI
import Combine

@MainActor
final class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
} 