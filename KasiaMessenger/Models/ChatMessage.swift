import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    let sender: String
    let text: String
    let timestamp: Date
    let isIncoming: Bool

    init(id: UUID = UUID(), sender: String, text: String, timestamp: Date = Date(), isIncoming: Bool) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.isIncoming = isIncoming
    }
}
