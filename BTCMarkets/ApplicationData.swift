//
//  ApplicationData.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 14/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

enum Currency: String, Codable {
  case aud = "AUD"
  case btc = "BTC"
  case ltc = "LTC"
  case xrp = "XRP"
  case eth = "ETH"
  case bch = "BCH"
  
  func coinName() -> String {
    switch self {
    case .aud: return "AUD"
    case .btc: return "Bitcoin"
    case .ltc: return "Litecoin"
    case .xrp: return "Ripple"
    case .eth: return "Ethereum"
    case .bch: return "BCash"
    }
  }
}

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

struct ApplicationData {
  var profiles: [Profile] = []
  private let profilesKey = "profiles"
  
  init() {
    self.retrieveProfiles()
  }
  
  private mutating func retrieveProfiles() {
    let userDefaults = UserDefaults.standard
    guard let encodedProfiles = userDefaults.object(forKey: profilesKey) as? Data else {
      return
    }
    
    guard let decodedProfiles = (try? PropertyListDecoder().decode(Array<Profile>.self, from: encodedProfiles)) else {
      return
    }
    
    self.profiles = decodedProfiles
  }
  
  func storeProfiles() {
    let userDefaults = UserDefaults.standard
    let encodedProfiles = try? PropertyListEncoder().encode(profiles)
    userDefaults.set(encodedProfiles, forKey: profilesKey)
  }
  
  mutating func addProfile(profile: Profile) {
    profiles.append(profile)
  }
  
}
