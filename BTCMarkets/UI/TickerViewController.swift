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

class TickerViewController: UITableViewController {
  private let applicationData = TickerStore.sharedInstance
  private var instruments: [Currency] = [.btc, .ltc, .xrp, .eth, .bch]
  
  private var ticker: Ticker {
    return applicationData.selectedTicker ?? applicationData.defaultTicker
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = ticker.tickerName
    applicationData.subscribeSelectedTicker(target: String(describing: self)) { [weak self] _ in
      self?.navigationItem.title = self?.ticker.tickerName
      self?.tableView.reloadData()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == CoinToConfigureTickerSegue {
      if let configureTickerViewController = segue.destination as? ConfigureTickerViewController {
        configureTickerViewController.configure(withTicker: ticker)
      }
    }
  }
  
  // MARK: TableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ticker.instruments.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCellIdentifier", for: indexPath)
    
    guard let currencyCell = cell as? CurrencyCell else {
      return cell
    }
    
    currencyCell.configure(currency: ticker.currency, instrument: ticker.instruments[indexPath.row])
    
    return currencyCell
  }
  
  deinit {
    applicationData.unsubscribe(target: String(describing: self))
  }
}
