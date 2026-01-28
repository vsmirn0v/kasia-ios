import Foundation
import Security

enum KeychainStore {
    private static let service = "com.kasia.messenger"
    private static let account = "seedPhrase"

    static func saveSeed(_ seed: String, synchronizable: Bool) throws {
        let data = Data(seed.utf8)
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        if synchronizable {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
