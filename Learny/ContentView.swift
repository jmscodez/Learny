// MainView.swift

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TopicInputView()
            }
            .tabItem { Label("Learn",    systemImage: "pencil") }

            NavigationStack {
                SavedCoursesView()
            }
            .tabItem { Label("Courses",  systemImage: "book") }

            NavigationStack {
                ProgressView()
            }
            .tabItem { Label("Progress", systemImage: "chart.bar") }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
