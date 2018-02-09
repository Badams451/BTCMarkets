//
//  AppReview.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 9/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import StoreKit

private let holdingsEnteredThreshold = 5
private let appDidBecomeActiveThreshold = 10
private let coinDetailViewedThreshold = 5

class AppReview {
  static func requestReview() {
    #if DEBUG
    #else
      let store = UserStatisticsStore.sharedInstance
      let holdingsThresholdMet = store.holdingsEnteredCount % holdingsEnteredThreshold == 0
      let appDidBecomeActiveThresholdMet = store.appDidBecomeActiveCount % appDidBecomeActiveThreshold == 0
      let coinDetailThresholdMet = store.coinDetailViewedCount % coinDetailViewedThreshold == 0
      
      if holdingsThresholdMet || appDidBecomeActiveThresholdMet || coinDetailThresholdMet {
        SKStoreReviewController.requestReview()
      }      
    #endif
  }
}
