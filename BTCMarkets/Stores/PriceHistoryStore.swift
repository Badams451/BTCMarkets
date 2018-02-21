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
  
  func update(price: Double, forCurrency currency: Currency) {
    pastDayPriceHistory[currency] = price
  }
}
