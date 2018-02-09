//
//  UserStatisticsStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 9/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

let appStatsAppBecomeActiveKey = "app.statistics.appDidBecomeActiveCount"
let appStatsCoinDetailViewedKey = "app.statistics.coinDetailViewedCount"
let appStatsHoldingsEnteredKey = "app.statistics.holdingsEnteredCount"

class UserStatisticsStore {
  private let userDefaults = UserDefaults.standard
  static var sharedInstance: UserStatisticsStore = UserStatisticsStore()

  func incrementStatistic(forKey key: String) {
    let value = userDefaults.integer(forKey: key)
    let newValue = value + 1
    userDefaults.set(newValue, forKey: key)
  }
  
  var appDidBecomeActiveCount: Int {
    return userDefaults.integer(forKey: appStatsAppBecomeActiveKey)
  }
  
  var coinDetailViewedCount: Int {
    return userDefaults.integer(forKey: appStatsCoinDetailViewedKey)
  }
  
  var holdingsEnteredCount: Int {
    return userDefaults.integer(forKey: appStatsHoldingsEnteredKey)
  }
}
