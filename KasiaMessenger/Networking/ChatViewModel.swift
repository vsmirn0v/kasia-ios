import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published var draftMessage: String = ""

    private let chatClient: ChatGRPCClient

    init(chatClient: ChatGRPCClient = ChatGRPCClient()) {
        self.chatClient = chatClient
    }

    func updateEndpoint(host: String, port: String) {
        guard let portValue = Int(port) else { return }
        chatClient.updateEndpoint(host: host, port: portValue)
        if connectionState == .connected {
            Task { await disconnect() }
        }
    }

    func connectIfNeeded() async {
        guard connectionState == .disconnected || connectionState == .failed else { return }
        connectionState = .connecting
        do {
            try await chatClient.connect()
            connectionState = .connected
            listenForIncomingMessages()
        } catch {
            connectionState = .failed
        }
    }

    func send(text: String) {
        send(text: text, recipient: nil)
    }

    func send(text: String, recipient: Contact?) {
        let outgoing = ChatMessage(sender: "Me", text: text, isIncoming: false)
        messages.append(outgoing)
        draftMessage = ""

        Task {
            do {
                if let reply = try await chatClient.send(message: outgoing, recipient: recipient) {
                    messages.append(reply)
                }
            } catch {
                let failed = ChatMessage(
                    sender: "System",
                    text: "Failed to send message: \(error.localizedDescription)",
                    isIncoming: true
                )
                messages.append(failed)
                connectionState = .failed
            }
        }
    }

    func disconnect() async {
        await chatClient.disconnect()
        connectionState = .disconnected
    }

    private func listenForIncomingMessages() {
        Task {
            do {
                for try await incoming in chatClient.incomingMessages() {
                    messages.append(incoming)
                }
            } catch {
                connectionState = .failed
            }
        }
    }
}

extension ChatViewModel {
    static var preview: ChatViewModel {
        let viewModel = ChatViewModel(chatClient: .preview)
        viewModel.messages = [
            ChatMessage(sender: "Kasia", text: "Welcome to Kasia Messenger!", isIncoming: true),
            ChatMessage(sender: "Me", text: "Happy to be here.", isIncoming: false)
        ]
        viewModel.connectionState = .connected
        return viewModel
    }
}
