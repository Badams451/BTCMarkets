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
import Mixpanel

class TickerViewController: UITableViewController {
  private let applicationData = TickerStore.sharedInstance
  
  private var ticker: TickerProfile {
    return applicationData.defaultTicker
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.trackEvent(forName: tickerViewEvent)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = ticker.tickerName
    applicationData.subscribeSelectedTicker(target: String(describing: self)) { [weak self] _ in
      self?.navigationItem.title = self?.ticker.tickerName
      self?.tableView.reloadData()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if !splitViewIsCollapsed {
      self.performSegue(withIdentifier: TickerToCoinDetailSegue, sender: self)
      let indexPath = IndexPath(row: 0, section: 0)
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    super.viewDidAppear(animated)

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == CoinToConfigureTickerSegue {
      if let configureTickerViewController = segue.destination as? ConfigureTickerViewController {
        configureTickerViewController.configure(withTicker: ticker)
        Analytics.trackEvent(forName: tickerEditEvent)
      }
    } else if segue.identifier == TickerToCoinDetailSegue
      || segue.identifier == TickerToCoinDetailPeekSegue
      || segue.identifier == TickerToCoinDetailPopSegue {
      if let coinDetailViewController = segue.destination as? CoinDetailViewController {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
          return
        }

        let currency = ticker.currency
        let instrument = ticker.instruments[indexPath.row]

        coinDetailViewController.currency = currency
        coinDetailViewController.instrument = instrument
        coinDetailViewController.navigationItem.title = "\(instrument.coinName) Price"
        
        Analytics.trackEvent(forName: String(format: "\(segueEvent)%@", segue.identifier!))
      }
    }
  }
  
  // MARK: TableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ticker.instruments.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCellIdentifier", for: indexPath)
    
    guard let currencyCell = cell as? CurrencyCell else {
      return cell
    }
    
    currencyCell.configure(currency: ticker.currency, instrument: ticker.instruments[indexPath.row])
    
    if splitViewIsCollapsed {
      currencyCell.accessoryType = .disclosureIndicator
    }
    
    return currencyCell
  }
  
  deinit {
    applicationData.unsubscribe(target: String(describing: self))
  }
}
