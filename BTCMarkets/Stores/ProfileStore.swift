//
//  ApplicationData.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 14/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

private let profilesKey = "profiles"
private let selectedProfileKey = "selectedProfile"

class ProfileStore {
  typealias ProfilesChanged = ([Profile]) -> Void
  typealias SelectedProfileChanged = (Profile?) -> Void
  typealias Subscriber = String
  
  static var sharedInstance: ProfileStore = ProfileStore()
  private var profileSubscribers: [(Subscriber, ProfilesChanged)] = []
  private var selectedProfileSubscribers: [(Subscriber, SelectedProfileChanged)] = []
  let defaultProfile = Profile(profileName: "CoinTracker", currency: .aud, instruments: [.btc, .ltc, .xrp, .eth, .bch])
  
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
      addOrUpdateProfile(profile: defaultProfile)
      setSelectedProfile(profile: defaultProfile)
      return
    }
    
    guard let decodedProfiles = (try? PropertyListDecoder().decode(Array<Profile>.self, from: encodedProfiles)) else {
      return
    }
    
    self.profiles = decodedProfiles
  }

}

// Mark: CRUD

extension ProfileStore {
  private func saveProfiles() {
    let userDefaults = UserDefaults.standard
    let encodedProfiles = try? PropertyListEncoder().encode(profiles)
    userDefaults.set(encodedProfiles, forKey: profilesKey)
  }
  
  func addOrUpdateProfile(profile: Profile) {
    if let existingProfileIndex = (profiles.index { $0.profileName == profile.profileName }) {
      profiles.remove(at: existingProfileIndex)
    }
    profiles.insert(profile, at: 0)
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

// Mark: Subscribe
extension ProfileStore {
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
