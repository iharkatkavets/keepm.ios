//
//  DatabaseCredentialsStore.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 3/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
// https://stackoverflow.com/questions/11614047/what-makes-a-keychain-item-unique-in-ios


class CredentialsStore {
    enum KeychainError: Error, Equatable {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    enum CredentialsItem: Equatable, Codable {
        case password(_: String, file: String)
    }



    func saveCredentials(_ item: CredentialsItem) throws {
        switch item {
        case .password(_, let file):
            let encoder = JSONEncoder()
            guard let encodedPassword = try? encoder.encode(item) else {
                throw KeychainError.unexpectedItemData
            }

            do {
                _ = try fetchCredentials(file)

                let query = queryPassword(file)


                let attrToUpdate: [String: Any] = [kSecValueData as String: encodedPassword]
                let status = SecItemUpdate(query as CFDictionary, attrToUpdate as CFDictionary)
                guard status == noErr else {
                    throw KeychainError.unhandledError(status: status)
                }
            } catch KeychainError.noPassword {
                let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrAccount as String: file,
                                            kSecAttrService as String: file,
                                            kSecValueData as String: encodedPassword]
                let status = SecItemAdd(query as CFDictionary, nil)
                guard status == errSecSuccess else {
                    throw KeychainError.unhandledError(status: status)
                }
            }
        }
    }

    func queryPassword(_ file: String) -> [String: Any] {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: file,
                                    kSecAttrService as String: file]
        return query
    }

    func updateCredentials(_ item: CredentialsItem) {
        
    }

    func fetchCredentials(_ file: String) throws -> CredentialsItem {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: file,
                                    kSecAttrService as String: file,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }

        let decoder = JSONDecoder()
        guard status == errSecSuccess,
            let queriedItem = item as? [String: Any],
            let data = queriedItem[String(kSecValueData)] as? Data else {
                throw KeychainError.unhandledError(status: status)
        }

        do {
            let credentials = try decoder.decode(CredentialsItem.self, from: data)
            return credentials
        } catch {
            throw KeychainError.unhandledError(status: status)
        }
    }


    func deleteCredentialsForFile(_ file: String) throws {
        let query = queryPassword(file)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
}

extension CredentialsStore.CredentialsItem {
    private enum CodingKeys: String, CodingKey {
        case password
        case file
    }

    enum CredentialsItemCodingError: Error {
        case decoding(String)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let password = try? values.decode(String.self, forKey: .password),
            let file = try? values.decode(String.self, forKey: .file) {
            self = .password(password, file: file)
            return
        }
        throw CredentialsItemCodingError.decoding("Whoops! \(dump(values))")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .password(let password, let file):
            try container.encode(password, forKey: .password)
            try container.encode(file, forKey: .file)
        }
    }
}
