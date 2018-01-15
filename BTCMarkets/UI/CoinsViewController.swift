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

class CoinsViewController: UITableViewController {
  private let applicationData = ApplicationData.sharedInstance
  private var instruments: [Currency] = [.btc, .ltc, .xrp, .eth, .bch]
  
  private var profile: Profile {
    return applicationData.selectedProfile ?? applicationData.defaultProfile
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = profile.profileName
    applicationData.subscribeSelectedProfile(target: String(describing: self)) { [weak self] _ in
      self?.navigationItem.title = self?.profile.profileName
      self?.tableView.reloadData()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == CoinToConfigureProfileSegue {
      if let configureProfileViewController = segue.destination as? ConfigureProfileViewController {
        configureProfileViewController.configure(withProfile: profile)
      }
    }
  }
  
  // MARK: TableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return profile.instruments.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCellIdentifier", for: indexPath)
    
    guard let currencyCell = cell as? CurrencyCell else {
      return cell
    }
    
    currencyCell.configure(currency: profile.currency, instrument: profile.instruments[indexPath.row])
    
    return currencyCell
  }
  
  deinit {
    applicationData.unsubscribe(target: String(describing: self))
  }
}
