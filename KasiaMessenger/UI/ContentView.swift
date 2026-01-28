import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if appState.hasSeedPhrase {
            TabView {
                NavigationStack {
                    ChatListView()
                }
                .tabItem {
                    Label("Chats", systemImage: "message")
                }

                NavigationStack {
                    ContactsView()
                }
                .tabItem {
                    Label("Contacts", systemImage: "person.2")
                }

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
        } else {
            SetupView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
