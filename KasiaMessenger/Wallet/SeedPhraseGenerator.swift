import Foundation

enum SeedPhraseGenerator {
    private static let words = [
        "ability", "about", "absent", "access", "accident", "account", "across", "action",
        "adapt", "address", "advice", "affair", "again", "agent", "ahead", "alarm",
        "album", "allow", "almost", "always", "amount", "anchor", "animal", "answer",
        "anyone", "apart", "appeal", "apple", "arrive", "artist", "aspect", "assist",
        "attack", "attempt", "august", "author", "balance", "basket", "battery", "battle",
        "beauty", "because", "before", "behave", "behind", "benefit", "better", "beyond",
        "birth", "black", "blossom", "board", "bonus", "borrow", "bottom", "bridge"
    ]

    static func generate(count: Int = 12) -> String {
        let selection = (0..<count).map { _ in words.randomElement() ?? "seed" }
        return selection.joined(separator: " ")
    }
}
