//
//  CurrencyCell.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 13/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Charts

class CurrencyCell: UITableViewCell, CurrencyFetcher, PriceDifferenceCalculator, ChartViewDelegate {
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var currencyLabel: UILabel!
  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var priceDifferenceLabel: UILabel!
  @IBOutlet var lineChartView: LineChartView!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  var coin: Coin?
  var openingPrice: Double?
  var timePeriod: TimePeriod {
    return .day
  }
  
  private var subscriberId: String?
  private var coinsStore: CoinsStore?
  private var tickHistoryStore = TickHistoryStore.sharedInstance
  private var currencyForStore: [Currency: CoinsStore] {
    return [
      .aud: CoinsStoreAud.sharedInstance,
      .btc: CoinsStoreBtc.sharedInstance
    ]
  }
  private var priceHistoryStore = PriceHistoryStore.sharedInstance

  override func prepareForReuse() {
    resetState()
    super.prepareForReuse()
  }

  func configure(currency: Currency, instrument: Currency) {
    currencyLabel.text = "\(instrument.rawValue)/\(currency.rawValue)"
    coinNameLabel.text = instrument.coinName
    
    let store = currencyForStore[currency]
    let subscriberId = "\(instrument.rawValue)-\(currency.rawValue)"
    
    store?.subscribe(subscriber: subscriberId, currency: instrument, type: .onlyPrice) { [weak self] coins in
      guard let updatedCoin = coins[instrument] else {
        return
      }
      
      let previousCoin = self?.coin
      self?.coin = updatedCoin
      self?.updateUI(previousCoin: previousCoin, updatedCoin: updatedCoin)
      self?.tickHistoryStore.fetchTickerHistory(forTimeWindow: .minute, timePeriod: .day, startingTime: .minusOneDay, currency: currency, instrument: instrument)
    }
    
    tickHistoryStore.subscribe(subscriber: subscriberId) { [weak self] tickStore in
      DispatchQueue.main.async {
        let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
        guard var strongSelf = self else { return }
        guard let data = tickStore[currencyInstrumentPair] else {
          return
        }
        
        guard
          let ticksForChart = data[strongSelf.timePeriod]?[TimeWindow.hour],
          let ticksForPrice = data[strongSelf.timePeriod]?[TimeWindow.minute]
        else {
          return
        }      
        
        let priceHistoryStore = strongSelf.priceHistoryStore
        if priceHistoryStore.pastDayPriceHistory[instrument] == nil || priceHistoryStore.priceIsOutdated {
          strongSelf.setOpeningPriceFor(timePeriod: strongSelf.timePeriod, fromTicks: ticksForPrice)
          strongSelf.priceHistoryStore.update(price: strongSelf.openingPrice ?? 0, forCurrency: instrument)
        }

        strongSelf.updatePriceDifferenceLabel()
        strongSelf.activityIndicator.stopAnimating()
        strongSelf.lineChartView.isHidden = false
        strongSelf.drawLineChart(forTicks: ticksForChart)
      }
    }
    
    if let price = priceHistoryStore.pastDayPriceHistory[instrument] {
      self.openingPrice = price
    }
    
    tickHistoryStore.fetchTickerHistory(forTimeWindow: .hour, timePeriod: .day, startingTime: .minusOneDay, currency: currency, instrument: instrument)
    tickHistoryStore.fetchTickerHistory(forTimeWindow: .minute, timePeriod: .day, startingTime: .minusOneDay, currency: currency, instrument: instrument)
    
    self.subscriberId = subscriberId
    self.coinsStore = store
  }
  
  private func updateUI(previousCoin: Coin?, updatedCoin: Coin) {
    updateValue(forLabel: priceLabel, previousValue: previousCoin?.lastPrice, newValue: updatedCoin.lastPrice, displayValue: updatedCoin.displayPrice)
    updatePriceDifferenceLabel()
  }
  
  private func updatePriceDifferenceLabel() {
    priceDifferenceLabel.text = self.formattedPriceDifference
    priceDifferenceLabel.textColor = self.formattedPriceColor
  }

  private func drawLineChart(forTicks ticks:[Tick]) {
    let chartData = ticks.enumerated().map { (index, tick) -> ChartDataEntry in
      return ChartDataEntry(x: Double(index), y: tick.close)
    }
    
    let dataSet = LineChartDataSet(values: chartData, label: nil)
    
    dataSet.axisDependency = .left
    dataSet.lineWidth = 1.5
    dataSet.drawCirclesEnabled = false
    dataSet.drawValuesEnabled = false
    dataSet.fillAlpha = 0.26
    dataSet.highlightEnabled = false
    dataSet.drawCircleHoleEnabled = false
    dataSet.fillColor = self.formattedPriceColor
    dataSet.setColor(self.formattedPriceColor)
    dataSet.drawFilledEnabled = true
    
    let data = LineChartData(dataSet: dataSet)
    data.setValueTextColor(.white)
    data.setValueFont(.systemFont(ofSize: 9, weight: .light))
    
    self.lineChartView.data = data
    self.lineChartView.legend.enabled = false
    self.lineChartView.xAxis.enabled = false
    self.lineChartView.leftAxis.enabled = false
    self.lineChartView.rightAxis.enabled = false
    self.lineChartView.chartDescription?.enabled = false
    self.lineChartView.isUserInteractionEnabled = false
  }
  
  private func resetState() {
    priceLabel.text = "-"
    priceDifferenceLabel.text = "-"
    openingPrice = nil
    coin = nil
    
    guard let subscriberId = subscriberId else { return }
    tickHistoryStore.unsubscribe(subscriber: subscriberId)
    coinsStore?.unsubscribe(subscriber: subscriberId)
    coinsStore = nil
    self.subscriberId = nil
  }
  
  
  deinit {
    resetState()
  }
}

