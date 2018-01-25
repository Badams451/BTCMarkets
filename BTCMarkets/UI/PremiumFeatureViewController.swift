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
  @IBOutlet var restoreButton: UIButton!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  
  let inAppPurchase: InAppPurchase = InAppPurchase()
  let store = PurchasesStore.sharedInstance

  @IBAction func purchaseButtonTapped(_ sender: Any) {
    showLoadingState()
    inAppPurchase.purchaseProVersion() { [weak self] in
      self?.hideLoadingState()
    }
  }

  @IBAction func restoreButtonTapped(_ sender: Any) {
    showLoadingState()
    inAppPurchase.restorePurchase() { [weak self] in
      self?.hideLoadingState()
    }
  }
  
  private func showLoadingState() {
    activityIndicator.startAnimating()
    purchaseButton.isEnabled = false
    restoreButton.isEnabled = false
  }
  
  private func hideLoadingState() {
    activityIndicator.stopAnimating()
    purchaseButton.isEnabled = true
    restoreButton.isEnabled = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    showLoadingState()
    inAppPurchase.fetchProducts() { [weak self] in
      self?.hideLoadingState()
      
      guard let product = $0 else { return }
      
      let subscriptionPeriod = product.subscriptionPeriod?.subscriptionPeriodDescription ?? "period"
      
      self?.purchaseButton.setTitle("Subscribe now - \(product.price.doubleValue.dollarValue) per \(subscriptionPeriod)", for: .normal)
    }
  }
}
