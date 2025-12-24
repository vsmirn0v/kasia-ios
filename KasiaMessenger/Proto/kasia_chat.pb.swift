import Foundation
import GRPC

public struct Kasia_ChatMessage {
    public var sender: String
    public var text: String
    public var timestamp: Int64

    public init(sender: String = "", text: String = "", timestamp: Int64 = 0) {
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }

    public static func with(_ configure: (inout Kasia_ChatMessage) -> Void) -> Kasia_ChatMessage {
        var message = Kasia_ChatMessage()
        configure(&message)
        return message
    }
}

public struct Kasia_SubscribeRequest {
    public init() {}
}

public struct Kasia_ChatServiceAsyncClient {
    public let channel: GRPCChannel

    public init(channel: GRPCChannel) {
        self.channel = channel
    }

    public func sendMessage(_ request: Kasia_ChatMessage) async throws -> Kasia_ChatMessage {
        request
    }

    public func subscribe(_ request: Kasia_SubscribeRequest) -> Kasia_ChatServiceAsyncClient.SubscribeCall {
        let stream = AsyncThrowingStream<Kasia_ChatMessage, Error> { continuation in
            continuation.finish()
        }
        return SubscribeCall(responses: stream)
    }

    public struct SubscribeCall {
        public let responses: AsyncThrowingStream<Kasia_ChatMessage, Error>
    }
}
