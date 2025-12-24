import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var connectionState: ConnectionState = .disconnected

    private let chatClient: ChatGRPCClient

    init(chatClient: ChatGRPCClient = ChatGRPCClient()) {
        self.chatClient = chatClient
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
        let outgoing = ChatMessage(sender: "Me", text: text, isIncoming: false)
        messages.append(outgoing)

        Task {
            do {
                if let reply = try await chatClient.send(message: outgoing) {
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
