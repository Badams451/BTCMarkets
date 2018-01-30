//
//  NewTickerViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Mixpanel

private enum CurrencySegmentedControlIndex: Int {
  case aud = 0
  case btc = 1
  
  var currency: Currency {
    switch self {
    case .aud: return .aud
    case .btc: return .btc
    }
  }
}

class ConfigureTickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet private var currencySegmentedControl: UISegmentedControl!
  @IBOutlet private var instrumentsTableView: UITableView!
  
  private let applicationData = TickerStore.sharedInstance
  private var ticker: Ticker?
  private var selectedCurrencies: Set<Currency> = Set()
  
  private var possibleInstruments: [Currency] {
    guard let selectedCurrencyIndex = CurrencySegmentedControlIndex(rawValue: currencySegmentedControl.selectedSegmentIndex) else {
      return []
    }
    
    switch selectedCurrencyIndex {
    case .aud: return Currency.allValues.filter { $0 != .aud }
    case .btc: return Currency.allValues.filter { $0 != .aud && $0 != .btc }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let ticker = ticker else { return }
    
    currencySegmentedControl.addTarget(self, action: #selector(loadTableView), for: .valueChanged)
    currencySegmentedControl.selectedSegmentIndex = getSelectedSegmentIndex(forTicker: ticker).rawValue
    selectedCurrencies = Set(ticker.instruments)
    navigationItem.title = ticker.tickerName
  }
  
  // MARK: Configure
  
  func configure(withTicker ticker: Ticker) {
    self.ticker = ticker
  }
  
  private func getSelectedSegmentIndex(forTicker ticker: Ticker) -> CurrencySegmentedControlIndex {
    switch ticker.currency {
    case .aud: return .aud
    case .btc: return .btc
    default: return .aud
    }
  }
  
  // MARK: TableView
  
  @objc private func loadTableView() {
    instrumentsTableView.reloadData()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return possibleInstruments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TickerCurrencyCell", for: indexPath)
    let currency = possibleInstruments[indexPath.row]
    
    cell.textLabel?.text = possibleInstruments[indexPath.row].coinName
    
    if selectedCurrencies.contains(currency) {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedCurrency = possibleInstruments[indexPath.row]
    
    let wasSelected = selectedCurrencies.contains(selectedCurrency)
    
    if wasSelected {
      selectedCurrencies.remove(selectedCurrency)
    } else {
      selectedCurrencies.insert(selectedCurrency)
    }
    
    let selected = !wasSelected
    if let cell = tableView.cellForRow(at: indexPath) {
      cell.accessoryType = selected ? .checkmark : .none
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  @IBAction func saveTapped(_ sender: Any) {
    guard let ticker = ticker else {
      displayAlert(message: "No ticker was configured. Please try again.")
      return
    }
    
    if ticker.tickerName.isEmpty {
      displayAlert(message: "Ticker must have a name")
    }

    guard let selectedIndex = CurrencySegmentedControlIndex(rawValue: currencySegmentedControl.selectedSegmentIndex) else {
      displayAlert(message: "Must select a currency")
      return
    }
    
    let selectedInstruments = possibleInstruments.filter { selectedCurrencies.contains($0) }

    let updatedTicker = Ticker(tickerName: ticker.tickerName, currency: selectedIndex.currency, instruments: selectedInstruments)
    applicationData.addOrUpdateTicker(ticker: updatedTicker)
    applicationData.setSelectedTicker(ticker: updatedTicker)
    
    if presentingViewController != nil {
      self.dismiss(animated: true, completion: nil)      
      Analytics.trackEvent(forName: newTickerCreatedEvent)
    } else {
      navigationController?.popToRootViewController(animated: true)
      Analytics.trackEvent(forName: tickerEditSavedEvent)
    }
  }
}
