import Foundation

/// Handles API key persistence through Keychain.
final class SettingsViewModel: ObservableObject {
    @Published var apiKey: String = KeychainManager.shared.fetchAPIKey() ?? ""

    func save() {
        KeychainManager.shared.saveAPIKey(apiKey)
    }
}
