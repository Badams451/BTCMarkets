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

private let rootCurrency = "AUD"
private let instruments = ["BTC", "LTC", "XRP", "ETH", "BCH"]
private let coins = ["Bitcoin", "Litecoin", "Ripple", "Ethereum", "BCash"]

class CoinsViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
    
    tableView.refreshControl = refreshControl
  }
  
  @objc private func loadData() {
    self.tableView.reloadData()
    tableView.refreshControl?.endRefreshing()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return instruments.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCellIdentifier", for: indexPath)
    
    guard let currencyCell = cell as? CurrencyCell else {
      return cell
    }
    
    currencyCell.configure(currency: rootCurrency, instrument: instruments[indexPath.row], coinName: coins[indexPath.row])
    
    return currencyCell
  }
}
