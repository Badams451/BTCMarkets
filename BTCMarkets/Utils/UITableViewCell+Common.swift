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
    
    let color: UIColor = previousValue < newValue ? UIColor.darkGreen : UIColor.darkRed
    
    label.text = displayValue
    label.textColor = color
    
    Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
      UIView.transition(with: label, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
        label.textColor = .black
      }, completion: nil)
    }
  }
}

private extension UIColor {
  static var darkGreen: UIColor {
    return UIColor(red: 0, green: 78/255.0, blue: 0, alpha: 1.0)
  }
  
  static var darkRed: UIColor {
    return UIColor(red: 170/255.0, green: 58/255.0, blue: 58/255.0, alpha: 1.0)
  }
}
