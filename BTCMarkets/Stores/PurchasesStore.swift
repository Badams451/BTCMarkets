//
//  PurchasesStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 1/21/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

protocol PremiumFeature: class {
  var describer: String { get }
  func showProVersionScreen()
  func dismissProVersionScreen()
  func subscribeToPurchasesStore()
}

extension PremiumFeature {
  func showProVersionScreen() {
    let proVersionViewController = UIViewController()
    if let viewController = self as? UIViewController {
      viewController.present(proVersionViewController, animated: true, completion: nil)
    }
  }

  func dismissProVersionScreen() {
    if let viewController = self as? UIViewController {
      viewController.dismiss(animated: true, completion: nil)
    }
  }

  private func proVersionStatusChanged(hasProVersion: Bool) {
    if hasProVersion {
      showProVersionScreen()
    } else {
      dismissProVersionScreen()
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

final class PurchasesStore {
  typealias Subscriber = PremiumFeature
  typealias PurchasesChanged = (Bool) -> Void

  static var sharedInstance: PurchasesStore = PurchasesStore()
  private var subscribers: [(Subscriber, PurchasesChanged)] = []

  init() {
    let purchased = UserDefaults.standard.bool(forKey: productIdentifier) as? Bool
  }

  func subscribe(subscriber: Subscriber, callback: @escaping PurchasesChanged) {
    subscribers.append((subscriber, callback))
    callback(true)
  }

  func unsubscribe(subscriber: Subscriber) {
    if let subscriberIndex = (subscribers.index { return $0.0.describer == subscriber.describer }) {
      subscribers.remove(at: subscriberIndex)
    }
  }
}
