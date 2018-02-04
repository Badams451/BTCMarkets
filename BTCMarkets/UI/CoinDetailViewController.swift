//
//  CoinDetailViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 2/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Charts

class CoinDetailViewController: UIViewController, ChartViewDelegate {
  var currency: Currency!
  var instrument: Currency!
  @IBOutlet var candleStickChartView: CandleStickChartView!
  @IBOutlet var periodSegmentedControl: UISegmentedControl!
  
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
      
      let ticks = filteredData.flatMap { tickData -> Tick? in
        guard tickData.count == 6 else {
          return nil
        }
        
        let timestamp = tickData[0].doubleValue / 1000
        let open = tickData[1].doubleValue
        let high = tickData[2].doubleValue
        let low = tickData[3].doubleValue
        let close = tickData[4].doubleValue
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        return Tick(timestamp: timestamp, low: low, high: high, open: open, close: close, date: date)
      }
      
      DispatchQueue.main.async {
        let values = (0..<ticks.count).map { (i) -> CandleChartDataEntry in
          let high = ticks[i].high / 100000000 // Double(arc4random_uniform(9) + 8)
          let low = ticks[i].low / 100000000 // Double(arc4random_uniform(9) + 8)
          let open = ticks[i].open / 100000000 // Double(arc4random_uniform(6) + 1)
          let close = ticks[i].close / 100000000 // Double(arc4random_uniform(6) + 1)
          
          return CandleChartDataEntry(x: Double(i), shadowH: high, shadowL: low, open: open, close: close, icon: nil)
        }
        
        let dataSet = CandleChartDataSet(values: values, label: nil)
        
        dataSet.axisDependency = .right
        dataSet.setColor(UIColor(white: 80/255, alpha: 1))
        dataSet.drawIconsEnabled = false
        dataSet.shadowWidth = 3.0
        dataSet.shadowColorSameAsCandle = true
        dataSet.decreasingColor = UIColor(red: 135/255, green: 15/255, blue: 35/255, alpha: 1)
        dataSet.decreasingFilled = true
        dataSet.increasingColor = UIColor(red: 72/255, green: 121/255, blue: 31/255, alpha: 1)
        dataSet.increasingFilled = true
        dataSet.neutralColor = .blue
        dataSet.drawValuesEnabled = false
        
        self.candleStickChartView.doubleTapToZoomEnabled = false
        self.candleStickChartView.chartDescription = nil
        self.candleStickChartView.xAxis.labelPosition = .bottom
        self.candleStickChartView.xAxis.valueFormatter = DateValueFormatter(dates: ticks.flatMap { $0.date })
        self.candleStickChartView.scaleYEnabled = false
        self.candleStickChartView.rightAxis.enabled = false
        self.candleStickChartView.leftAxis.valueFormatter = AUDValueFormatter()
        self.candleStickChartView.delegate = self
        self.candleStickChartView.legend.enabled = false
        
        self.candleStickChartView.zoom(scaleX: 3.0, scaleY: 1.0, x: 0, y: 0)
        self.candleStickChartView.data = CandleChartData(dataSet: dataSet)
        self.candleStickChartView.setVisibleXRangeMinimum(8.0)
        self.candleStickChartView.moveViewToX(24.0)
      }
    }.catch { error in
      print(error)
    }
  }
  
  func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
  }
  
  func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
  }
}

class AUDValueFormatter: IAxisValueFormatter {
  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    return value.dollarValue
  }
}

class DateValueFormatter : IAxisValueFormatter {
  private let dates: [Date]
  
  init(dates: [Date]) {
    self.dates = dates
  }
  
  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    let index = Int((value / 24) * 24)

    guard index >= 0 && index < dates.count else {
      return ""
    }
    
    let date = dates[index]
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM"
    
    return "\(timeFormatter.string(from: date))\n\(dateFormatter.string(from: date))"
  }
}
