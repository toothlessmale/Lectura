import Foundation
import Security

/// Simple wrapper around Keychain for storing the OpenAI API key securely.
final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    private let service = "com.minutemind.api"
    private let account = "OPENAI_API_KEY"

    /// Retrieve API key from Keychain.
    func fetchAPIKey() -> String? {
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrService as String: service,
                                   kSecAttrAccount as String: account,
                                   kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Save or update the API key.
    func saveAPIKey(_ key: String) {
        let data = Data(key.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        if SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess {
            let attrs: [String: Any] = [kSecValueData as String: data]
            SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
        } else {
            var newItem = query
            newItem[kSecValueData as String] = data
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }
}
