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

private let rootCurrency = "AUD"

protocol CurrencyFetcher {
  func fetchCurrency(currency: String, instrument: String) -> Promise<Currency?>
}

extension CurrencyFetcher {
  func fetchCurrency(currency: String, instrument: String) -> Promise<Currency?> {
    let api = RestfulAPI()
    return api.tick(currency: rootCurrency, instrument: instrument).then { json in
      Currency(JSON: json)
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
  
  let socketManager: SocketManager = SocketManager(socketURL: URL(string: "https://socket.btcmarkets.net")!,  config: [.compress, .secure(true), .connectParams(["transports":["websocket"]])])
  lazy var socket: SocketIOClient? = {
    return socketManager.defaultSocket
  }()

  override func prepareForReuse() {
    super.prepareForReuse()
  }

  func configure(currency: String, instrument: String, coinName: String) {
    currencyLabel.text = "\(instrument)/\(currency)"
    coinNameLabel.text = coinName
    
    self.fetchCurrency(currency: currency, instrument: instrument).then { coin -> Void in
      guard let coin = coin else {
        return
      }

      DispatchQueue.main.async {
        self.priceLabel.text = "$\(coin.displayPrice)"
        self.volumeLabel.text = "Volume(24h): \(coin.displayVolume)"
        self.bidLabel.text = "Bid: \(coin.displayBestBid)"
        self.askLabel.text = "Ask: \(coin.displayBestAsk)"
      }
      
      self.setupSocket(currency: currency, instrument: instrument)
    }.catch { error in print(error) }
  }
  
  private func setupSocket(currency: String, instrument: String) {
    socket?.on(clientEvent: .connect) { [weak self] data, ack in
      let channelName = "Ticker-BTCMarkets-\(instrument)-\(currency)"
      self?.socket?.emit("join", with: [channelName])
    }
    
    socket?.on("newTicker") { data, ack in
      print(data)
      print(ack)
    }
    
    socket?.connect()
  }
}

