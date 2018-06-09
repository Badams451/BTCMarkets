//
//  PriceHistoryStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 21/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

final class DailyPriceHistoryStore {
  
  static var sharedInstance: DailyPriceHistoryStore = DailyPriceHistoryStore()
  private let tickHistoryStore: TickHistoryStore = TickHistoryStore.sharedInstance
  typealias SubscriberID = String
  typealias Price = Double  
  typealias SubscriberCallback = (Price) -> Void
  typealias Subscriber = (subscriberID: SubscriberID, currency: Currency, callback: SubscriberCallback)
  typealias CurrencyInstrumentTimeWindow = ThreadSafeDictionary<Currency, Price>
  typealias PriceHistoryCollection = ThreadSafeDictionary<Currency, Price>

  private var priceHistoryCollection = PriceHistoryCollection()
  private var subscribers: [Subscriber] = []
  
  private var tickHistoryStoreSubscriberID: String {
    return String(describing: self)
  }
  
  init() {
    tickHistoryStore.subscribe(subscriber: tickHistoryStoreSubscriberID) { [weak self] _ in
      guard let strongSelf = self else { return }
      
      for currency in Currency.allExceptAud {
        if let tick = strongSelf.tickHistoryStore.tick(closestTo: TimeInterval.minusOneDay, forCurrency: currency, timePeriod: .day, timeWindow: .minute) {
          strongSelf.update(price: tick.close, forInstrument: currency)
        }
      }
    }
    
    var components = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
    components.minute = components.minute != nil ? components.minute! + 1 : 0
    components.second = 0
    
    let fireDate = Calendar.current.date(from: components)
    
    let timer = Timer(fire: fireDate!, interval: 60, repeats: true) { _ in
      for currency in Currency.allExceptAud {
        if let tick = self.tickHistoryStore.tick(closestTo: TimeInterval.minusOneDay, forCurrency: currency, timePeriod: .day, timeWindow: .minute) {
          self.update(price: tick.close, forInstrument: currency)
        }
      }
    }
    
    RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
  }
  
  deinit {
    tickHistoryStore.unsubscribe(subscriber: tickHistoryStoreSubscriberID)
  }
  
  private func update(price: Double, forInstrument instrument: Currency) {
    priceHistoryCollection[instrument] = price
    
    for subscriber in subscribers {
      if subscriber.currency == instrument {
        subscriber.callback(price)
      }
    }
  }
  
  func subscribe(subscriber: SubscriberID, instrument: Currency, callback: @escaping SubscriberCallback) {
    subscribers.append((subscriber, instrument, callback))
  }
  
  func unsubscribe(subscriberID: SubscriberID) {
    let index = subscribers.index {subscriber -> Bool in
      return subscriber.subscriberID == subscriberID
    }
    
    if let index = index {
      subscribers.remove(at: index)
    }
  }
}
