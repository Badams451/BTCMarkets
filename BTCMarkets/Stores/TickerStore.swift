//
//  ApplicationData.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 14/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

private let tickersKey = "tickers"
private let selectedTickerKey = "selectedTicker"

class TickerStore {
  typealias TickersChanged = ([TickerProfile]) -> Void
  typealias SelectedTickerChanged = (TickerProfile?) -> Void
  typealias Subscriber = String
  
  static var sharedInstance: TickerStore = TickerStore()
  private var tickerSubscribers: [(Subscriber, TickersChanged)] = []
  private var selectedTickerSubscribers: [(Subscriber, SelectedTickerChanged)] = []
  let defaultTicker = TickerProfile(tickerName: "Ticker", currency: .aud, instruments: [.btc, .ltc, .eth, .etc, .xrp, .bch])
  
  init() {
    retrieveTickers()
  }
  
  var tickers: [TickerProfile] = [] {
    didSet {
      tickerSubscribers.forEach { subscriber in subscriber.1(tickers) }
    }
  }
  
  var selectedTicker: TickerProfile? {
    let tickerName = "Ticker"
    let ticker = tickers.filter { $0.tickerName == tickerName }.first
    return ticker
  }
  
  private func retrieveTickers() {
    let userDefaults = UserDefaults.standard
    guard let encodedTickers = userDefaults.object(forKey: tickersKey) as? Data else {
      addOrUpdateTicker(ticker: defaultTicker)
      setSelectedTicker(ticker: defaultTicker)
      return
    }
    
    guard let decodedTickers = (try? PropertyListDecoder().decode(Array<TickerProfile>.self, from: encodedTickers)) else {
      return
    }
    
    self.tickers = decodedTickers
  }

}

// Mark: CRUD

extension TickerStore {
  private func saveTickers() {
    let userDefaults = UserDefaults.standard
    let encodedTickers = try? PropertyListEncoder().encode(tickers)
    userDefaults.set(encodedTickers, forKey: tickersKey)
  }
  
  func addOrUpdateTicker(ticker: TickerProfile) {
    if let existingTickerIndex = (tickers.index { $0.tickerName == ticker.tickerName }) {
      tickers.remove(at: existingTickerIndex)
    }
    tickers.insert(ticker, at: 0)
    saveTickers()
  }
  
  func setSelectedTicker(ticker: TickerProfile) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(ticker.tickerName, forKey: selectedTickerKey)
    selectedTickerSubscribers.forEach { $0.1(selectedTicker) }
  }
  
  func delete(ticker: TickerProfile) {
    let index = tickers.index { $0.tickerName == ticker.tickerName }
    
    if let index = index {
      tickers.remove(at: index)
      saveTickers()
    }
  }
}

// Mark: Subscribe
extension TickerStore {
  func subscribeSelectedTicker(target: Subscriber, callback: @escaping SelectedTickerChanged)  {
    selectedTickerSubscribers.append((target, callback))
    callback(selectedTicker)
  }
  
  func subscribeTickerChange(target: Subscriber, callback: @escaping TickersChanged)  {
    tickerSubscribers.append((target, callback))
    callback(tickers)
  }
  
  func unsubscribe(target: Subscriber) {
    let tickerSubscriberIndex = tickerSubscribers.index { (result) -> Bool in
      return result.0 == target
    }
    
    if let tickerSubscriberIndex = tickerSubscriberIndex {
      tickerSubscribers.remove(at: tickerSubscriberIndex)
    }
    
    let selectedTickerSubscriberIndex = selectedTickerSubscribers.index { (result) -> Bool in
      return result.0 == target
    }
    
    if let selectedTickerSubscriberIndex = selectedTickerSubscriberIndex {
      selectedTickerSubscribers.remove(at: selectedTickerSubscriberIndex)
    }
  }
}
