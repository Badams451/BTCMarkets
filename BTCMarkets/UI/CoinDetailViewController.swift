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
    
    periodSegmentedControl.addTarget(self, action: #selector(periodSegmentControlSelected(segmentControl:)), for: .valueChanged)
    fetchAndDisplayTickerHistory(forTimeWindow: .hour, startingTime:  Date().timeIntervalSince1970 - 24*60*60)
  }
  
  func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
  }
  
  func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
  }
  
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    print((entry as? CandleChartDataEntry)?.low)
    print((entry as? CandleChartDataEntry)?.high)
    print((entry as? CandleChartDataEntry)?.open)
    print((entry as? CandleChartDataEntry)?.close)
  }
  
  @objc func periodSegmentControlSelected(segmentControl: UISegmentedControl) {
    switch segmentControl.selectedSegmentIndex {
    case 0:
      fetchAndDisplayTickerHistory(forTimeWindow: .minute, startingTime: Date().timeIntervalSince1970 - 60*60)
    case 1:
      fetchAndDisplayTickerHistory(forTimeWindow: .hour, startingTime: Date().timeIntervalSince1970 - 24*60*60)
    case 2:
      fetchAndDisplayTickerHistory(forTimeWindow: .hour, startingTime: Date().timeIntervalSince1970 - 24*60*60*7)
    case 3:
      fetchAndDisplayTickerHistory(forTimeWindow: .day, startingTime:  Date().timeIntervalSince1970 - 24 * 60 * 60 * 30)
    default:
      return
    }
  }
  
  private func fetchAndDisplayTickerHistory(forTimeWindow timeWindow: TimeWindow, startingTime: TimeInterval) {
    let api = RestfulAPI()
    let to = Int(Date().timeIntervalSince1970)
    
    api.tickerHistory(from: Int(startingTime), to: to, forTimeWindow: timeWindow, currency: currency.rawValue, instrument: instrument.rawValue).then { response -> Void in
      guard let data = response["ticks"] as? [[Int]] else {
        return
      }
      
      let filteredData = data.drop { array in
        guard let timestamp = array.first else {
          return true
        }
        
        return timestamp / 1000 < Int(startingTime)
      }
      
      let ticks = filteredData.flatMap { tickData -> Tick? in
        guard tickData.count == 6 else {
          return nil
        }
        
        let timestamp = tickData[0].doubleValue / 1000
        let open = tickData[1].doubleValue / 100000000
        let high = tickData[2].doubleValue / 100000000
        let low = tickData[3].doubleValue / 100000000
        let close = tickData[4].doubleValue / 100000000
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        return Tick(timestamp: timestamp, low: low, high: high, open: open, close: close, date: date)
      }
      
      let splitTicks = ticks.chunks(7)
      
      let aggregatedTicks = splitTicks.map { ticks -> Tick in
        let time = ticks.first?.timestamp
        let open = ticks.first?.open
        let close = ticks.last?.close
        let high = ticks.map { $0.high }.max()
        let low = ticks.map { $0.low }.min()
        return Tick(timestamp: time!, low: low!, high: high!, open: open!, close: close!, date: ticks.first!.date!)
      }
      
      DispatchQueue.main.async {
//        var ticks = aggregatedTicks
        let values = (0..<ticks.count).map { (i) -> CandleChartDataEntry in
          let high = ticks[i].high
          let low = ticks[i].low
          let open = ticks[i].open
          let close = ticks[i].close
          
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
        dataSet.neutralColor = dataSet.decreasingColor
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
        self.candleStickChartView.data = CandleChartData(dataSet: dataSet)
        self.candleStickChartView.setVisibleXRangeMinimum(8.0)
      }
    }.catch { error in
      print(error)
    }
  }
}

private extension Array {
  func chunks(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
    }
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
