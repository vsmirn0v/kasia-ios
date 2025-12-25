import Foundation
import GRPC
import NIOCore

public struct Kasia_ChatMessage: GRPCPayload, Hashable, Sendable {
    public var sender: String
    public var text: String
    public var timestamp: Int64

    public init(sender: String = "", text: String = "", timestamp: Int64 = 0) {
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }

    public init(serializedByteBuffer buffer: inout ByteBuffer) throws {
        self = try Kasia_ChatMessage.deserialize(from: &buffer)
    }

    public static func with(_ configure: (inout Kasia_ChatMessage) -> Void) -> Kasia_ChatMessage {
        var message = Kasia_ChatMessage()
        configure(&message)
        return message
    }

    public func serialize(into buffer: inout ByteBuffer) throws {
        if !sender.isEmpty {
            ProtobufCoder.writeTag(fieldNumber: 1, wireType: .lengthDelimited, to: &buffer)
            ProtobufCoder.writeString(sender, to: &buffer)
        }
        if !text.isEmpty {
            ProtobufCoder.writeTag(fieldNumber: 2, wireType: .lengthDelimited, to: &buffer)
            ProtobufCoder.writeString(text, to: &buffer)
        }
        if timestamp != 0 {
            ProtobufCoder.writeTag(fieldNumber: 3, wireType: .varint, to: &buffer)
            ProtobufCoder.writeVarint(UInt64(bitPattern: timestamp), to: &buffer)
        }
    }

    public static func deserialize(from buffer: inout ByteBuffer) throws -> Kasia_ChatMessage {
        var message = Kasia_ChatMessage()
        var localBuffer = buffer

        while localBuffer.readableBytes > 0 {
            let tag = try ProtobufCoder.readVarint(from: &localBuffer)
            let fieldNumber = Int(tag >> 3)
            let wireType = ProtobufWireType(rawValue: Int(tag & 0x7))

            switch (fieldNumber, wireType) {
            case (1, .lengthDelimited):
                message.sender = try ProtobufCoder.readString(from: &localBuffer)
            case (2, .lengthDelimited):
                message.text = try ProtobufCoder.readString(from: &localBuffer)
            case (3, .varint):
                let value = try ProtobufCoder.readVarint(from: &localBuffer)
                message.timestamp = Int64(bitPattern: value)
            default:
                try ProtobufCoder.skipField(wireType: wireType, from: &localBuffer)
            }
        }

        buffer = localBuffer
        return message
    }
}

public struct Kasia_SubscribeRequest: GRPCPayload, Hashable, Sendable {
    public init() {}

    public init(serializedByteBuffer buffer: inout ByteBuffer) throws {
        _ = buffer
    }

    public func serialize(into buffer: inout ByteBuffer) throws {
    }

    public static func deserialize(from buffer: inout ByteBuffer) throws -> Kasia_SubscribeRequest {
        _ = buffer.readableBytes
        return Kasia_SubscribeRequest()
    }
}

public struct Kasia_ChatServiceClient {
    public let channel: GRPCChannel
    public var defaultCallOptions: CallOptions

    public init(channel: GRPCChannel, defaultCallOptions: CallOptions = CallOptions()) {
        self.channel = channel
        self.defaultCallOptions = defaultCallOptions
    }

    public func sendMessage(
        _ request: Kasia_ChatMessage,
        callOptions: CallOptions? = nil
    ) -> UnaryCall<Kasia_ChatMessage, Kasia_ChatMessage> {
        channel.makeUnaryCall(
            path: "/kasia.ChatService/SendMessage",
            request: request,
            callOptions: callOptions ?? defaultCallOptions
        )
    }

    public func subscribe(
        _ request: Kasia_SubscribeRequest,
        callOptions: CallOptions? = nil
    ) -> ServerStreamingCall<Kasia_SubscribeRequest, Kasia_ChatMessage> {
        channel.makeServerStreamingCall(
            path: "/kasia.ChatService/Subscribe",
            request: request,
            callOptions: callOptions ?? defaultCallOptions
        )
    }

    public func subscribe(
        _ request: Kasia_SubscribeRequest,
        callOptions: CallOptions? = nil,
        handler: @escaping (Kasia_ChatMessage) -> Void
    ) -> ServerStreamingCall<Kasia_SubscribeRequest, Kasia_ChatMessage> {
        channel.makeServerStreamingCall(
            path: "/kasia.ChatService/Subscribe",
            request: request,
            callOptions: callOptions ?? defaultCallOptions,
            handler: handler
        )
    }
}

private enum ProtobufWireType: Int {
    case varint = 0
    case lengthDelimited = 2
}

private enum ProtobufCodingError: Error {
    case truncated
    case unsupportedWireType
    case invalidLength
}

private enum ProtobufCoder {
    static func writeTag(fieldNumber: Int, wireType: ProtobufWireType, to buffer: inout ByteBuffer) {
        let tag = UInt64((fieldNumber << 3) | wireType.rawValue)
        writeVarint(tag, to: &buffer)
    }

    static func writeString(_ value: String, to buffer: inout ByteBuffer) {
        let bytes = Array(value.utf8)
        writeVarint(UInt64(bytes.count), to: &buffer)
        buffer.writeBytes(bytes)
    }

    static func writeVarint(_ value: UInt64, to buffer: inout ByteBuffer) {
        var value = value
        while value >= 0x80 {
            buffer.writeInteger(UInt8(value & 0x7f | 0x80))
            value >>= 7
        }
        buffer.writeInteger(UInt8(value))
    }

    static func readString(from buffer: inout ByteBuffer) throws -> String {
        let length = Int(try readVarint(from: &buffer))
        guard length >= 0 else { throw ProtobufCodingError.invalidLength }
        guard let bytes = buffer.readBytes(length: length) else {
            throw ProtobufCodingError.truncated
        }
        return String(decoding: bytes, as: UTF8.self)
    }

    static func readVarint(from buffer: inout ByteBuffer) throws -> UInt64 {
        var shift: UInt64 = 0
        var result: UInt64 = 0

        while shift < 64 {
            guard let byte = buffer.readInteger(as: UInt8.self) else {
                throw ProtobufCodingError.truncated
            }
            result |= UInt64(byte & 0x7f) << shift
            if (byte & 0x80) == 0 {
                return result
            }
            shift += 7
        }
        throw ProtobufCodingError.truncated
    }

    static func skipField(wireType: ProtobufWireType?, from buffer: inout ByteBuffer) throws {
        guard let wireType else { throw ProtobufCodingError.unsupportedWireType }
        switch wireType {
        case .varint:
            _ = try readVarint(from: &buffer)
        case .lengthDelimited:
            let length = Int(try readVarint(from: &buffer))
            guard length >= 0, buffer.readableBytes >= length else {
                throw ProtobufCodingError.truncated
            }
            buffer.moveReaderIndex(forwardBy: length)
        }
    }
}
