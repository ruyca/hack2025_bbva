import Foundation
import Security

class KeychainService {
    // MARK: - Singleton instance
    static let shared = KeychainService()
    private init() {}
    
    // MARK: - Biometric flag services
    
    // The key format for storing biometric flags in the keychain
    private func biometricKey(for userID: String) -> String {
        return "com.bbva.mipymes.biometric.\(userID)"
    }
    
    // Check if biometrics are enabled for a specific user
    func isBiometricsEnabled(for userID: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: biometricKey(for: userID),
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // If the item exists and has data, biometrics is enabled
        return status == errSecSuccess && item != nil
    }
    
    // Enable biometrics for a specific user
    func setBiometricsEnabled(for userID: String) -> OSStatus {
        // First, check if the item already exists
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: biometricKey(for: userID)
        ]
        
        // Create a simple data value to represent "enabled"
        let enabledValue = "true".data(using: .utf8)!
        
        // Check if item already exists
        var item: CFTypeRef?
        let checkStatus = SecItemCopyMatching(query as CFDictionary, &item)
        
        if checkStatus == errSecSuccess {
            // Item exists, update it
            let updateAttributes: [String: Any] = [
                kSecValueData as String: enabledValue
            ]
            return SecItemUpdate(query as CFDictionary, updateAttributes as CFDictionary)
        } else if checkStatus == errSecItemNotFound {
            // Item doesn't exist, add it
            let addAttributes: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: biometricKey(for: userID),
                kSecValueData as String: enabledValue,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            return SecItemAdd(addAttributes as CFDictionary, nil)
        } else {
            // Some other error occurred during the check
            return checkStatus
        }
    }
    
    // Remove biometrics enable flag for a user
    func removeBiometricsEnabled(for userID: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: biometricKey(for: userID)
        ]
        
        return SecItemDelete(query as CFDictionary)
    }
}
