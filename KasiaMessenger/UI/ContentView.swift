import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ChatViewModel
    @State private var draftMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                messagesList
                composer
            }
            .navigationTitle("Kasia Messenger")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    connectionStatus
                }
            }
        }
        .task {
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
            .onChange(of: viewModel.messages) { _ in
                guard let lastMessage = viewModel.messages.last else { return }
                withAnimation {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }

    private var composer: some View {
        HStack(spacing: 12) {
            TextField("Type a message", text: $draftMessage)
                .textFieldStyle(.roundedBorder)
            Button("Send") {
                let text = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return }
                viewModel.send(text: text)
                draftMessage = ""
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
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
    ContentView()
        .environmentObject(ChatViewModel.preview)
}
