//
//  PurchasesStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 1/21/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import StoreKit

protocol PremiumFeature: class {
  var describer: String { get }
  func showProVersionScreen()
  func dismissProVersionScreen()
  func subscribeToPurchasesStore()
}

extension PremiumFeature {
  private func proVersionStatusChanged(hasProVersion: Bool) {
    if hasProVersion {
      dismissProVersionScreen()
    } else {
      showProVersionScreen()
    }
  }

  func subscribeToPurchasesStore() {
    let store = PurchasesStore.sharedInstance

    store.subscribe(subscriber: self) { [weak self] purchased in
      self?.proVersionStatusChanged(hasProVersion: purchased)
    }
  }
}

private let productIdentifier = "com.btcmarkets.pro.version"


final class InAppPurchase: NSObject {

  typealias ProductRequestCompletion = (SKProduct) -> Void

  var productsRequest: SKProductsRequest?
  var product: SKProduct?
  var productRequestCompletion: ProductRequestCompletion?
  let purchasesStore: PurchasesStore = PurchasesStore.sharedInstance

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

  func purchaseProVersion() {
    guard let product = product else { return }
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  func restorePurchase() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

extension InAppPurchase: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        print("purchased")
        guard let transactionDate = transaction.transactionDate else {
          return
        }

        let expiryDate = transactionDate.oneYearLater()
        purchasesStore.setPurchasedState(purchased: true, expiry: expiryDate)
        SKPaymentQueue.default().finishTransaction(transaction)
      case .failed:
        print("fail")
        SKPaymentQueue.default().finishTransaction(transaction)
      case .restored:
        print("restored")
        guard let transactionDate = transaction.transactionDate else {
          return
        }

        let expiryDate = transactionDate.oneYearLater()
        purchasesStore.setPurchasedState(purchased: true, expiry: expiryDate)
        SKPaymentQueue.default().finishTransaction(transaction)
      case .deferred:
        print("deferred")
      case .purchasing:
        print("purchasing")
      }
    }
  }
}


final class PurchasesStore {
  typealias Subscriber = PremiumFeature
  typealias PurchasesChanged = (Bool) -> Void

  static var sharedInstance: PurchasesStore = PurchasesStore()
  private var subscribers: [(Subscriber, PurchasesChanged)] = []
  private let purchaseExpiryKey = "proVersionExpiryDate"

  private(set) var purchased: Bool {
    get {
      if let expiryDate = UserDefaults.standard.object(forKey: purchaseExpiryKey) as? Date {
        return expiryDate.timeIntervalSinceNow > 0
      }
      return UserDefaults.standard.bool(forKey: productIdentifier)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: productIdentifier)
      subscribers.forEach { $0.1(newValue) }
    }
  }

  func setPurchasedState(purchased: Bool, expiry: Date) {
    UserDefaults.standard.set(expiry, forKey: purchaseExpiryKey)
    self.purchased = true
  }

  init() {
  }

  func subscribe(subscriber: Subscriber, callback: @escaping PurchasesChanged) {
    subscribers.append((subscriber, callback))
    callback(purchased)
  }

  func unsubscribe(subscriber: Subscriber) {
    if let subscriberIndex = (subscribers.index { return $0.0.describer == subscriber.describer }) {
      subscribers.remove(at: subscriberIndex)
    }
  }
}
