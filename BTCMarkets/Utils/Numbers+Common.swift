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
  
  var btcValue: String {
    if self.isZero {
      return "0 BTC"
    }
    
    return "\(self) BTC"
  }
  
  var holdingsValue: String {
    if self.isZero {
      return "0"
    }
    
    let isWholeNumber = self.truncatingRemainder(dividingBy: 1) == 0
    let value = isWholeNumber ? String(format: "%.0f", self) : "\(self)"
    return value
  }
  
  var intValue: Int {
    return Int(self)
  }
  
  func stringValue(forDecimalPlaces decimalPlaces: Int) -> String {
    return String(format: "%.\(decimalPlaces)f", arguments: [self])
  }
}

extension Date {
  func oneYearLater() -> Date {
    var offsetComponents = DateComponents()
    offsetComponents.year = 1

    let calendar = Calendar.current
    if let result = calendar.date(byAdding: offsetComponents, to: self) {
      return result
    } else {
      // This should never happen, but we'll try to handle it gracefully
      let secondsPerYear: TimeInterval = 60 * 60 * 24 * 365
      return Date().addingTimeInterval(secondsPerYear)
    }
  }
}

extension TimeInterval {
  static var now:  TimeInterval {
    return Date().timeIntervalSince1970
  }
  
  static var minusOneDay: TimeInterval {
    return now - (24 * 60 * 60).doubleValue
  }
  
  static var minusOneWeek: TimeInterval {
    return now - (7 * 24 * 60 * 60).doubleValue
  }
  
  static var minusOneMonth: TimeInterval {
    return now - (30 * 24 * 60 * 60).doubleValue
  }
}

extension Int {
  var doubleValue: Double {
    return Double(self)
  }
  
  var minutes: TimeInterval {
    return self.doubleValue * 60.doubleValue
  }
}
