//
//  Currency.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 12/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import ObjectMapper

struct Currency: Mappable {
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
}

extension Currency {
  var displayPrice: String {
    return lastPrice != nil ? "\(lastPrice!)" : ""
  }
  
  var displayBestBid: String {
    return bestBid != nil ? "\(bestBid!)" : ""
  }
  
  var displayBestAsk: String {
    return bestAsk != nil ? "\(bestAsk!)" : ""
  }
  
  var displayVolume: String {
    return volume24h != nil ? "\(volume24h!)" : ""
  }
}
