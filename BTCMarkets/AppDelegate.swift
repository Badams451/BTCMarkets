//
//  AppDelegate.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 12/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
  }

}

