//
//  CurrenciesStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import PromiseKit
import SocketIO

class CurrencyValuesStore: CurrencyFetcher {
  static var sharedInstance: CurrencyValuesStore = CurrencyValuesStore()
  
  typealias CurrencyValues = [Currency: Float]
  typealias Subscriber = String
  typealias CurrencyValuesChanged = (CurrencyValues) -> Void
  
  private var subscribers: [(Subscriber, CurrencyValuesChanged)] = []
  private lazy var currencyValues: CurrencyValues = {
    var currencies = CurrencyValues()
    Currency.allValues.forEach { currencies[$0] = 0.0 }
    currencies[.aud] = 1
    return currencies
  }()
  
  var socketManager: SocketManager = SocketManager(socketURL: URL(string: "https://socket.btcmarkets.net")!,  config: [.compress, .secure(true), .forceWebsockets(true)])
  lazy var socket: SocketIOClient? = {
    return socketManager.defaultSocket
  }()
  
  init() {}
  
  func start() {
    let promises = Currency.allExceptAud.map { fetchCurrency(currency: .aud, instrument: $0) }
    
    promises.forEach { promise in
      promise.then { coin -> Void in
        guard let coin = coin, let currency = Currency(rawValue: coin.instrument) else {
          return
        }
        
        self.currencyValues[currency] = coin.lastPrice
        self.setupSocket(currency: .aud)
      }.catch { error in print(error) }
    }
  }
  
  private func setupSocket(currency: Currency) {
    let instruments = Currency.allExceptAud
    
    socket?.on(clientEvent: .connect) { [weak self] data, ack in
      instruments.forEach { instrument in
        let channelName = "Ticker-BTCMarkets-\(instrument.rawValue)-\(currency.rawValue)"
        self?.socket?.emit("join", with: [channelName])
      }
    }
    
    socket?.on("newTicker") { [weak self] data, ack in
      guard let strongSelf = self,
            let json = data.first as? JSONResponse,
            var coin = Coin(JSON: json),
            let currency = Currency(rawValue: coin.instrument) else {
        return
      }
      
      coin.normaliseValues()
      strongSelf.currencyValues[currency] = coin.lastPrice
      strongSelf.subscribers.forEach { $0.1(strongSelf.currencyValues) }      
    }
    
    socket?.connect()
  }
  
  func subscribe(subscriber: Subscriber, callback: @escaping CurrencyValuesChanged) {
    subscribers.append((subscriber, callback))
    callback(currencyValues)
  }
  
  func unsubscribe(subscriber: Subscriber) {
    if let subscriberIndex = (subscribers.index { return $0.0 == subscriber }) {
      subscribers.remove(at: subscriberIndex)
    }
  }
  
  func value(forCurrency currency: Currency) -> Float {
    return currencyValues[currency] ?? 0
  }
}
