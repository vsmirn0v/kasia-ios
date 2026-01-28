import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var appState: AppState
    @State private var seedInput = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set up your Kaspa wallet")
                .font(.title.bold())
            Text("Import an existing seed phrase or generate a new one to start using Kasia Messenger.")
                .foregroundColor(.secondary)

            Text("Seed phrase")
                .font(.headline)
            TextEditor(text: $seedInput)
                .frame(minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.4))
                )

            HStack {
                Button("Generate") {
                    seedInput = SeedPhraseGenerator.generate()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Continue") {
                    appState.saveSeedPhrase(seedInput)
                }
                .buttonStyle(.borderedProminent)
                .disabled(seedInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
    }
}

#Preview {
    SetupView()
        .environmentObject(AppState())
}
