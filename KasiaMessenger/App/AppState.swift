import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var seedPhrase: String = "" {
        didSet { storedSeedPhrase = seedPhrase }
    }
    @Published var nodeHost: String = "public.kaspa.network" {
        didSet { storedNodeHost = nodeHost }
    }
    @Published var nodePort: String = "50051" {
        didSet { storedNodePort = nodePort }
    }
    @Published var contacts: [Contact] = [] {
        didSet { persistContacts() }
    }

    @AppStorage("kasia.seedPhrase") private var storedSeedPhrase: String = ""
    @AppStorage("kasia.nodeHost") private var storedNodeHost: String = "public.kaspa.network"
    @AppStorage("kasia.nodePort") private var storedNodePort: String = "50051"

    init() {
        seedPhrase = storedSeedPhrase
        nodeHost = storedNodeHost
        nodePort = storedNodePort
        contacts = Self.loadContacts()
    }

    var hasSeedPhrase: Bool {
        !seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func saveSeedPhrase(_ phrase: String) {
        seedPhrase = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func exportSeedToICloudKeychain() throws {
        guard hasSeedPhrase else { return }
        try KeychainStore.saveSeed(seedPhrase, synchronizable: true)
    }

    func addContact(name: String, address: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedAddress.isEmpty else { return }
        contacts.append(Contact(name: trimmedName, address: trimmedAddress))
    }

    func removeContacts(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }

    private func persistContacts() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(contacts) {
            UserDefaults.standard.set(data, forKey: "kasia.contacts")
        }
    }

    private static func loadContacts() -> [Contact] {
        guard let data = UserDefaults.standard.data(forKey: "kasia.contacts") else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([Contact].self, from: data)) ?? []
    }
}
