//
//  Ticker.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

struct TickerProfile: Codable {
  var tickerName: String
  var currency: Currency
  var instruments: [Currency]
  
  private enum CodingKeys: CodingKey {
    case tickerName, currency, instruments
  }
  
  init(tickerName: String, currency: Currency, instruments: [Currency]) {
    self.tickerName = tickerName
    self.currency = .aud
    self.instruments = instruments
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    tickerName = try container.decode(String.self, forKey: .tickerName)
    currency = .aud
    instruments = try container.decode(Array<Currency>.self, forKey: .instruments)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(tickerName, forKey: .tickerName)
    try container.encode(Currency.aud, forKey: .currency)
    try container.encode(instruments, forKey: .instruments)
  }
}
