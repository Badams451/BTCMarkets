//
//  Ticker.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 31/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import ObjectMapper

enum TimeWindow: String {
  case hour = "hour"
  case day = "day"
  case minute = "minute"
}

struct Tick {
  var timestamp: Double = 0
  var low: Double = 0
  var high: Double = 0
  var open: Double = 0
  var close: Double = 0
  var date: Date?
}
