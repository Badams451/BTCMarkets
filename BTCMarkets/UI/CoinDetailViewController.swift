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
  private let tickHistoryStore = TickHistoryStore.sharedInstance
  private let coinStore = CoinsStoreAud.sharedInstance
  private var currentDatesOnXAxis: [Date] = []
  private var coin: Coin?
  
  @IBOutlet var candleStickChartView: CandleStickChartView!
  @IBOutlet var periodSegmentedControl: UISegmentedControl!
  @IBOutlet var currentPriceLabel: UILabel!
  
  @IBOutlet var openLabel: UILabel!
  @IBOutlet var closeLabel: UILabel!
  @IBOutlet var lowLabel: UILabel!
  @IBOutlet var highLabel: UILabel!
  @IBOutlet var timelabel: UILabel!
  
  private var dateFormatterForXAxis: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM HH:mm"
    return formatter
  }
  
  private var timePeriodForSegmentControl: TimePeriod {
    guard let timePeriod = TimePeriod(rawValue: periodSegmentedControl.selectedSegmentIndex) else {
      return .day
    }
    
    return timePeriod
  }
  
  private var timeWindowForSelectedSegment: TimeWindow {
    switch self.timePeriodForSegmentControl {
    case .day: return .hour
    case .week: return .hour
    case .month: return .hour
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
    tickHistoryStore.subscribe(subscriber: subscriberId) { [weak self] _ in
      guard let strongSelf = self else { return }
      let ticks = strongSelf.tickHistoryStore.ticks(forTimePeriod: strongSelf.timePeriodForSegmentControl, currency: strongSelf.currency, instrument: strongSelf.instrument)
      strongSelf.drawCandlestickChart(forTicks: ticks)
      strongSelf.currentDatesOnXAxis = ticks.flatMap { $0.date }
    }
    
    coinStore.subscribe(subscriber: subscriberId) { [weak self] coinCollection in
      guard let strongSelf = self else { return }
      guard let updatedCoin = coinCollection[strongSelf.instrument] else { return }
      strongSelf.updateValue(forLabel: strongSelf.currentPriceLabel, previousValue: strongSelf.coin?.lastPrice, newValue: updatedCoin.lastPrice, displayValue: "Current: \(updatedCoin.displayPrice)")
      strongSelf.coin = updatedCoin
    }
  }
  
  deinit {
    tickHistoryStore.unsubscribe(subscriber: subscriberId)
    coinStore.unsubscribe(subscriber: subscriberId)
  }
  
  func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
  }
  
  func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
  }
  
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    guard let entry = entry as? CandleChartDataEntry else { return }
    
    let date = currentDatesOnXAxis[entry.x.intValue]
    let dateString = dateFormatterForXAxis.string(from: date)
    openLabel.text = "Open: \(entry.open.dollarValue)"
    closeLabel.text = "Close: \(entry.close.dollarValue)"
    lowLabel.text = "Low: \(entry.low.dollarValue)"
    highLabel.text = "High: \(entry.high.dollarValue)"
    timelabel.text = "At: \(dateString)"
    timelabel.isHidden = false
  }
  
  @objc func onSegmentControlSelected(segmentControl: UISegmentedControl) {
    let timeWindow: TimeWindow = timeWindowForSelectedSegment
    let startingTime: TimeInterval = startTimeForSelectedSegment
    
    tickHistoryStore.fetchTickerHistory(forTimeWindow: timeWindow, timePeriod: timePeriodForSegmentControl, startingTime: startingTime, currency: currency, instrument: instrument)
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
    dataSet.decreasingColor = UIColor.darkRed
    dataSet.increasingColor = UIColor.darkGreen
    dataSet.decreasingFilled = true
    dataSet.increasingFilled = true
    dataSet.shadowColorSameAsCandle = true
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
