//
//  UITableViewCell+Common.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 17/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

extension UITableViewCell {
  func updateValue(forLabel label: UILabel, previousValue: Double?, newValue: Double?, displayValue: String) {
    guard let previousValue = previousValue, let newValue = newValue else {
      label.text = displayValue
      return
    }
    
    guard previousValue != newValue else {
      label.text = displayValue
      return
    }
    
    let color: UIColor = previousValue < newValue ? .green : .red
    
    label.text = displayValue
    label.textColor = color
    
    Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
      UIView.transition(with: label, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
        label.textColor = .black
      }, completion: nil)
    }
  }
}
