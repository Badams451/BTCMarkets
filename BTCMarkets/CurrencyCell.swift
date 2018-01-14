//
//  CurrencyCell.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 13/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import PromiseKit
import SocketIO

protocol CurrencyFetcher {
  func fetchCurrency(currency: Currency, instrument: Currency) -> Promise<Coin?>
}

extension CurrencyFetcher {
  func fetchCurrency(currency: Currency, instrument: Currency) -> Promise<Coin?> {
    let api = RestfulAPI()
    return api.tick(currency: currency.rawValue, instrument: instrument.rawValue).then { json in
      Coin(JSON: json)
    }
  }
}

class CurrencyCell: UITableViewCell, CurrencyFetcher {
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var bidLabel: UILabel!
  @IBOutlet var askLabel: UILabel!
  @IBOutlet var currencyLabel: UILabel!
  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var volumeLabel: UILabel!
  
  private var coin: Coin?
  
  let socketManager: SocketManager = SocketManager(socketURL: URL(string: "https://socket.btcmarkets.net")!,  config: [.compress, .secure(true), .forceWebsockets(true)])
  lazy var socket: SocketIOClient? = {
    return socketManager.defaultSocket
  }()

  override func prepareForReuse() {
    super.prepareForReuse()
  }

  func configure(currency: Currency, instrument: Currency) {
    currencyLabel.text = "\(instrument.rawValue)/\(currency.rawValue)"
    coinNameLabel.text = instrument.coinName
    
    self.fetchCurrency(currency: currency, instrument: instrument).then { coin -> Void in
      guard let coin = coin else {
        return
      }

      DispatchQueue.main.async {
        self.updateUI(coin: coin)
      }
      
      self.setupSocket(currency: currency, instrument: instrument)
    }.catch { error in print(error) }
  }
  
  private func updateUI(coin: Coin) {
    updateValue(forLabel: priceLabel, previousValue: self.coin?.lastPrice, newValue: coin.lastPrice, displayValue: coin.displayPrice)
    updateValue(forLabel: bidLabel, previousValue: self.coin?.bestBid, newValue: coin.bestBid, displayValue: coin.displayBestBid)
    updateValue(forLabel: askLabel, previousValue: self.coin?.bestAsk, newValue: coin.bestAsk, displayValue: coin.displayBestAsk)
    volumeLabel.text = coin.displayVolume
    self.coin = coin
  }
  
  private func updateValue(forLabel label: UILabel, previousValue: Float?, newValue: Float?, displayValue: String) {
    guard let previousValue = previousValue, let newValue = newValue else {
      label.text = displayValue
      return
    }
    
    guard previousValue != newValue else { return }
    
    let color: UIColor = previousValue < newValue ? .green : .red
    
    label.text = displayValue
    label.textColor = color

    Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
      UIView.transition(with: label, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
        label.textColor = .black
      }, completion: nil)
    }
  }
  
  private func setupSocket(currency: Currency, instrument: Currency) {
    socket?.on(clientEvent: .connect) { [weak self] data, ack in
      let channelName = "Ticker-BTCMarkets-\(instrument.rawValue)-\(currency.rawValue)"
      self?.socket?.emit("join", with: [channelName])
    }
    
    socket?.on("newTicker") { [weak self] data, ack in
      guard let json = data.first as? JSONResponse, var coin = Coin(JSON: json) else {
        return
      }
      coin.normaliseValues()
      
      self?.updateUI(coin: coin)
    }
    
    socket?.connect()
  }
}

