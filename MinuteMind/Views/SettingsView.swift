import SwiftUI

/// Screen to allow user to provide/update OpenAI API key.
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section(header: Text("OpenAI API Key")) {
                SecureField("Key", text: $viewModel.apiKey)
                Button("Save") { viewModel.save() }
            }
        }
        .navigationTitle("Settings")
    }
}
