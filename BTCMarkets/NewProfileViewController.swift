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
}

class NewProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet var currencySegmentedControl: UISegmentedControl!
  @IBOutlet var instrumentsTableView: UITableView!
  var currencies: [Currency] = []
  
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
      currencies = Currency.allValues.filter { $0 != .aud }
    case .btc:
      currencies = Currency.allValues.filter { $0 != .aud && $0 != .btc }
    }

    instrumentsTableView.reloadData()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currencies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCurrencyCell", for: indexPath)
    
    cell.textLabel?.text = currencies[indexPath.row].coinName
    
    return cell
  }
}
