//
//  Notification+BookPlayerKit.swift
//  BookPlayerKit
//
//  Created by Gianni Carlo on 4/25/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//

import UIKit

extension Notification.Name {
  public static let chapterChange = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).book.chapter")
  public static let bookPlayed = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).book.play")
  public static let bookPaused = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).book.pause")
  public static let bookEnd = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).book.end")
  public static let bookPlaying = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).book.playback")
  public static let bookReady = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).book.ready")
  public static let messageReceived = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).watch.message")
  public static let accountUpdate = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).account.update")
  public static let login = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).account.login")
  public static let logout = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).account.logout")
  public static let itemMetadatUploaded = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).item.metadata.upload")
  public static let folderProgressUpdated = Notification.Name("\(Bundle.main.configurationString(for: .bundleIdentifier)).folder.progress.update")
}
