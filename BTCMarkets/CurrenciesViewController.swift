//
//  CurrencyProfileViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 14/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class CurrenciesViewController: UITableViewController {
  
  private var currencies: [String] = ["AUD", "BTC", "LTC", "XRP", "ETH", "BCH"]

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currencies.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyViewControllerCell", for: indexPath)
    
    cell.textLabel?.text = currencies[indexPath.row]
    
    return cell
  }

}
