//
//  AppDelegate.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 12/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Mixpanel
import StoreKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  private let userStatsStore = UserStatisticsStore.sharedInstance

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Fabric.with([Crashlytics.self])
    
    CoinsStoreAud.sharedInstance.start()
    CoinsStoreBtc.sharedInstance.start()
    
    #if DEBUG
    #else
      Mixpanel.initialize(token: "c55a5b7d4a857b39d09adc41d446ebc7")
    #endif
    
    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    CoinsStoreAud.sharedInstance.start()
    CoinsStoreBtc.sharedInstance.start()
    UserStatisticsStore.sharedInstance.incrementStatistic(forKey: appStatsAppBecomeActiveKey)
    AppReview.requestReview()
  }
}

