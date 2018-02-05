//
//  HoldingsViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Mixpanel

enum HoldingItemType {
  case currency
  case equity
}

private protocol HoldingItem {
  var reuseIdentifier: String { get }
  var type: HoldingItemType { get }
}

extension Currency: HoldingItem {
  var reuseIdentifier: String {
    return "HoldingsCell"
  }
  
  var type: HoldingItemType {
    return .currency
  }
}

private struct TotalEquityItem: HoldingItem {
  var reuseIdentifier: String {
    return "EquityCell"
  }
  
  var type: HoldingItemType {
    return .equity
  }
}

class HoldingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet private var tableView: UITableView!
  private let holdingItems = Currency.allExceptAud
  private let totalEquityItem = TotalEquityItem()
  private let holdingsStore = HoldingsStore.sharedInstance
  private let currencyStoreAud = CoinsStoreAud.sharedInstance
  private var allItems: [HoldingItem]  {
    return holdingItems + [totalEquityItem]
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.trackEvent(forName: holdingsViewEvent)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    holdingsStore.subscribe(subscriber: String(describing: self)) { [weak self] _ in
      self?.tableView.reloadData()
    }
    
    currencyStoreAud.subscribe(subscriber: String(describing: self)) { [weak self] _ in
      self?.tableView.reloadData()
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = allItems[indexPath.row]
    
    let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier, for: indexPath)
    
    switch item.type {
    case .currency:
      let currency = holdingItems[indexPath.row]
      guard let coin = currencyStoreAud.coin(forCurrency: currency),
        let holdingsCell = cell as? HoldingsCell else {
          return cell
      }
      let holdingName = currency.rawValue.uppercased()
      let holdingsAmount = holdingsStore.holdingsAmount(forCurrency: currency)
      let currencyValue = coin.lastPrice
      let holdingsValue = holdingsAmount * currencyValue
      
      holdingsCell.currencyLabel?.text = holdingName
      holdingsCell.holdingsAmountLabel.text = "\(holdingsAmount.holdingsValue) \(currency.rawValue)"
      holdingsCell.updateValue(forLabel: holdingsCell.audAmountLabel, previousValue: holdingsCell.holdingValue, newValue: holdingsValue, displayValue: "\(holdingsValue.dollarValue)")
      holdingsCell.holdingValue = holdingsValue
    case .equity:
      let coins = Currency.allExceptAud.flatMap { currencyStoreAud.coin(forCurrency: $0) }
      
      let value = coins.reduce(0) { (acc, coin) -> Double in
        guard let currency = Currency(rawValue: coin.instrument) else {
          return acc
        }
        
        return acc + coin.lastPrice * holdingsStore.holdingsAmount(forCurrency: currency)
      }
      
      guard let equityCell = cell as? EquityCell else { return cell }

      equityCell.updateValue(forLabel: equityCell.equityAmountLabel, previousValue: equityCell.equityValue, newValue: value, displayValue: "\(value.dollarValue)")
      equityCell.equityValue = value
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let item = allItems[indexPath.row]
    guard item.type == .currency else { return }
    
    let alert = UIAlertController(title: "Holdings amount", message: "Enter holdings amount", preferredStyle: .alert)
    let currency = holdingItems[indexPath.row]
    let holdingsAmount = holdingsStore.holdingsAmount(forCurrency: currency)
    
    alert.addTextField { textField in
      textField.text = "\(holdingsAmount.holdingsValue)"
      textField.keyboardType = .decimalPad
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
    let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
      guard let amountString = alert.textFields?.first?.text else {
        return
      }
      
      guard let amount = Double(amountString) else {
        return
      }
      
      self?.holdingsStore.storeHolding(currency: currency, amount: amount)
    }
    
    alert.addAction(cancel)
    alert.addAction(ok)
    
    present(alert, animated: true, completion: nil)
    Analytics.trackEvent(forName: "holdings:cell:tap:\(currency.coinName)")
  }
  
  deinit {
    holdingsStore.unsubscribe(subscriber: String(describing: self))
    currencyStoreAud.unsubscribe(subscriber: String(describing: self))
  }
}

class HoldingsCell: UITableViewCell {
  @IBOutlet var audAmountLabel: UILabel!
  @IBOutlet var currencyLabel: UILabel!
  @IBOutlet var holdingsAmountLabel: UILabel!
  var holdingValue: Double = 0
}

class EquityCell: UITableViewCell {
  @IBOutlet var equityAmountLabel: UILabel!
  var equityValue: Double = 0
}
