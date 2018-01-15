//
//  Currency.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

enum Currency: String, Codable {
  case aud = "AUD"
  case btc = "BTC"
  case ltc = "LTC"
  case xrp = "XRP"
  case eth = "ETH"
  case bch = "BCH"
  
  var coinName: String {
    switch self {
    case .aud: return "AUD"
    case .btc: return "Bitcoin"
    case .ltc: return "Litecoin"
    case .xrp: return "Ripple"
    case .eth: return "Ethereum"
    case .bch: return "BCash"
    }
  }
  
  static var allValues: [Currency] {
    return [.aud, .btc, .ltc, .xrp, .eth, .bch]
  }
  
  static var allExceptAud: [Currency] {
    return [.aud, .btc, .ltc, .xrp, .eth, .bch]
  }
}
