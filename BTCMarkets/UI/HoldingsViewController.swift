//
//  HoldingsViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

private let reuseIdentifier = "HoldingsViewControllerCell"

class HoldingsViewController: UITableViewController {
  let holdingTypes = Currency.allValues
  let store = HoldingsStore.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    store.subscribe(subscriber: String(describing: self)) { [weak self] _ in
      self?.tableView.reloadData()
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return holdingTypes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    let currency = holdingTypes[indexPath.row]
    let holdingName = currency.rawValue.uppercased()
    let holdingsAmount = store.holdingsAmount(forCurrency: currency)
    
    cell.textLabel?.text = holdingName
    cell.detailTextLabel?.text = "\(holdingsAmount)"
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let alert = UIAlertController(title: "Holdings amount", message: "Enter holdings amount", preferredStyle: .alert)
    let currency = holdingTypes[indexPath.row]
    let holdingsAmount = store.holdingsAmount(forCurrency: currency)
    
    alert.addTextField { textField in
      textField.text = "\(holdingsAmount)"
      textField.keyboardType = .decimalPad
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
    let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
      guard let amountString = alert.textFields?.first?.text else {
        return
      }
      
      guard let amount = Float(amountString) else {
        return
      }
      
      self?.store.storeHolding(currency: currency, amount: amount)
    }
    
    alert.addAction(cancel)
    alert.addAction(ok)
    
    present(alert, animated: true, completion: nil)
  }
  
}
