//
//  CurrenciesViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 12/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import PromiseKit
import ObjectMapper

class CoinsViewController: UITableViewController {
  private var currency: Currency! = .aud
  private var instruments: [Currency] = [.btc, .ltc, .xrp, .eth, .bch]
  private var filteredInstruments: [Currency] {
    return instruments.filter { $0 != currency }
  }
  
  private var coinNames = [
    "BTC": "Bitcoin",
    "LTC": "Litecoin",
    "XRP": "Ripple",
    "ETH": "Ethereum",
    "BCH": "BCash"
  ]
  
  // MARK: TableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredInstruments.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCellIdentifier", for: indexPath)
    
    guard let currencyCell = cell as? CurrencyCell else {
      return cell
    }
    
    currencyCell.configure(currency: currency, instrument: filteredInstruments[indexPath.row])
    
    return currencyCell
  }
}
