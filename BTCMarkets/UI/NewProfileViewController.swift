//
//  NewTickerViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class NewTickerViewController: UIViewController {

  @IBOutlet var textField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textField.borderStyle = .none
    textField.becomeFirstResponder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let tickerName = textField.text else {
      displayAlert(message: "Ticker must have a name")
      return
    }
    
    let ticker = Ticker(tickerName: tickerName, currency: .aud, instruments: Currency.allValues.filter { $0 != .aud })    
    
    if let configureTickerViewController = segue.destination as? ConfigureTickerViewController {
      configureTickerViewController.configure(withTicker: ticker)
    }
    
    super.prepare(for: segue, sender: sender)
  }
}
