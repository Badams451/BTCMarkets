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

final class CoinsStoreAud: CoinsStore {
  static var sharedInstance: CoinsStoreAud = CoinsStoreAud()

  override var currency: Currency! {
    return .aud
  }
}

final class CoinsStoreBtc: CoinsStore {
  static var sharedInstance: CoinsStoreBtc = CoinsStoreBtc()
  
  override var currency: Currency! {
    return .btc
  }
}

class CoinsStore: CurrencyFetcher {
  typealias CoinCollection = [Currency: Coin]
  typealias Subscriber = String
  typealias CoinCollectionChanged = (CoinCollection) -> Void
  
  enum SubscriptionType {
    case all
    case onlyPrice
  }
  
  private var subscribers: [(subscriber: Subscriber, currency: Currency, type: SubscriptionType, onCoinCollectionChanged: CoinCollectionChanged)] = []
  private var coins: CoinCollection = CoinCollection()  
  
  // Abstract implementation. Must override.
  var currency: Currency! {
    return nil
  }

  private var socketManager: SocketManager = SocketManager(socketURL: URL(string: "https://socket.btcmarkets.net")!,  config: [.compress, .secure(true), .forceWebsockets(true)])
  private var socket: SocketIOClient?
  
  init() {
    self.socket = socketManager.defaultSocket
  }
  
  func coin(forCurrency currency: Currency) -> Coin? {
    return coins[currency]
  }
  
  func start() {
    let promises = Currency.allExceptAud.map { fetchCurrency(currency: currency, instrument: $0) }
    
    promises.forEach { promise in
      promise.then { coin -> Void in
        guard let coin = coin, let currency = Currency(rawValue: coin.instrument) else {
          return
        }
        
        self.coins[currency] = coin
        self.setupSocket(currency: self.currency)
        self.notifySubscribers()
      }.catch { error in print(error) }
    }
  }

  private func setupSocket(currency: Currency) {
    let instruments = [Currency.btc]
    
    socket?.on(clientEvent: .connect) { [weak self] data, ack in
      instruments.forEach { instrument in
        let channelName = "Ticker-BTCMarkets-\(instrument.rawValue)-\(currency.rawValue)"
        self?.socket?.emit("join", with: [channelName])
      }
    }
    
    socket?.on("newTicker") { [weak self] data, ack in
      DispatchQueue.global().async {
        guard
          let strongSelf = self,
          let json = data.first as? JSONResponse,
          var coin = Coin(JSON: json),
          let currency = Currency(rawValue: coin.instrument)
        else {
          return
        }
        
        coin.normaliseValues()
        
        let subscribers = (strongSelf.subscribers.filter { $0.currency == currency })
        let previousCoin = strongSelf.coins[currency]
        let priceUpdated = (previousCoin == nil) ? previousCoin!.lastPrice != coin.lastPrice : true
        let coinUpdated = (previousCoin == nil) ? previousCoin! != coin : true
        
        DispatchQueue.main.async {
          if coinUpdated {
            strongSelf.coins[currency] = coin
          }
          
          for subscriber in subscribers {
            let subscriptionType = subscriber.type
            switch subscriptionType {
            case .all:
              if coinUpdated {
                subscriber.onCoinCollectionChanged(strongSelf.coins)
              }
            case .onlyPrice:
              if priceUpdated {
                subscriber.onCoinCollectionChanged(strongSelf.coins)
              }
            }
          }
        }
      }
    }
    
    socket?.connect()
  }
  
  func subscribe(subscriber: Subscriber, currency: Currency, type: SubscriptionType, callback: @escaping CoinCollectionChanged) {
    subscribers.append((subscriber, currency, type, callback))
    callback(coins)
  }

  func unsubscribe(subscriber: Subscriber) {
    if let subscriberIndex = (subscribers.index { return $0.0 == subscriber }) {
      subscribers.remove(at: subscriberIndex)
    }
  }
  
  private func notifySubscribers() {
    subscribers.forEach { $0.onCoinCollectionChanged(coins) }
  }
}

