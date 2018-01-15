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
  
  var coinName: String {
    switch self {
    case .aud: return "AUD"
    case .btc: return "Bitcoin"
    case .ltc: return "Litecoin"
    case .xrp: return "Ripple"
    case .eth: return "Ethereum"
    case .bch: return "BCash"
    }
  }
  
  static var allValues: [Currency] {
    return [.aud, .btc, .ltc, .xrp, .eth, .bch]
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

class ApplicationData {
  typealias ProfilesChanged = ([Profile]) -> Void
  typealias SelectedProfileChanged = (Profile?) -> Void
  typealias Subscriber = String
  
  static var sharedInstance: ApplicationData = ApplicationData()
  
  private let profilesKey = "profiles"
  private let selectedProfileKey = "selectedProfile"
  private var profileSubscribers: [(Subscriber, ProfilesChanged)] = []
  private var selectedProfileSubscribers: [(Subscriber, SelectedProfileChanged)] = []
  
  init() {
    retrieveProfiles()
  }
  
  var profiles: [Profile] = [] {
    didSet {
      profileSubscribers.forEach { subscriber in subscriber.1(profiles) }
    }
  }
  
  var selectedProfile: Profile? {
    guard let profileName = UserDefaults.standard.object(forKey: selectedProfileKey) as? String else {
      return nil
    }
    let profile = profiles.filter { $0.profileName == profileName }.first
    return profile
  }
  
  private func retrieveProfiles() {
    let userDefaults = UserDefaults.standard
    guard let encodedProfiles = userDefaults.object(forKey: profilesKey) as? Data else {
      return
    }
    
    guard let decodedProfiles = (try? PropertyListDecoder().decode(Array<Profile>.self, from: encodedProfiles)) else {
      return
    }
    
    self.profiles = decodedProfiles
  }
  
  private func saveProfiles() {
    let userDefaults = UserDefaults.standard
    let encodedProfiles = try? PropertyListEncoder().encode(profiles)
    userDefaults.set(encodedProfiles, forKey: profilesKey)
  }

  func addProfile(profile: Profile) {
    profiles.append(profile)
    saveProfiles()
  }
  
  func setSelectedProfile(profile: Profile) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(profile.profileName, forKey: selectedProfileKey)
    selectedProfileSubscribers.forEach { $0.1(selectedProfile) }
  }
  
  func delete(profile: Profile) {
    let index = profiles.index { $0.profileName == profile.profileName }
    
    if let index = index {
      profiles.remove(at: index)
      saveProfiles()
    }
  }
}

// Subscribe
extension ApplicationData {
  func subscribeSelectedProfile(target: Subscriber, callback: @escaping SelectedProfileChanged)  {
    selectedProfileSubscribers.append((target, callback))
    callback(selectedProfile)
  }
  
  func subscribeProfileChange(target: Subscriber, callback: @escaping ProfilesChanged)  {
    profileSubscribers.append((target, callback))
    callback(profiles)
  }
  
  func unsubscribe(target: Subscriber) {
    let profileSubscriberIndex = profileSubscribers.index { (result) -> Bool in
      return result.0 == target
    }
    
    if let profileSubscriberIndex = profileSubscriberIndex {
      profileSubscribers.remove(at: profileSubscriberIndex)
    }
    
    let selectedProfileSubscriberIndex = selectedProfileSubscribers.index { (result) -> Bool in
      return result.0 == target
    }
    
    if let selectedProfileSubscriberIndex = selectedProfileSubscriberIndex {
      selectedProfileSubscribers.remove(at: selectedProfileSubscriberIndex)
    }
  }
}
