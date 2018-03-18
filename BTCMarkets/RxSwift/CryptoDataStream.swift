//
//  CryptoDataStream.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 18/3/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import SocketIO

protocol CryptoDataStream {
  
  typealias OnCryptoUpdated = (Currency, Coin) -> Void
  
  func startStreaming()
  
  func stopStreaming()
  
  func setOnCryptoUpdated(callback: @escaping OnCryptoUpdated)
  
}

final class CryptoDataStreamer: CryptoDataStream, CurrencyFetcher {
  private var onCryptoUpdate: OnCryptoUpdated?
  private var socketManager: SocketManager = SocketManager(socketURL: URL(string: "https://socket.btcmarkets.net")!,  config: [.compress, .secure(true), .forceWebsockets(true)])
  private var socket: SocketIOClient?
  
  init() {
    self.socket = socketManager.defaultSocket
  }
  
  func startStreaming() {
    let promises = Currency.allExceptAud.map { fetchCurrency(currency: .aud, instrument: $0) }
    
    promises.forEach { promise in
      promise.then { coin -> Void in
        guard let coin = coin, let currency = Currency(rawValue: coin.instrument) else {
          return
        }
       
        self.onCryptoUpdate?(currency, coin)
      }.catch { error in print(error) }
    }
  }
  
  private func setupSocket() {
    let instruments = Currency.allExceptAud
    
    socket?.on(clientEvent: .connect) { [weak self] data, ack in
      instruments.forEach { instrument in
        let channelName = "Ticker-BTCMarkets-\(instrument.rawValue)-\(Currency.aud.rawValue)"
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
        strongSelf.onCryptoUpdate?(currency, coin)
      }
    }
    
    socket?.connect()
  }
  
  func stopStreaming() {
    socket?.disconnect()
  }
  
  func setOnCryptoUpdated(callback: @escaping OnCryptoUpdated) {
    self.onCryptoUpdate = callback
  }
}
