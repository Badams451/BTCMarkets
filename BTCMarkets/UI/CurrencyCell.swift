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
      guard let coin = coins[instrument] else {
        return
      }

      self?.coin = coin
      self?.updateUI(coin: coin)          
    }
    
    tickHistoryStore.subscribe(subscriber: subscriberId) { [weak self] tickStore in
      let currencyInstrumentPair = "\(currency.rawValue)\(instrument.rawValue)"
      guard var strongSelf = self else { return }
      guard let data = tickStore[currencyInstrumentPair],
        let ticks = data[strongSelf.timePeriod] else {
          return
      }
      
      strongSelf.setOpeningPriceFor(timePeriod: .day, fromTicks: ticks)
    }
    
    tickHistoryStore.fetchTickerHistory(forTimeWindow: .hour, timePeriod: .day, startingTime: .minusOneDay, currency: currency, instrument: instrument)
    
    self.subscriberId = subscriberId
    self.coinsStore = store
  }
  
  private func updateUI(coin: Coin) {
    updateValue(forLabel: priceLabel, previousValue: self.coin?.lastPrice, newValue: coin.lastPrice, displayValue: coin.displayPrice)
    updateValue(forLabel: bidLabel, previousValue: self.coin?.bestBid, newValue: coin.bestBid, displayValue: coin.displayBestBid)
    updateValue(forLabel: askLabel, previousValue: self.coin?.bestAsk, newValue: coin.bestAsk, displayValue: coin.displayBestAsk)
    volumeLabel.text = coin.displayVolume
    priceDifferenceLabel.text = self.formattedPriceDifference
    priceDifferenceLabel.textColor = self.formattedPriceColor
  }
  
  private func resetState() {
    priceLabel.text = "-"
    bidLabel.text = "-"
    askLabel.text = "-"
    volumeLabel.text = "-"
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

