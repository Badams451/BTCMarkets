//
//  UserStatisticsStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 6/8/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

let darkModeOnKey = "dark.mode.key"

class SettingsStore {
  private let userDefaults = UserDefaults.standard
  static var sharedInstance: SettingsStore = SettingsStore()

  var isDarkModeOn: Bool {
    return userDefaults.bool(forKey: darkModeOnKey)
  }

  func toggleDarkModel() {
    userDefaults.set(!isDarkModeOn, forKey: darkModeOnKey)
  }
}
