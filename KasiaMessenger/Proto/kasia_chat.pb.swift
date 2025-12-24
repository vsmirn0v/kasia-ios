import Foundation
import GRPC
@preconcurrency import SwiftProtobuf

public struct Kasia_ChatMessage: SwiftProtobuf.Message {
    public var sender: String = ""
    public var text: String = ""
    public var timestamp: Int64 = 0
    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

extension Kasia_ChatMessage {
    public static let protoMessageName = "kasia.ChatMessage"

    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "sender"),
        2: .same(proto: "text"),
        3: .same(proto: "timestamp")
    ]

    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1:
                try decoder.decodeSingularStringField(value: &sender)
            case 2:
                try decoder.decodeSingularStringField(value: &text)
            case 3:
                try decoder.decodeSingularInt64Field(value: &timestamp)
            default:
                try decoder.skipField()
            }
        }
    }

    public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if !sender.isEmpty {
            try visitor.visitSingularStringField(value: sender, fieldNumber: 1)
        }
        if !text.isEmpty {
            try visitor.visitSingularStringField(value: text, fieldNumber: 2)
        }
        if timestamp != 0 {
            try visitor.visitSingularInt64Field(value: timestamp, fieldNumber: 3)
        }
        try unknownFields.traverse(visitor: &visitor)
    }
}

public struct Kasia_SubscribeRequest: SwiftProtobuf.Message {
    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

extension Kasia_SubscribeRequest {
    public static let protoMessageName = "kasia.SubscribeRequest"

    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [:]

    public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let _ = try decoder.nextFieldNumber() {
            try decoder.skipField()
        }
    }

    public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        try unknownFields.traverse(visitor: &visitor)
    }
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
