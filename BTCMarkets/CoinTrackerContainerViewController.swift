//
//  CoinTrackerContainerViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 14/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class CoinTrackerContainerViewController: SlideMenuController  {
  
  override func awakeFromNib() {
    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CoinsViewController") {
      self.mainViewController = controller
    }
    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "CoinProfileViewController") {
      self.leftViewController = controller
    }
    
    super.awakeFromNib()
  }

  @IBAction func profilesButtonTapped(_ sender: Any) {
    openLeft()
  }

}
