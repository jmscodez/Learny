import SwiftUI

struct MainView: View {
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
        .preferredColorScheme(.dark)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
