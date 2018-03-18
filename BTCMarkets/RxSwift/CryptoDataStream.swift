//
//  CryptoDataStream.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 18/3/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

protocol CryptoDataStream {
  
  typealias OnCryptoUpdated = (Currency, Coin) -> Void
  
  func startStreaming()
  
  func stopStreaming()
  
  func setOnCryptoUpdated(callback: @escaping OnCryptoUpdated)
  
}

final class CryptoDataStreamer: CryptoDataStream {
  private var callback: OnCryptoUpdated?
  
  func startStreaming() {
    
  }
  
  func stopStreaming() {
    
  }
  
  func setOnCryptoUpdated(callback: @escaping OnCryptoUpdated) {
    
  }
}
