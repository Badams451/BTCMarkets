//
//  PriceHistoryStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 21/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

final class PriceHistoryStore {
  
  typealias PriceHistoryCollection = [Currency: Double]
  static var sharedInstance: PriceHistoryStore = PriceHistoryStore()
  private(set) var pastDayPriceHistory: PriceHistoryCollection = PriceHistoryCollection()
  private var lastUpdateTime = TimeInterval.now
  private var timeUntilInvalidCache: TimeInterval {
    return 10 + lastUpdateTime
  }
  
  var priceIsOutdated: Bool {
    return TimeInterval.now > timeUntilInvalidCache
  }
  
  func update(price: Double, forCurrency currency: Currency) {
    pastDayPriceHistory[currency] = price
    lastUpdateTime = TimeInterval.now
  }
}
