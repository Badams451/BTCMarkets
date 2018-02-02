//
//  CoinDetailViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 2/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class CoinDetailViewController: UIViewController {
  var currency: Currency!
  var instrument: Currency!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let api = RestfulAPI()
    
    let from = Int(Date().timeIntervalSince1970 - 24*60*60)
    let to = Int(Date().timeIntervalSince1970)
    
    api.tickerHistory(from: from, to: to, forTimeWindow: .minute, currency: currency.rawValue, instrument: instrument.rawValue).then { response -> Void in
      guard let data = response["ticks"] as? [[Int]] else {
        return
      }
      
      let ticks = data.flatMap { tickData -> Tick? in
        guard tickData.count == 6 else {
          return nil
        }
        
        let timestamp = tickData[0].doubleValue
        let open = tickData[1].doubleValue
        let high = tickData[2].doubleValue
        let close = tickData[3].doubleValue
        let low = tickData[4].doubleValue
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        return Tick(low: low, high: high, open: open, close: close, date: date)
      }
      
      print(ticks)
      
    }.catch { error in
      print(error)
    }
  }
}
