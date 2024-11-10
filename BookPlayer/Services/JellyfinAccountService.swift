//
//  JellyfinAccountService.swift
//  BookPlayer
//
//  Created by Lysann Schlegel on 2024-11-06.
//  Copyright © 2024 Tortuga Power. All rights reserved.
//

import Foundation

struct JellyfinConnectionData {
  let serverUrl: URL
  let serverName: String
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
          let serverUrlString = existingItem[kSecAttrServer as String] as? String,
          let serverUrl = URL(string: serverUrlString),
          let userID = existingItem[kSecAttrAccount as String] as? String
    else {
      return nil
    }
    let additionalData = decodeAdditionalData(existingItem[kSecAttrComment as String] as? String ?? "")
    return JellyfinConnectionData(serverUrl: serverUrl,
                                  serverName: additionalData.serverName,
                                  userID: userID,
                                  userName: additionalData.userName,
                                  accessToken: accessToken)
  }

  func saveConnection(_ data: JellyfinConnectionData) throws {
    guard let secureData = data.accessToken.data(using: .utf8, allowLossyConversion: false) else {
      // conversionError
      throw NSError(domain: NSOSStatusErrorDomain, code: -67594)
    }

    let query = buildQuery()
    let attributes: [String: Any] = [kSecAttrServer as String: data.serverUrl.absoluteString,
                                     kSecAttrAccount as String: data.userID,
                                     kSecAttrComment as String: encodeAdditionalData(data),
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

  private struct AdditionalData : Codable {
    let serverName: String
    let userName: String
  }
  private func encodeAdditionalData(_ data: JellyfinConnectionData) -> String {
    encodeAdditionalData(AdditionalData(serverName: data.serverName,
                                        userName: data.userName))
  }
  private func encodeAdditionalData(_ data: AdditionalData) -> String {
    do {
      let jsonEncoder = JSONEncoder()
      let jsonResultData = try jsonEncoder.encode(data)
      return String(data: jsonResultData, encoding: .utf8)!
    } catch {
      return ""
    }
  }
  private func decodeAdditionalData(_ data: String) -> AdditionalData {
    do {
      let jsonDecoder = JSONDecoder()
      let jsonData = data.data(using: .utf8)!
      let jsonResultData = try jsonDecoder.decode(AdditionalData.self, from: jsonData)
      return jsonResultData
    } catch {
      return AdditionalData(serverName: "", userName: "")
    }
  }
}
