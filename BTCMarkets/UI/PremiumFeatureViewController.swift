//
//  PremiumFeatureViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 1/21/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import StoreKit

private let productIdentifier = "com.btcmarkets.pro.version"

final class InAppPurchase: NSObject {

  typealias ProductRequestCompletion = (SKProduct) -> Void

  var productsRequest: SKProductsRequest?
  var product: SKProduct?
  var productRequestCompletion: ProductRequestCompletion?

  override init() {
    super.init()
    SKPaymentQueue.default().add(self)
  }
}

extension InAppPurchase: SKProductsRequestDelegate {
  func fetchProducts(completion: @escaping ProductRequestCompletion) {
    productsRequest?.cancel()

    productsRequest = SKProductsRequest(productIdentifiers: Set([productIdentifier]))
    productsRequest!.delegate = self
    productsRequest!.start()

    self.productRequestCompletion = completion
  }

  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    guard let product = response.products.first else { return }
    self.product = product
    productRequestCompletion?(product)
  }
}

extension InAppPurchase: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        print("purchased")
      case .failed:
        print("fail")
      case .restored:
        print("restored")
      case .deferred:
        print("deferred")
      case .purchasing:
        print("purchasing")
      }
    }
  }
}

class PremiumFeatureViewController: UIViewController {
  static let storyboardName = "PremiumFeature"
  @IBOutlet var purchaseButton: UIButton!

  let inAppPurchase: InAppPurchase = InAppPurchase()

  @IBAction func laterButtonTapped(_ sender: Any) {
    if let parent = self.parent as? PremiumFeature {
      parent.dismissProVersionScreen()
    }
  }

  @IBAction func purchaseButtonTapped(_ sender: Any) {
    
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    inAppPurchase.fetchProducts() { [weak self] in
      self?.purchaseButton.setTitle("Buy \($0.localizedTitle) for \($0.price.floatValue) per year", for: .normal)
    }
  }
}
