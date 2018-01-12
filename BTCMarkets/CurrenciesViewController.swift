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

private let rootCurrency = "AUD"
private let instruments = ["BTC", "LTC", "XRP", "ETH", "BCH"]
private let coins = ["Bitcoin", "Litecoin", "Ripple", "Ethereum", "BCash"]

protocol CurrencyFetcher {
  func fetchCurrency(currency: String, instrument: String) -> Promise<Currency?>
}

extension CurrencyFetcher {
  func fetchCurrency(currency: String, instrument: String) -> Promise<Currency?> {
    let api = RestfulAPI()
    return api.tick(currency: rootCurrency, instrument: instrument).then { json in
      Currency(JSON: json)
    }
  }
}

class CurrenciesViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
    
    tableView.refreshControl = refreshControl
  }
  
  @objc private func loadData() {
    self.tableView.reloadData()
    tableView.refreshControl?.endRefreshing()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return instruments.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCellIdentifier", for: indexPath)
    
    guard let currencyCell = cell as? CurrencyCell else {
      return cell
    }
    
    currencyCell.configure(currency: rootCurrency, instrument: instruments[indexPath.row], coinName: coins[indexPath.row])
    
    return currencyCell
  }
}

class CurrencyCell: UITableViewCell, CurrencyFetcher {
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var bidLabel: UILabel!
  @IBOutlet var askLabel: UILabel!
  @IBOutlet var currencyLabel: UILabel!
  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var volumeLabel: UILabel!
  
  func configure(currency: String, instrument: String, coinName: String) {
    currencyLabel.text = "\(instrument)/\(currency)"
    coinNameLabel.text = coinName
    
    self.fetchCurrency(currency: currency, instrument: instrument).then { currency -> Void in
      guard let currency = currency else {
        return
      }
      
      DispatchQueue.main.async {
        self.priceLabel.text = "$\(currency.displayPrice)"
        self.volumeLabel.text = "Volume(24h): \(currency.displayVolume)"
        self.bidLabel.text = "Bid: \(currency.displayBestBid)"
        self.askLabel.text = "Ask: \(currency.displayBestAsk)"
        
      }
    }.catch { error in print(error) }
  }
}

struct Currency: Mappable {
  var bestBid: Float?
  var bestAsk: Float?
  var lastPrice: Float?
  var currency: String = ""
  var instrument: String = ""
  var timeStamp: Int?
  var volume24h: Int?
  
  init?(map: Map) {
  }
  
  mutating func mapping(map: Map) {
    bestBid <- map["bestBid"]
    bestAsk <- map["bestAsk"]
    lastPrice <- map["lastPrice"]
    currency <- map["currency"]
    instrument <- map["instrument"]
    timeStamp <- map["timeStamp"]
    volume24h <- map["volume24h"]
  }
}

extension Currency {
  var displayPrice: String {
    return lastPrice != nil ? "\(lastPrice!)" : ""
  }
  
  var displayBestBid: String {
    return bestBid != nil ? "\(bestBid!)" : ""
  }
  
  var displayBestAsk: String {
    return bestAsk != nil ? "\(bestAsk!)" : ""
  }
  
  var displayVolume: String {
    return volume24h != nil ? "\(volume24h!)" : ""
  }
}
