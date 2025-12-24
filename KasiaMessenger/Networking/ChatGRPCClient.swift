import Foundation
import GRPC
import NIOCore
import NIOPosix
import SwiftProtobuf

final class ChatGRPCClient {
    private let host: String
    private let port: Int
    private var group: EventLoopGroup?
    private var channel: GRPCChannel?
    private var responseStream: AsyncThrowingStream<ChatMessage, Error>?
    private var responseContinuation: AsyncThrowingStream<ChatMessage, Error>.Continuation?

    init(host: String = "localhost", port: Int = 50051) {
        self.host = host
        self.port = port
    }

    func connect() async throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.group = group
        let channel = try GRPCChannelPool.with(
            target: .host(host, port: port),
            transportSecurity: .plaintext,
            eventLoopGroup: group
        )
        self.channel = channel
        startIncomingStreamIfNeeded()
    }

    func send(message: ChatMessage) async throws -> ChatMessage? {
        guard let channel else { throw ChatClientError.notConnected }

        let request = Kasia_ChatMessage.with {
            $0.sender = message.sender
            $0.text = message.text
            $0.timestamp = Int64(message.timestamp.timeIntervalSince1970)
        }

        let client = Kasia_ChatServiceAsyncClient(channel: channel)
        let response = try await client.sendMessage(request)

        return ChatMessage(
            sender: response.sender,
            text: response.text,
            timestamp: Date(timeIntervalSince1970: TimeInterval(response.timestamp)),
            isIncoming: true
        )
    }

    func incomingMessages() -> AsyncThrowingStream<ChatMessage, Error> {
        if let responseStream {
            return responseStream
        }

        let stream = AsyncThrowingStream { continuation in
            responseContinuation = continuation
        }
        responseStream = stream
        return stream
    }

    func disconnect() async {
        responseContinuation?.finish()
        responseContinuation = nil
        responseStream = nil
        try? await channel?.close().get()
        channel = nil
        try? await group?.shutdownGracefully()
        group = nil
    }

    private func startIncomingStreamIfNeeded() {
        guard let channel else { return }

        responseStream = AsyncThrowingStream { continuation in
            responseContinuation = continuation

            Task {
                do {
                    let client = Kasia_ChatServiceAsyncClient(channel: channel)
                    let call = client.subscribe(Kasia_SubscribeRequest())

                    for try await message in call.responses {
                        let incoming = ChatMessage(
                            sender: message.sender,
                            text: message.text,
                            timestamp: Date(timeIntervalSince1970: TimeInterval(message.timestamp)),
                            isIncoming: true
                        )
                        continuation.yield(incoming)
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

extension ChatGRPCClient {
    static var preview: ChatGRPCClient {
        ChatGRPCClient(host: "preview", port: 0)
    }
}

enum ChatClientError: Error {
    case notConnected
}
