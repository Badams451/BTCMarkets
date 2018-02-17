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
  
  typealias TicksForTimeWindow = [TimePeriod : [Tick]]
  typealias CurrencyInstrumentPair = String
  typealias TickStore = [CurrencyInstrumentPair: TicksForTimeWindow]
  typealias CurrencyInstrumentTimeWindow = String
  typealias Subscriber = String
  typealias Instrument = Currency
  typealias TicksChanged = (TickStore) -> Void
  
  static var sharedInstance: TickHistoryStore = TickHistoryStore()
  private var subscribers: [(Subscriber, TicksChanged)] = []
  private var tickUpdatedStore: [CurrencyInstrumentTimeWindow: TimeInterval] = [:]
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
  
  func ticks(forTimePeriod timePeriod: TimePeriod, currency: Currency, instrument: Currency) -> [Tick] {
    let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
    guard let ticksForTimeWindow = tickStore[currencyInstrumentPair] else {
      return []
    }
    
    guard let ticks = ticksForTimeWindow[timePeriod] else {
      return []
    }
    
    return ticks
  }
  
  func store(ticks: [Tick], forTimePeriod timePeriod: TimePeriod, currency: Currency, instrument: Instrument) {
    let needsAggregation = timePeriod == .week || timePeriod == .month
    let chunkSize = self.chunkSize(forTimePeriod: timePeriod)
    let ticks = needsAggregation ? aggregateTicks(for: ticks, chunkSize: chunkSize) : ticks
    let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
    if let _ = tickStore[currencyInstrumentPair] {
      tickStore[currencyInstrumentPair]![timePeriod] = ticks
    } else {
      tickStore[currencyInstrumentPair] = TicksForTimeWindow()
      tickStore[currencyInstrumentPair]![timePeriod] = ticks
    }
    
    tickUpdatedStore["\(currency.rawValue)\(instrument.rawValue)\(timePeriod.rawValue)"] = .now
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
      if let lastUpdate = self.tickUpdatedStore[dataCachedKey], lastUpdate > TimeInterval.now - self.timeUntilStaleCache {
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
                          
                          self.store(ticks: ticks, forTimePeriod: timePeriod, currency: currency, instrument: instrument)
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
