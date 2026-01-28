import SwiftUI

struct ChatListView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List {
            if appState.contacts.isEmpty {
                Text("Add a contact to start a chat.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(appState.contacts) { contact in
                    NavigationLink(value: contact) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contact.name)
                                .font(.headline)
                            Text(contact.address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Chats")
        .navigationDestination(for: Contact.self) { contact in
            ChatDetailView(contact: contact)
        }
    }
}

#Preview {
    NavigationStack {
        ChatListView()
            .environmentObject(AppState())
    }
}
