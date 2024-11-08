//
//  JellyfinAccountService.swift
//  BookPlayer
//
//  Created by Lysann Schlegel on 2024-11-06.
//  Copyright © 2024 Tortuga Power. All rights reserved.
//

import Foundation

struct JellyfinConnectionData {
  let url: URL
  let userID: String
  let userName: String
  let accessToken: String
}

/// sourcery: AutoMockable
protocol JellyfinAccountServiceProtocol {
  func findSavedConnection() throws -> JellyfinConnectionData?
  func saveConnection(_ data: JellyfinConnectionData) throws
  func removeSavedConnection() throws
}

class JellyfinAccountService : JellyfinAccountServiceProtocol {
  static let serviceName = "Jellyfin Service"

  func findSavedConnection() throws -> JellyfinConnectionData? {
    let query = buildQuery().merging([kSecMatchLimit as String: kSecMatchLimitOne,
                                      kSecReturnAttributes as String: true,
                                      kSecReturnData as String: true], uniquingKeysWith: { (_, new) in new })
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status == errSecItemNotFound {
      return nil
    } else if status != errSecSuccess {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    }
    guard let existingItem = item as? [String : Any],
          let accessTokenData = existingItem[kSecValueData as String] as? Data,
          let accessToken = String(data: accessTokenData, encoding: String.Encoding.utf8),
          let urlString = existingItem[kSecAttrServer as String] as? String,
          let url = URL(string: urlString),
          let userID = existingItem[kSecAttrAccount as String] as? String
    else {
      return nil
    }
    let userName = existingItem[kSecAttrComment as String] as? String ?? ""
    return JellyfinConnectionData(url: url, userID: userID, userName: userName, accessToken: accessToken)
  }

  func saveConnection(_ data: JellyfinConnectionData) throws {
    guard let secureData = data.accessToken.data(using: .utf8, allowLossyConversion: false) else {
      // conversionError
      throw NSError(domain: NSOSStatusErrorDomain, code: -67594)
    }

    let query = buildQuery()
    let attributes: [String: Any] = [kSecAttrServer as String: data.url.absoluteString,
                                     kSecAttrAccount as String: data.userID,
                                     kSecAttrComment as String: data.userName,
                                     kSecValueData as String: secureData]
    var status = SecItemUpdate(buildQuery() as CFDictionary, attributes as CFDictionary)
    if status != errSecSuccess {
      let newItemAttributes = query.merging(attributes, uniquingKeysWith: { (_, new) in new })
      status = SecItemAdd(newItemAttributes as CFDictionary, nil)
      if status != errSecSuccess {
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
      }
    }
  }

  func removeSavedConnection() throws {
    let query = buildQuery()
    let status = SecItemDelete(query as CFDictionary)
    if status != errSecSuccess && status != errSecItemNotFound {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    }
  }

  private func buildQuery() -> [String: Any] {
    return [kSecClass as String: kSecClassInternetPassword,
            kSecAttrLabel as String: Self.serviceName ]
  }
}
