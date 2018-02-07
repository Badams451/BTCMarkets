//
//  TickerHistoryStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 7/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

private let timestampNormalisationFactor: Double = 1000
private let tickerAmountNormalisationFactor: Double = 100000000

final class TickHistoryStore {
  typealias TicksForTimeWindow = [TimeWindow : [Tick]]
  typealias CurrencyInstrumentPair = String
  typealias TickStore = [CurrencyInstrumentPair: TicksForTimeWindow]
  typealias CurrencyInstrumentTimeWindow = String
  typealias Subscriber = String
  typealias Instrument = Currency
  typealias TicksChanged = (TickStore) -> Void
  
  static var sharedInstance: CoinsStoreBtc = CoinsStoreBtc()
  private var subscribers: [(Subscriber, TicksChanged)] = []
  private var tickUpdatedStore: [CurrencyInstrumentTimeWindow: TimeInterval] = [:]
  private let timeUntilStaleCache: TimeInterval = 1.minutes
  private(set) var tickStore = TickStore()
  
  private var timeIntervalNow: TimeInterval {
    return Date().timeIntervalSinceNow
  }
  
  func subscribe(subscriber: Subscriber, callback: @escaping TicksChanged) {
    subscribers.append((subscriber, callback))
    callback(tickStore)
  }
  
  func unsubscribe(subscriber: Subscriber) {
    if let subscriberIndex = (subscribers.index { return $0.0 == subscriber }) {
      subscribers.remove(at: subscriberIndex)
    }
  }
  
  func tickers(forTimeWindow timeWindow: TimeWindow, currency: Currency, instrument: Currency) -> [Tick] {
    let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
    guard let ticksForTimeWindow = tickStore[currencyInstrumentPair] else {
      return []
    }
    
    guard let ticks = ticksForTimeWindow[timeWindow] else {
      return []
    }
    
    return ticks
  }
  
  func store(ticks: [Tick], forTimeWindow timeWindow: TimeWindow, currency: Currency, instrument: Instrument) {
    let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
    if let _ = tickStore[currencyInstrumentPair] {
      tickStore[currencyInstrumentPair]![timeWindow] = ticks
    } else {
      tickStore[currencyInstrumentPair] = TicksForTimeWindow()
      tickStore[currencyInstrumentPair]![timeWindow] = ticks
    }
    
    tickUpdatedStore["\(currency.rawValue)\(instrument.rawValue)\(timeWindow.rawValue)"] = timeIntervalNow
    notifySubscribers()
  }
  
  private func notifySubscribers() {
    subscribers.forEach { $0.1(tickStore) }
  }
  
  func fetchTickerHistory(forTimeWindow timeWindow: TimeWindow, startingTime: TimeInterval, currency: Currency, instrument: Instrument) {
    
    let dataCachedKey = "\(currency.rawValue)\(instrument.rawValue)\(timeWindow.rawValue)"
    if let lastUpdate = tickUpdatedStore[dataCachedKey], lastUpdate > timeIntervalNow - timeUntilStaleCache {
      notifySubscribers()
      return
    }
    
    let api = RestfulAPI()
    let endTime = Date().timeIntervalSince1970
    
    api.tickerHistory(from: startingTime.intValue,
                      to: endTime.intValue,
                      forTimeWindow: timeWindow,
                      currency: currency.rawValue,
                      instrument: instrument.rawValue).then { response -> Void in
      guard let data = response["ticks"] as? [[Int]] else {
        return
      }
                        
      let filteredData = data.drop { array in
        guard let timestamp = array.first else {
          return true
        }
        
        return timestamp / timestampNormalisationFactor.intValue < Int(startingTime)
      }
                        
      let ticks = filteredData.flatMap { tickData -> Tick? in
        guard tickData.count == 6 else {
          return nil
        }
        
        let timestamp = tickData[0].doubleValue / timestampNormalisationFactor
        let open = tickData[1].doubleValue / tickerAmountNormalisationFactor
        let high = tickData[2].doubleValue / tickerAmountNormalisationFactor
        let low = tickData[3].doubleValue / tickerAmountNormalisationFactor
        let close = tickData[4].doubleValue / tickerAmountNormalisationFactor
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        return Tick(timestamp: timestamp, low: low, high: high, open: open, close: close, date: date)
      }
      
      self.store(ticks: ticks, forTimeWindow: timeWindow, currency: currency, instrument: instrument)
    }.catch { error in
      print("Could not fetch ticker history: \(error)")
    }
  }
}
