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
  
  typealias TicksForTimeWindow = [TimeWindow: [Tick]]
  typealias TicksForTimePeriod = [TimePeriod : TicksForTimeWindow]
  typealias CurrencyInstrumentPair = String
  typealias CurrencyInstrumentTimeWindow = String
  typealias Subscriber = String
  typealias Instrument = Currency
  typealias TicksChanged = (TickStore) -> Void
  typealias TickStore = ThreadSafeDictionary<CurrencyInstrumentPair, TicksForTimePeriod>
  typealias TickUpdatedStore = ThreadSafeDictionary<CurrencyInstrumentTimeWindow, TimeInterval>
  
  static var sharedInstance: TickHistoryStore = TickHistoryStore()
  private var subscribers: [(Subscriber, TicksChanged)] = []
  private var tickUpdatedStore: TickUpdatedStore = TickUpdatedStore()
  private let timeUntilStaleCache: TimeInterval = 1.minutes
  private var tickStore = TickStore()
  
  func subscribe(subscriber: Subscriber, callback: @escaping TicksChanged) {
    subscribers.append((subscriber, callback))
    callback(tickStore)
  }
  
  func unsubscribe(subscriber: Subscriber) {
    if let subscriberIndex = (subscribers.index { return $0.0 == subscriber }) {
      subscribers.remove(at: subscriberIndex)
    }
  }
  
  func tick(closestTo timeInterval: TimeInterval, forCurrency instrument: Currency, timePeriod: TimePeriod, timeWindow: TimeWindow) -> Tick? {
    let ticks = self.ticks(forTimePeriod: timePeriod, timewindow: timeWindow, currency: .aud, instrument: instrument)
    return ticks.first { return $0.timestamp >= timeInterval }
  }
  
  private func ticks(forTimePeriod timePeriod: TimePeriod, timewindow: TimeWindow, currency: Currency, instrument: Currency) -> [Tick] {
    let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
    guard let ticksForTimePeriod = tickStore[currencyInstrumentPair] else {
      return []
    }
    
    guard let ticksForTimeWindow = ticksForTimePeriod[timePeriod] else {
      return []
    }
    
    guard let ticks = ticksForTimeWindow[timewindow] else {
      return []
    }
    
    return ticks
  }
  
  func store(ticks: [Tick], forTimePeriod timePeriod: TimePeriod, forTimeWindow timeWindow: TimeWindow, currency: Currency, instrument: Instrument) {
    let needsAggregation = timePeriod == .week || timePeriod == .month
    let chunkSize = self.chunkSize(forTimePeriod: timePeriod)
    let ticks = needsAggregation ? aggregateTicks(for: ticks, chunkSize: chunkSize) : ticks
    let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
    if tickStore[currencyInstrumentPair] == nil {
      tickStore[currencyInstrumentPair] = TicksForTimePeriod()
    }
    
    if tickStore[currencyInstrumentPair]![timePeriod] == nil {
      tickStore[currencyInstrumentPair]![timePeriod] = TicksForTimeWindow()
    }
    
    tickStore[currencyInstrumentPair]![timePeriod]![timeWindow] = ticks 
    tickUpdatedStore["\(currency.rawValue)\(instrument.rawValue)\(timePeriod.rawValue)\(timeWindow.rawValue)"] = .now
    notifySubscribers()
  }
  
  private func chunkSize(forTimePeriod timePeriod: TimePeriod) -> Int {
    switch timePeriod {
    case .day: return 1
    case .week: return 6
    case .month: return 12
    }
  }
  
  private func aggregateTicks(for ticks:[Tick], chunkSize: Int) -> [Tick] {
    let splitTicks = ticks.chunks(chunkSize)
    let aggregatedTicks = splitTicks.map { ticks -> Tick in
      let time = ticks.first?.timestamp
      let open = ticks.first?.open
      let close = ticks.last?.close
      let high = ticks.map { $0.high }.max()
      let low = ticks.map { $0.low }.min()
      return Tick(timestamp: time!, low: low!, high: high!, open: open!, close: close!, date: ticks.first!.date!)
    }
    
    return aggregatedTicks
  }
  
  private func notifySubscribers() {
    subscribers.forEach { $0.1(tickStore) }
  }
  
  func fetchTickerHistory(forTimeWindow timeWindow: TimeWindow, timePeriod: TimePeriod, startingTime: TimeInterval, currency: Currency, instrument: Instrument) {
    DispatchQueue.global().async {
      let dataCachedKey = "\(currency.rawValue)\(instrument.rawValue)\(timePeriod.rawValue)\(timeWindow.rawValue)"
      if let lastUpdate = self.tickUpdatedStore[dataCachedKey], lastUpdate < TimeInterval.now + self.timeUntilStaleCache {
        self.notifySubscribers()
        return
      }
      
      let api = RestfulAPI()
      let endTime = TimeInterval.now
      
      api.tickerHistory(from: startingTime.intValue,
                        to: endTime.intValue,
                        forTimeWindow: timeWindow,
                        currency: currency.rawValue,
                        instrument: instrument.rawValue).then { response -> Void in
                          DispatchQueue.global().async {
                            guard let data = response["ticks"] as? [[Int]] else {
                              return
                            }
                            
                            let filteredData = data.drop { array in
                              guard let timestamp = array.first else {
                                return true
                              }
                              
                              let normalisedTimestamp = timestamp.doubleValue / timestampNormalisationFactor
                              return normalisedTimestamp < startingTime
                            }
                            
                            let ticks = filteredData.compactMap { tickData -> Tick? in
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
                            
                            self.store(ticks: ticks, forTimePeriod: timePeriod, forTimeWindow: timeWindow, currency: currency, instrument: instrument)
                          }
        }.catch { error in
          print("Could not fetch ticker history: \(error)")
      }
    }
  }
}


private extension Array {
  func chunks(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
    }
  }
}
