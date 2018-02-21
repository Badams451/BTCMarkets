//
//  CurrencyCell.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 13/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell, CurrencyFetcher, PriceDifferenceCalculator {
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var bidLabel: UILabel!
  @IBOutlet var askLabel: UILabel!
  @IBOutlet var currencyLabel: UILabel!
  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var volumeLabel: UILabel!
  @IBOutlet var priceDifferenceLabel: UILabel!
  
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
    updateValue(forLabel: bidLabel, previousValue: previousCoin?.bestBid, newValue: updatedCoin.bestBid, displayValue: updatedCoin.displayBestBid)
    updateValue(forLabel: askLabel, previousValue: previousCoin?.bestAsk, newValue: updatedCoin.bestAsk, displayValue: updatedCoin.displayBestAsk)
    volumeLabel.text = updatedCoin.displayVolume
    priceDifferenceLabel.text = self.formattedPriceDifference
    priceDifferenceLabel.textColor = self.formattedPriceColor
  }
  
  private func resetState() {
    priceLabel.text = "-"
    bidLabel.text = "-"
    askLabel.text = "-"
    volumeLabel.text = "-"
    priceDifferenceLabel.text = "-"
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

