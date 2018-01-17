//
//  Currency.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 12/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import ObjectMapper

struct Coin: Mappable {
  var bestBid: Double = 0
  var bestAsk: Double = 0
  var lastPrice: Double = 0
  var currency: String = ""
  var instrument: String = ""
  var timeStamp: Int = 0
  var volume24h: Int = 0
  
  init?(map: Map) {
  }
  
  mutating func mapping(map: Map) {
    bestBid <- map["bestBid"]
    bestAsk <- map["bestAsk"]
    lastPrice <- map["lastPrice"]
    currency <- map["currency"]
    instrument <- map["instrument"]
    timeStamp <- map["timeStamp"]
    volume24h <- map["volume24h"]
  }
  
  // Due to websocket api returning data that is 8 magnitudes bigger than the actual data
  mutating func normaliseValues() {
    bestBid /= 100000000
    bestAsk /= 100000000
    lastPrice /= 100000000
    timeStamp /= 100000000
    volume24h /= 100000000
  }
  
  private func normalise(value: Double?) -> Double? {
    guard let value = value else { return nil }
    return value / 100000000
  }
  
  private func normalise(value: Int?) -> Int? {
    guard let value = value else { return nil }
    return value / 100000000
  }
}

extension Coin {
  var displayPrice: String {
    return !lastPrice.isZero ? "\(lastPrice.dollarValue)" : ""
  }
  
  var displayBestBid: String {
    return !bestBid.isZero ? "\(bestBid.dollarValue)" : ""
  }
  
  var displayBestAsk: String {
    return !bestAsk.isZero ? "\(bestAsk.dollarValue)" : ""
  }
  
  var displayVolume: String {
    return volume24h != 0 ? "\(volume24h)" : ""
  }
}
