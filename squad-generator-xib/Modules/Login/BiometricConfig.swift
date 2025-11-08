//
//  BiometricConfig.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 08/11/25.
//

import Security
import LocalAuthentication

enum KeychainError: Error { case unexpectedStatus(OSStatus), notFound }

struct SecureKeychain {
  private static let service = "com.letstrysomethingnew.squad-generator-xib.biometric-login"

  static func savePassword(_ password: String, account: String) throws {
    let access = SecAccessControlCreateWithFlags(
      nil,
      kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      [.userPresence],
      nil
    )!

    let context = LAContext()

    // Delete any existing
    let deleteQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ]
    SecItemDelete(deleteQuery as CFDictionary)

    let addQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecAttrAccessControl as String: access,
      kSecUseAuthenticationContext as String: context,
      kSecValueData as String: Data(password.utf8)
    ]

    let status = SecItemAdd(addQuery as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
  }

  static func loadPassword(account: String, prompt: String) throws -> String {
    let context = LAContext()
    context.localizedReason = prompt

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecUseAuthenticationContext as String: context,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status != errSecItemNotFound else { throw KeychainError.notFound }
    guard status == errSecSuccess,
          let data = item as? Data,
          let password = String(data: data, encoding: .utf8) else {
      throw KeychainError.unexpectedStatus(status)
    }
    return password
  }

  static func deletePassword(account: String) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ]
    SecItemDelete(query as CFDictionary)
  }
}
