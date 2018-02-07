//
//  CoinDetailViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 2/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Charts

enum TimePeriod: Int {
  case day = 0
  case week = 1
  case month = 2
}

class CoinDetailViewController: UIViewController, ChartViewDelegate {
  
  var currency: Currency!
  var instrument: Currency!
  private let store = TickHistoryStore.sharedInstance
  
  @IBOutlet var candleStickChartView: CandleStickChartView!
  @IBOutlet var periodSegmentedControl: UISegmentedControl!
  
  private var timePeriodForSegmentControl: TimePeriod {
    guard let timePeriod = TimePeriod(rawValue: periodSegmentedControl.selectedSegmentIndex) else {
      return .day
    }
    
    return timePeriod
  }
  
  private var timeWindowForSelectedSegment: TimeWindow {
    switch self.timePeriodForSegmentControl {
    case .day: return .hour
    case .week: return .day
    case .month: return .day
    }
  }
  
  private var startTimeForSelectedSegment: TimeInterval {
    switch self.timePeriodForSegmentControl {
    case .day: return TimeInterval.minusOneDay
    case .week: return TimeInterval.minusOneWeek
    case .month: return TimeInterval.minusOneMonth
    }
  }
  
  private var subscriberId: TickHistoryStore.Subscriber {
    return String(describing: self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    periodSegmentedControl.addTarget(self, action: #selector(onSegmentControlSelected), for: .valueChanged)
    onSegmentControlSelected(segmentControl: periodSegmentedControl)
    store.subscribe(subscriber: subscriberId) { [weak self] _ in
      guard let strongSelf = self else { return }
      let ticks = strongSelf.store.ticks(forTimePeriod: strongSelf.timePeriodForSegmentControl, currency: strongSelf.currency, instrument: strongSelf.instrument)
      strongSelf.drawCandlestickChart(forTicks: ticks)
    }
  }
  
  deinit {
    store.unsubscribe(subscriber: subscriberId)
  }
  
  func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
  }
  
  func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
  }
  
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    print((entry as? CandleChartDataEntry)?.low ?? "")
    print((entry as? CandleChartDataEntry)?.high ?? "")
    print((entry as? CandleChartDataEntry)?.open ?? "")
    print((entry as? CandleChartDataEntry)?.close ?? "")
  }
  
  @objc func onSegmentControlSelected(segmentControl: UISegmentedControl) {
    let timeWindow: TimeWindow = timeWindowForSelectedSegment
    let startingTime: TimeInterval = startTimeForSelectedSegment
    
    store.fetchTickerHistory(forTimeWindow: timeWindow, timePeriod: timePeriodForSegmentControl, startingTime: startingTime, currency: currency, instrument: instrument)
  }
  
  private func drawCandlestickChart(forTicks ticks: [Tick]) {
    let chartData = (0..<ticks.count).map { (i) -> CandleChartDataEntry in
      let high = ticks[i].high
      let low = ticks[i].low
      let open = ticks[i].open
      let close = ticks[i].close
      
      return CandleChartDataEntry(x: Double(i), shadowH: high, shadowL: low, open: open, close: close, icon: nil)
    }
    
    let dataSet = CandleChartDataSet(values: chartData, label: nil)
    
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
