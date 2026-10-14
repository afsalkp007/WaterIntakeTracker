import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Today", systemImage: "drop.fill")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(1)

            GoalSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.cyan)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WaterLog.self, inMemory: true)
}
