//
//  CryptoStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 3/17/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import RxSwift

struct CryptoUpdateNotifier {

  let currency: Currency

  let price: BehaviorSubject<Double>

}

final class CryptoStore {
  
  static let shared: CryptoStore = CryptoStore()

  private let dataStream: CryptoDataStream

  private var cryptoUpdateNotifiers = [Currency: CryptoUpdateNotifier]()

  init(dataStream: CryptoDataStream = CryptoDataStreamer()) {
    self.dataStream = dataStream
    self.dataStream.startStreaming()
    self.dataStream.setOnCryptoUpdated(callback: onCryptoUpdate)

    Currency.allExceptAud.forEach { currency in
      let priceSubject = BehaviorSubject<Double>(value: 0)
      let notifier = CryptoUpdateNotifier(currency: currency, price: priceSubject)
      self.cryptoUpdateNotifiers[currency] = notifier
    }
  }

  deinit {
    self.dataStream.stopStreaming()
  }

  private func onCryptoUpdate(currency: Currency, coin: Coin) {
    let notifier = cryptoUpdateNotifiers[currency]!
    let previousPrice = try! notifier.price.value()
    let newPrice = coin.lastPrice

    if previousPrice != newPrice {
      notifier.price.onNext(newPrice)
    }
  }

  func notifier(forCurrency currency: Currency) -> CryptoUpdateNotifier {
    return cryptoUpdateNotifiers[currency]!
  }


}

