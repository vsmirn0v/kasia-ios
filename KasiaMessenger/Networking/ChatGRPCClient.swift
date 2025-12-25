import Foundation
import GRPC
import NIOCore
import NIOPosix

final class ChatGRPCClient {
    private var host: String
    private var port: Int
    private var group: EventLoopGroup?
    private var channel: GRPCChannel?
    private var responseStream: AsyncThrowingStream<ChatMessage, Error>?
    private var responseContinuation: AsyncThrowingStream<ChatMessage, Error>.Continuation?
    private var subscribeCall: ServerStreamingCall<Kasia_SubscribeRequest, Kasia_ChatMessage>?

    init(host: String = "public.kaspa.network", port: Int = 50051) {
        self.host = host
        self.port = port
    }

    func updateEndpoint(host: String, port: Int) {
        guard host != self.host || port != self.port else { return }
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

    func send(message: ChatMessage, recipient: Contact?) async throws -> ChatMessage? {
        guard let channel else { throw ChatClientError.notConnected }
        let _ = recipient

        var request = Kasia_ChatMessage()
        request.sender = message.sender
        request.text = message.text
        request.timestamp = Int64(message.timestamp.timeIntervalSince1970)

        let client = Kasia_ChatServiceClient(channel: channel)
        let call = client.sendMessage(request)
        let response = try await call.response.get()

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
        subscribeCall?.cancel(promise: nil)
        subscribeCall = nil
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
                    let client = Kasia_ChatServiceClient(channel: channel)
                    let call = client.subscribe(Kasia_SubscribeRequest(), handler: { message in
                        let incoming = ChatMessage(
                            sender: message.sender,
                            text: message.text,
                            timestamp: Date(timeIntervalSince1970: TimeInterval(message.timestamp)),
                            isIncoming: true
                        )
                        continuation.yield(incoming)
                    })
                    subscribeCall = call

                    call.status.whenComplete { result in
                        switch result {
                        case .success:
                            continuation.finish()
                        case .failure(let error):
                            continuation.finish(throwing: error)
                        }
                    }
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
