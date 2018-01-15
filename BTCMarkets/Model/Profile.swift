//
//  Profile.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

struct Profile: Codable {
  var profileName: String
  var currency: Currency
  var instruments: [Currency]
  
  private enum CodingKeys: CodingKey {
    case profileName, currency, instruments
  }
  
  init(profileName: String, currency: Currency, instruments: [Currency]) {
    self.profileName = profileName
    self.currency = currency
    self.instruments = instruments
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    profileName = try container.decode(String.self, forKey: .profileName)
    currency = try container.decode(Currency.self, forKey: .currency)
    instruments = try container.decode(Array<Currency>.self, forKey: .instruments)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(profileName, forKey: .profileName)
    try container.encode(currency, forKey: .currency)
    try container.encode(instruments, forKey: .instruments)
  }
}
