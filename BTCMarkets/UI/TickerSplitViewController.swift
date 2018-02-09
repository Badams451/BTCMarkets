//
//  TickerSplitViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 9/2/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class TickerSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    self.preferredDisplayMode = .allVisible
  }
  

  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
    return true
  }
}
