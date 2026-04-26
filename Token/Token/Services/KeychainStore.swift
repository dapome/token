import Foundation
import Security

struct KeychainStore {
    private let serviceName = Bundle.main.bundleIdentifier ?? "dev.usagebuddy.token"

    func value(for provider: ProviderKind) -> String? {
        let query = baseQuery(for: provider).merging([
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]) { _, newValue in
            newValue
        }

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8),
              !value.isEmpty else {
            return nil
        }

        return value
    }

    func save(_ value: String, for provider: ProviderKind) throws {
        let data = Data(value.utf8)
        let query = baseQuery(for: provider)

        let attributes: [String: Any] = [
            kSecValueData as String: data,
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard updateStatus != errSecItemNotFound else {
            let creationQuery = query.merging(attributes) { _, newValue in
                newValue
            }
            let addStatus = SecItemAdd(creationQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(addStatus))
            }
            return
        }

        guard updateStatus == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(updateStatus))
        }
    }

    func deleteValue(for provider: ProviderKind) throws {
        let status = SecItemDelete(baseQuery(for: provider) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    private func baseQuery(for provider: ProviderKind) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: provider.keychainAccount,
        ]
    }
}
