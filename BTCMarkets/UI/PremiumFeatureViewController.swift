//
//  PremiumFeatureViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 1/21/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import StoreKit

class PremiumFeatureViewController: UIViewController {
  static let storyboardName = "PremiumFeature"
  @IBOutlet var purchaseButton: UIButton!

  let inAppPurchase: InAppPurchase = InAppPurchase()
  let store = PurchasesStore.sharedInstance

  @IBAction func laterButtonTapped(_ sender: Any) {
    if let parent = self.parent as? PremiumFeature {
      parent.dismissProVersionScreen()
    }
  }

  @IBAction func purchaseButtonTapped(_ sender: Any) {
    inAppPurchase.purchaseProVersion()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    inAppPurchase.fetchProducts() { [weak self] in
      self?.purchaseButton.setTitle("Buy \($0.localizedTitle) for \($0.price.floatValue) per year", for: .normal)
    }
  }
}
