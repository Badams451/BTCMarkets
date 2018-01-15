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
  @IBOutlet var textField: UITextField!
  @IBOutlet private var currencySegmentedControl: UISegmentedControl!
  @IBOutlet private var instrumentsTableView: UITableView!
  private var instruments: [Currency] = []
  private var selectedIndices: Set<Int> = Set()
  private let applicationData = ApplicationData.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadTableView()
    currencySegmentedControl.addTarget(self, action: #selector(loadTableView), for: .valueChanged)
  }
  
  // MARK: TableView
  
  @objc private func loadTableView() {
    guard let selectedIndex = CurrencySegmentedControlIndex(rawValue: currencySegmentedControl.selectedSegmentIndex) else {
      return
    }
    
    switch selectedIndex {
    case .aud:
      instruments = Currency.allValues.filter { $0 != .aud }
    case .btc:
      instruments = Currency.allValues.filter { $0 != .aud && $0 != .btc }
    }

    instrumentsTableView.reloadData()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return instruments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCurrencyCell", for: indexPath)
    
    cell.textLabel?.text = instruments[indexPath.row].coinName
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedIndex = indexPath.row
    let wasSelected = selectedIndices.contains(selectedIndex)
    
    if wasSelected {
      selectedIndices.remove(selectedIndex)
    } else {
      selectedIndices.insert(selectedIndex)
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
    
    let selectedInstruments = instruments.enumerated().filter { index, _ -> Bool in
      return selectedIndices.contains(index)
    }.map { index, instrument -> Currency in
      return instrument
    }
      
    let profile = Profile(profileName: profileName, currency: selectedIndex.currency, instruments: selectedInstruments)
    applicationData.addProfile(profile: profile)
    navigationController?.popViewController(animated: true)
  }
  
  private func displayAlert(message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}
