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
  var bestBid: Float?
  var bestAsk: Float?
  var lastPrice: Float?
  var currency: String = ""
  var instrument: String = ""
  var timeStamp: Int?
  var volume24h: Int?
  
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
    bestBid = normalise(value: bestBid)
    bestAsk = normalise(value: bestAsk)
    lastPrice = normalise(value: lastPrice)
    timeStamp = normalise(value: timeStamp)
    volume24h = normalise(value: volume24h)
  }
  
  private func normalise(value: Float?) -> Float? {
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
    return lastPrice != nil ? "$\(lastPrice!)" : ""
  }
  
  var displayBestBid: String {
    return bestBid != nil ? "Bid: \(bestBid!)" : ""
  }
  
  var displayBestAsk: String {
    return bestAsk != nil ? "Ask: \(bestAsk!)" : ""
  }
  
  var displayVolume: String {
    return volume24h != nil ? "Vol(24h): \(volume24h!)" : ""
  }
}
