import SwiftUI

struct MainView: View {
    init() {
        // Tab bar icons/tint
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = .lightGray
    }

    var body: some View {
        TabView {
            TopicInputView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Learn")
                }

            SavedCoursesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Courses")
                }

            ProgressView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Progress")
                }
        }
        .accentColor(.cyan)
        .preferredColorScheme(.dark)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
