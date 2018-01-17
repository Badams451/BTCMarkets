//
//  Double+Common.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 17/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

extension Double {
  var dollarValue: String {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .currency
    
    return formatter.string(for: self) ?? ""
  }
  
  var holdingsValue: String {
    if self.isZero {
      return "0"
    }
    
    let isWholeNumber = self.truncatingRemainder(dividingBy: 1) == 0
    let value = isWholeNumber ? String(format: "%.0f", self) : "\(self)"
    return value
  }
}
