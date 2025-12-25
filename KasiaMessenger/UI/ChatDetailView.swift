import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject private var appState: AppState
    let contact: Contact
    @StateObject private var viewModel: ChatViewModel

    init(contact: Contact) {
        self.contact = contact
        _viewModel = StateObject(wrappedValue: ChatViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            messagesList
            composer
        }
        .navigationTitle(contact.name)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                connectionStatus
            }
        }
        .task {
            viewModel.updateEndpoint(host: appState.nodeHost, port: appState.nodePort)
            await viewModel.connectIfNeeded()
        }
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            List(viewModel.messages) { message in
                MessageRow(message: message)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .onChange(of: viewModel.messages) { _, _ in
                guard let lastMessage = viewModel.messages.last else { return }
                withAnimation {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }

    private var composer: some View {
        HStack(spacing: 12) {
            TextField("Type a message", text: $viewModel.draftMessage)
                .textFieldStyle(.roundedBorder)
            Button("Send") {
                viewModel.send(text: viewModel.draftMessage, recipient: contact)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(composerBackgroundColor)
    }

    private var connectionStatus: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(viewModel.connectionState.color)
                .frame(width: 10, height: 10)
            Text(viewModel.connectionState.label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var composerBackgroundColor: Color {
        #if os(iOS)
        return Color(.secondarySystemBackground)
        #else
        return Color(.windowBackgroundColor)
        #endif
    }
}

private struct MessageRow: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isIncoming { Spacer() }
            VStack(alignment: .leading, spacing: 4) {
                Text(message.sender)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .font(.body)
                    .padding(12)
                    .background(message.isIncoming ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                    .cornerRadius(12)
            }
            if !message.isIncoming { Spacer() }
        }
        .id(message.id)
    }
}

#Preview {
    NavigationStack {
        ChatDetailView(contact: Contact(name: "Kasia", address: "kaspa:demo"))
            .environmentObject(AppState())
    }
}
