import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var exportStatus: String?

    var body: some View {
        Form {
            Section("Wallet") {
                HStack {
                    Text("Seed phrase")
                    Spacer()
                    Text(appState.hasSeedPhrase ? "Configured" : "Missing")
                        .foregroundColor(appState.hasSeedPhrase ? .green : .red)
                        .font(.caption)
                }

                Button("Export seed to iCloud Keychain") {
                    do {
                        try appState.exportSeedToICloudKeychain()
                        exportStatus = "Seed phrase exported to iCloud Keychain."
                    } catch {
                        exportStatus = "Export failed: \(error.localizedDescription)"
                    }
                }
            }

            Section("Kaspa node") {
                TextField("Host", text: $appState.nodeHost)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Port", text: $appState.nodePort)
                    .keyboardType(.numberPad)
            }

            if let exportStatus {
                Section {
                    Text(exportStatus)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
