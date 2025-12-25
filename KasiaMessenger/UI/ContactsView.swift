import SwiftUI

struct ContactsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isPresentingAdd = false

    var body: some View {
        List {
            ForEach(appState.contacts) { contact in
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.headline)
                    Text(contact.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: appState.removeContacts)
        }
        .navigationTitle("Contacts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    isPresentingAdd = true
                }
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            AddContactView(isPresented: $isPresentingAdd)
        }
    }
}

private struct AddContactView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var address = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Kaspa address", text: $address)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .navigationTitle("New Contact")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appState.addContact(name: name, address: address)
                        isPresented = false
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactsView()
            .environmentObject(AppState())
    }
}
