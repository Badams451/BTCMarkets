//
//  AppReview.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 9/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import StoreKit

private let holdingsEnteredThreshold = 15
private let appDidBecomeActiveThreshold = 40
private let coinDetailViewedThreshold = 15

class AppReview {
  static func requestReview() {
    #if DEBUG
    #else
      let store = UserStatisticsStore.sharedInstance
      let holdingsThresholdMet = store.holdingsEnteredCount % holdingsEnteredThreshold == 0 && store.holdingsEnteredCount != 0
      let appDidBecomeActiveThresholdMet = store.appDidBecomeActiveCount % appDidBecomeActiveThreshold == 0 && store.appDidBecomeActiveCount != 0
      let coinDetailThresholdMet = store.coinDetailViewedCount % coinDetailViewedThreshold == 0 && store.coinDetailViewedCount != 0
    
      if holdingsThresholdMet {
        store.incrementStatistic(forKey: appStatsHoldingsEnteredKey)
      }
      
      if appDidBecomeActiveThresholdMet {
        store.incrementStatistic(forKey: appStatsAppBecomeActiveKey)
      }
      
      if coinDetailThresholdMet {
        store.incrementStatistic(forKey: appStatsCoinDetailViewedKey)
      }
    
      if holdingsThresholdMet || appDidBecomeActiveThresholdMet || coinDetailThresholdMet {
        SKStoreReviewController.requestReview()        
      }
    #endif
  }
}
