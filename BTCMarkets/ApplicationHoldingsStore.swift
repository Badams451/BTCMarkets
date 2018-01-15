//
//  ApplicationHoldingsStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

private let holdingsKey = "holdings"
private typealias Holdings = [Currency: Float]

class ApplicationHoldingsStore {
  private var holdings: Holdings = Holdings()
  private let userDefaults = UserDefaults.standard
  
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
}
