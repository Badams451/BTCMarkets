//
//  CurrencyFetcher.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 28/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import PromiseKit

protocol CurrencyFetcher {
  func fetchCurrency(currency: Currency, instrument: Currency) -> Promise<Coin?>
}

extension CurrencyFetcher {
  func fetchCurrency(currency: Currency, instrument: Currency) -> Promise<Coin?> {
    let api = RestfulAPI()
    return api.tick(currency: currency.rawValue, instrument: instrument.rawValue).then { json in
      Coin(JSON: json)
    }
  }
}
