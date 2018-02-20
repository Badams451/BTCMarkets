//
//  Common.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

protocol PriceDifferenceCalculator {
  var openingPrice: Double? { get set }
  var coin: Coin? { get set }
  var timePeriod: TimePeriod { get }
  
  var priceDifference: Double { get }
  var percentageDifference: Double { get }
  var formattedPriceDifference: String { get }
  var formattedPriceColor: UIColor { get }
  mutating func setOpeningPriceFor(timePeriod: TimePeriod, fromTicks ticks: [Tick])
}

extension PriceDifferenceCalculator {
  var priceDifference: Double {
    guard let coin = coin, let openingPrice = openingPrice else {
      return 0
    }
    
    return coin.lastPrice - openingPrice
  }
  
  var percentageDifference: Double {
    guard let coin = coin else {
      return 0
    }
    return (priceDifference / coin.lastPrice) * 100
  }
  
  var formattedPriceDifference: String {    
    let percentChangedString = percentageDifference.stringValue(forDecimalPlaces: 2)
    return "\(priceDifference.dollarValue) (\(percentChangedString)%) \(timePeriod.priceChangeDescription)"
  }
  
  var formattedPriceColor: UIColor {
    return percentageDifference >= 0 ? UIColor.darkGreen : UIColor.darkRed
  }
  
  mutating func setOpeningPriceFor(timePeriod: TimePeriod, fromTicks ticks: [Tick]) {
    let date = Calendar.current.startOfDay(for: Date())
    let timestamp = date.timeIntervalSince1970
    
    switch timePeriod {
    case .day:
      if let tick = (ticks.first { $0.timestamp > timestamp }) {
        self.openingPrice = tick.open
      }
    default:
      if let tick = ticks.first {
        self.openingPrice = tick.open
      }
    }
  }
}
