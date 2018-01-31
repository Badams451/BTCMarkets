//
//  TickersViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 14/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Mixpanel

class TickersViewController: UITableViewController {
  let tickerStore = TickerStore.sharedInstance
  var tickers: [TickerProfile] {
    return tickerStore.tickers
  }
  
  var selectedTicker: TickerProfile? {
    return tickerStore.selectedTicker
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationItem.rightBarButtonItem?.isEnabled = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()    
    tickerStore.subscribeTickerChange(target: String(describing: self)) { [weak self] tickers in
      self?.tableView.reloadData()
    }    
    Analytics.trackEvent(forName: tickersViewEvent)
  }
  
  deinit {
    tickerStore.unsubscribe(target: String(describing: self))
  }

  @IBAction func closeButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tickers.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TickersViewCell", for: indexPath)
    let ticker = tickers[indexPath.row]
    
    if ticker.tickerName == selectedTicker?.tickerName {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    cell.textLabel?.text = "\(ticker.tickerName)"
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, success) in
      let ticker = self.tickers[indexPath.row]
      if ticker.tickerName == self.selectedTicker?.tickerName {
        let alert = UIAlertController(title: "Error", message: "Cannot delete selected ticker", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        return
      }
      self.tickerStore.delete(ticker: ticker)
    }
    
    deleteAction.backgroundColor = .red
    
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let ticker = self.tickers[indexPath.row]
    tickerStore.setSelectedTicker(ticker: ticker)
    self.dismiss(animated: true, completion: nil)
  }
}
