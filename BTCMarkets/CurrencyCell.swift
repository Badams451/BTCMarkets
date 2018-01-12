//
//  CurrencyCell.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 13/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import PromiseKit

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

  func configure(currency: String, instrument: String, coinName: String) {
    currencyLabel.text = "\(instrument)/\(currency)"
    coinNameLabel.text = coinName

    self.fetchCurrency(currency: currency, instrument: instrument).then { currency -> Void in
      guard let currency = currency else {
        return
      }

      DispatchQueue.main.async {
        self.priceLabel.text = "$\(currency.displayPrice)"
        self.volumeLabel.text = "Volume(24h): \(currency.displayVolume)"
        self.bidLabel.text = "Bid: \(currency.displayBestBid)"
        self.askLabel.text = "Ask: \(currency.displayBestAsk)"

      }
    }.catch { error in print(error) }
  }
}
