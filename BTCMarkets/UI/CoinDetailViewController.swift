//
//  CoinDetailViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 2/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Charts

class CoinDetailViewController: UIViewController {
  var currency: Currency!
  var instrument: Currency!
  @IBOutlet var candleStickChartView: CandleStickChartView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let api = RestfulAPI()
    
    let from = Int(Date().timeIntervalSince1970 - 24*60*60)
    let to = Int(Date().timeIntervalSince1970)
    
    api.tickerHistory(from: from, to: to, forTimeWindow: .hour, currency: currency.rawValue, instrument: instrument.rawValue).then { response -> Void in
      guard let data = response["ticks"] as? [[Int]] else {
        return
      }
      
      let filteredData = data.drop { array in
        guard let timestamp = array.first else {
          return true
        }
        
        return timestamp / 1000 < from
      }
      
      print(filteredData.count)
      
      let ticks = filteredData.flatMap { tickData -> Tick? in
        guard tickData.count == 6 else {
          return nil
        }
        
        print(from)
        
        let timestamp = tickData[0].doubleValue / 1000
        let open = tickData[1].doubleValue
        let close = tickData[2].doubleValue
        let low = tickData[3].doubleValue
        let high = tickData[4].doubleValue
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "YYYY-MM-dd HH:mm"
        
        print(formatter.string(from: date))
        
        return Tick(low: low, high: high, open: open, close: close, date: date)
      }
      
      DispatchQueue.main.async {
        
        let range: UInt32 = 1000
        let yVals1 = (0..<ticks.count).map { (i) -> CandleChartDataEntry in
          let high = ticks[i].high / 100000000 // Double(arc4random_uniform(9) + 8)
          let low = ticks[i].low / 100000000 // Double(arc4random_uniform(9) + 8)
          let open = ticks[i].open / 100000000 // Double(arc4random_uniform(6) + 1)
          let close = ticks[i].close / 100000000 // Double(arc4random_uniform(6) + 1)
          
          return CandleChartDataEntry(x: Double(i), shadowH: high, shadowL: low, open: open, close: close, icon: nil)
        }
        
        let set1 = CandleChartDataSet(values: yVals1, label: "Data Set")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = .red
        set1.decreasingFilled = true
        set1.increasingColor = UIColor(red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        set1.increasingFilled = false
        set1.neutralColor = .blue
        
        self.candleStickChartView.data = CandleChartData(dataSet: set1)
      }
    }.catch { error in
      print(error)
    }
  }
}
