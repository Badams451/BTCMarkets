//
//  CurrencyCell.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 13/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Charts

class CurrencyCell: UITableViewCell, CurrencyFetcher, PriceDifferenceCalculator {
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var currencyLabel: UILabel!
  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var priceDifferenceLabel: UILabel!
  @IBOutlet var lineChartView: LineChartView!
  
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
    
    store?.subscribe(subscriber: subscriberId) { [weak self] coins in
      guard let updatedCoin = coins[instrument] else {
        return
      }
      
      let previousCoin = self?.coin
      self?.coin = updatedCoin
      self?.updateUI(previousCoin: previousCoin, updatedCoin: updatedCoin)
    }
    
    tickHistoryStore.subscribe(subscriber: subscriberId) { [weak self] tickStore in
      let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
      guard var strongSelf = self else { return }
      guard let data = tickStore[currencyInstrumentPair],
        let ticks = data[strongSelf.timePeriod] else {
          return
      }

      strongSelf.setOpeningPriceFor(timePeriod: strongSelf.timePeriod, fromTicks: ticks)
      strongSelf.drawLineChart(forTicks: ticks)
      strongSelf.updatePriceDifferenceLabel()
      
      if let price = strongSelf.openingPrice {
        strongSelf.priceHistoryStore.update(price: price, forCurrency: currency)
      }
    }
    
    if let price = priceHistoryStore.pastDayPriceHistory[currency] {
      self.openingPrice = price
    }
    
    tickHistoryStore.fetchTickerHistory(forTimeWindow: .hour, timePeriod: .day, startingTime: .minusOneDay, currency: currency, instrument: instrument)
    
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
    dataSet.fillColor = .darkRed
    dataSet.drawFilledEnabled = true
    dataSet.setColor(.darkRed)
    
    let data = LineChartData(dataSet: dataSet)
    data.setValueTextColor(.white)
    data.setValueFont(.systemFont(ofSize: 9, weight: .light))
    
    self.lineChartView.data = data
    self.lineChartView.legend.enabled = false
    self.lineChartView.xAxis.enabled = false
    self.lineChartView.leftAxis.enabled = false
    self.lineChartView.rightAxis.enabled = false
    self.lineChartView.chartDescription?.enabled = false
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

