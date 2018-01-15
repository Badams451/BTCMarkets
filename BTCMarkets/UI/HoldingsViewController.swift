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
  let holdingsStore = HoldingsStore.sharedInstance
  let currencyValuesStore = CurrencyValuesStore.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    holdingsStore.subscribe(subscriber: String(describing: self)) { [weak self] _ in
      self?.tableView.reloadData()
    }
    
    currencyValuesStore.subscribe(subscriber: String(describing: self)) { [weak self] _ in
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
    let holdingsAmount = holdingsStore.holdingsAmount(forCurrency: currency)
    let currencyValue = currencyValuesStore.value(forCurrency: currency)
    let holdingsValue = holdingsAmount * currencyValue
    
    if let holdingsCell = cell as? HoldingsCell {
      holdingsCell.textLabel?.text = holdingName
      holdingsCell.detailTextLabel?.text = "\(holdingsAmount)"
      holdingsCell.updateValue(forLabel: holdingsCell.amountLabel, previousValue: holdingsCell.holdingValue, newValue: holdingsValue, displayValue: "$ \(holdingsValue)")      
      holdingsCell.amountLabel.text = "$ \(holdingsValue)"
      holdingsCell.holdingValue = holdingsValue
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let alert = UIAlertController(title: "Holdings amount", message: "Enter holdings amount", preferredStyle: .alert)
    let currency = holdingTypes[indexPath.row]
    let holdingsAmount = holdingsStore.holdingsAmount(forCurrency: currency)
    
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
      
      self?.holdingsStore.storeHolding(currency: currency, amount: amount)
    }
    
    alert.addAction(cancel)
    alert.addAction(ok)
    
    present(alert, animated: true, completion: nil)
  }
  
  deinit {
    holdingsStore.unsubscribe(subscriber: String(describing: self))
    currencyValuesStore.unsubscribe(subscriber: String(describing: self))
  }
}

class HoldingsCell: UITableViewCell {
  @IBOutlet var amountLabel: UILabel!
  
  var holdingValue: Float = 0
  
  func updateValue(forLabel label: UILabel, previousValue: Float?, newValue: Float?, displayValue: String) {
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
}
