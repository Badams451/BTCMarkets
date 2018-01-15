//
//  NewProfileViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

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

class NewProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet private var textField: UITextField!
  @IBOutlet private var currencySegmentedControl: UISegmentedControl!
  @IBOutlet private var instrumentsTableView: UITableView!
  
  private let applicationData = ApplicationData.sharedInstance
  private var profile: Profile = Profile(profileName: "", currency: .aud, instruments: Currency.allValues.filter { $0 != .aud })
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
    
    currencySegmentedControl.addTarget(self, action: #selector(loadTableView), for: .valueChanged)
    
    textField.text = profile.profileName
    currencySegmentedControl.selectedSegmentIndex = getSelectedSegmentIndex(forProfile: profile).rawValue
    selectedCurrencies = Set(profile.instruments)
  }
  
  // MARK: Configure
  
  func configure(withProfile profile: Profile) {
    self.profile = profile
  }
  
  private func getSelectedSegmentIndex(forProfile profile: Profile) -> CurrencySegmentedControlIndex {
    switch profile.currency {
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCurrencyCell", for: indexPath)
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
    guard let profileName = textField.text else {
      displayAlert(message: "Profile must have a name")
      return
    }

    if profileName.isEmpty {
      displayAlert(message: "Profile must have a name")
    }

    guard let selectedIndex = CurrencySegmentedControlIndex(rawValue: currencySegmentedControl.selectedSegmentIndex) else {
      displayAlert(message: "Must select a currency")
      return
    }
    
    let selectedInstruments = possibleInstruments.filter { selectedCurrencies.contains($0) }

    let profile = Profile(profileName: profileName, currency: selectedIndex.currency, instruments: selectedInstruments)
    applicationData.addOrUpdateProfile(profile: profile)
    navigationController?.popViewController(animated: true)
  }
  
  private func displayAlert(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}
