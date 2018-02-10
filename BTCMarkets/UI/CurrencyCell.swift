//
//  CurrencyCell.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 13/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell, CurrencyFetcher {
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var bidLabel: UILabel!
  @IBOutlet var askLabel: UILabel!
  @IBOutlet var currencyLabel: UILabel!
  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var volumeLabel: UILabel!
  
  private var coin: Coin?
  private var subscriberId: String?
  private var coinsStore: CoinsStore?
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

      self?.updateUI(coin: coin)
    }
    
    self.subscriberId = subscriberId
    self.coinsStore = store
  }
  
  private func updateUI(coin: Coin) {
    updateValue(forLabel: priceLabel, previousValue: self.coin?.lastPrice, newValue: coin.lastPrice, displayValue: coin.displayPrice)
    updateValue(forLabel: bidLabel, previousValue: self.coin?.bestBid, newValue: coin.bestBid, displayValue: coin.displayBestBid)
    updateValue(forLabel: askLabel, previousValue: self.coin?.bestAsk, newValue: coin.bestAsk, displayValue: coin.displayBestAsk)
    volumeLabel.text = coin.displayVolume
    self.coin = coin
  }
  
  private func resetState() {
    priceLabel.text = "-"
    bidLabel.text = "-"
    askLabel.text = "-"
    volumeLabel.text = "-"
    coin = nil
    
    guard let subscriberId = subscriberId else { return }
    coinsStore?.unsubscribe(subscriber: subscriberId)
    coinsStore = nil
    self.subscriberId = nil
  }
  
  deinit {
    resetState()
  }
}

