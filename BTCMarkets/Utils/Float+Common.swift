//
//  Float+Common.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 17/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation

extension Float {
  var dollarValue: String {
    return String(format: "%.2f", self)
  }
  
  var holdingsValue: String {
    if self.isZero {
      return "0"
    }
    
    return "\(self)"
  }
}
