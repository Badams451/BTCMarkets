//
//  PriceHistoryStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 21/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

final class PriceHistoryStore {
  
  static var sharedInstance: PriceHistoryStore = PriceHistoryStore()
  
  typealias PriceHistoryForTimeWindow = [TimeWindow: Double]
  typealias PriceHistoryForTimePeriod = [TimePeriod: PriceHistoryForTimeWindow]
  typealias PriceHistoryCollection = [Currency: PriceHistoryForTimePeriod]
  typealias SubscriberID = String
  typealias Price = Double
  typealias SubscriberCallback = (Price) -> Void
  typealias Subscriber = (subscriberID: SubscriberID, currency: Currency, timePeriod: TimePeriod, timeWindow: TimeWindow, callback: SubscriberCallback)
  
  private var priceHistoryCollection = PriceHistoryCollection()
  private var subscribers: [Subscriber] = []
  
  func update(price: Double, forInstrument instrument: Currency, forTimeWindow timeWindow: TimeWindow, forTimePeriod timePeriod: TimePeriod) {
    if priceHistoryCollection[instrument] == nil {
      priceHistoryCollection[instrument] = PriceHistoryForTimePeriod()
    }
    
    if priceHistoryCollection[instrument]![timePeriod] == nil {
       priceHistoryCollection[instrument]![timePeriod] = PriceHistoryForTimeWindow()
    }
    
    priceHistoryCollection[instrument]![timePeriod]![timeWindow] = price
    
    for subscriber in subscribers {
      if subscriber.currency == instrument && timePeriod == timePeriod && timeWindow == timeWindow {
        subscriber.callback(price)
      }
    }
  }
  
  func subscribe(subscriber: Subscriber) {
    subscribers.append(subscriber)
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
