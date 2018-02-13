//
//  Analytics.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 30/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Mixpanel

let tickerViewEvent = "ticker:view"
let tickerEditEvent = "ticker:edit:tapped"
let tickersViewEvent = "tickers:view"
let newTickerViewedEvent = "new:ticker:viewed"
let newTickerCreatedEvent = "new:ticker:created"
let tickerEditSavedEvent = "ticker:edit:saved"
let holdingsViewEvent = "holdings:view"
let coinDetailViewEvent = "coin:detail:view"
let tickerConfigureCurrencySelected = "ticker:configure:currency:selected:"
let segueEvent = "app:segue:"

class Analytics {
  static func trackEvent(forName name: String) {
    #if DEBUG
    #else
      Mixpanel.mainInstance().track(event: name)
    #endif
  }
}
