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

private let productIdentifier = "com.btcmarkets.pro.version.subscription"


final class InAppPurchase: NSObject {

  typealias ProductRequestCompletion = (SKProduct?) -> Void
  typealias ProductPurchaseCompletion = () -> Void
  typealias ProductRestoreCompletion = () -> Void

  var productsRequest: SKProductsRequest?
  var product: SKProduct?
  var productRequestCompletion: ProductRequestCompletion?
  var productPurchaseCompletion: ProductPurchaseCompletion?
  let purchasesStore: PurchasesStore = PurchasesStore.sharedInstance
  

  override init() {
    super.init()
    SKPaymentQueue.default().add(self)
  }
  
  deinit {
    SKPaymentQueue.default().remove(self)
    productsRequest?.delegate = nil
    productRequestCompletion = nil
    productPurchaseCompletion = nil
  }
}

extension InAppPurchase: SKProductsRequestDelegate {
  func fetchProducts(completion: @escaping ProductRequestCompletion) {
    productsRequest?.cancel()

    productsRequest = SKProductsRequest(productIdentifiers: Set([productIdentifier]))
    productsRequest!.delegate = self
    productsRequest!.start()
    productRequestCompletion = completion
  }

  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    guard let product = response.products.first else {
      productRequestCompletion?(nil)
      return
    }
    self.product = product
    productRequestCompletion?(product)
  }

  func purchaseProVersion(completion: @escaping ProductPurchaseCompletion) {
    guard let product = product else { return }
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
    productPurchaseCompletion = completion
  }

  func restorePurchase(completion: @escaping ProductRestoreCompletion) {
    SKPaymentQueue.default().restoreCompletedTransactions()    
    productPurchaseCompletion = completion
  }
}

extension SKProductSubscriptionPeriod {
  var subscriptionInterval: TimeInterval {
    var numberOfHours = 0
    switch self.unit {
    case .day: numberOfHours = 24
    case .week: numberOfHours = 24 * 7
    case .month: numberOfHours = 24 * 31
    case .year: numberOfHours = 24 * 366
    }
    
    let numberOfSeconds = numberOfHours * 60 * 60
    let totalTimeInterval = numberOfSeconds * self.numberOfUnits
    return TimeInterval(totalTimeInterval)
  }
  
  var subscriptionPeriodDescription: String {
    let numberOfUnits = self.numberOfUnits
    let prefix = numberOfUnits > 0 ? "\(numberOfUnits) " : ""
    let suffix = numberOfUnits > 1 ? "s" : ""
    var body = ""
    switch self.unit {
    case .day: body = "Day"
    case .week: body = "Week"
    case .month: body = "Month"
    case .year: body = "Year"
    }
    return "\(prefix)\(body)\(suffix)"
  }
}

extension InAppPurchase: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        guard let transactionDate = transaction.transactionDate,
              let subscriptionExpiryInterval = product?.subscriptionPeriod?.subscriptionInterval else {
          return
        }

        let expiryDate = transactionDate.addingTimeInterval(subscriptionExpiryInterval)
        purchasesStore.setPurchasedState(purchased: true, expiry: expiryDate)
        SKPaymentQueue.default().finishTransaction(transaction)
        print("purchased")
      case .restored:
        guard let transactionDate = transaction.original?.transactionDate,
              let subscriptionExpiryInterval = product?.subscriptionPeriod?.subscriptionInterval else {
          break
        }
        
        let expiryDate = transactionDate.addingTimeInterval(subscriptionExpiryInterval)
        let now = Date()
        
        if now.timeIntervalSince(expiryDate) < 0 {
          purchasesStore.setPurchasedState(purchased: true, expiry: expiryDate)          
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        print("restored")
      case .failed:
        SKPaymentQueue.default().finishTransaction(transaction)
        print("failed")
      case .deferred:
        return
      case .purchasing:
        return
      }
    }
    productPurchaseCompletion?()
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
