//
//  PremiumFeatureViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 1/21/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class PremiumFeatureViewController: UIViewController {
  static let storyboardName = "PremiumFeature"

  @IBAction func laterButtonTapped(_ sender: Any) {
    if let parent = self.parent as? PremiumFeature {
      parent.dismissProVersionScreen()
    }
  }

  @IBAction func purchaseButtonTapped(_ sender: Any) {    
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
