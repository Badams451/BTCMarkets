//
//  ApplicationHoldingsStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

private let holdingsKey = "holdings"

class HoldingsStore {
  typealias Subscriber = String
  typealias Holdings = [Currency: Float]
  typealias HoldingsChanged = (Holdings) -> Void
  
  private var holdings: Holdings = Holdings() {
    didSet {
      subscribers.forEach { $0.1(holdings) }
    }
  }
  private let userDefaults = UserDefaults.standard
  private var subscribers: [(Subscriber, HoldingsChanged)] = []
  
  static var sharedInstance: HoldingsStore = HoldingsStore()
  
  init() {
    instantiateStore()
  }
  
  private func instantiateStore() {
    guard let encodedHoldings = userDefaults.object(forKey: holdingsKey) as? Data else {
      createDefaultHoldings()
      return
    }
    
    guard let decodedHoldings = (try? PropertyListDecoder().decode(Holdings.self, from: encodedHoldings)) else {
      return
    }
    
    holdings = decodedHoldings
  }
  
  private func createDefaultHoldings() {
    var holdings = [Currency: Float]()
    Currency.allValues.forEach { holdings[$0] = 0 }
    self.holdings = holdings
    persistHoldings()
  }
  
  private func persistHoldings() {
    let encodedHoldings = try? PropertyListEncoder().encode(holdings)
    userDefaults.set(encodedHoldings, forKey: holdingsKey)
  }
  
  func storeHolding(currency: Currency, amount: Float) {
    holdings[currency] = amount
    persistHoldings()
  }
  
  func holdingsAmount(forCurrency currency: Currency) -> Float {
    return holdings[currency] ?? 0
  }
  
  func subscribe(subscriber: Subscriber, callback: @escaping HoldingsChanged) {
    subscribers.append((subscriber, callback))
    callback(holdings)
  }
  
  func unsubscribe(subscriber: Subscriber) {
    if let subscriberIndex = (subscribers.index { return $0.0 == subscriber }) {
      subscribers.remove(at: subscriberIndex)
    }
  }
}
