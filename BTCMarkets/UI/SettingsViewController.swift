//
//  SettingsViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 6/8/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

  @IBOutlet var darkModeSwitch: UISwitch!

  private let settingsStore = SettingsStore.sharedInstance

  override func viewDidLoad() {
    super.viewDidLoad()

    self.darkModeSwitch.isOn = settingsStore.isDarkModeOn
  }

  @IBAction func onDarkSwitchTapped(_ sender: Any) {
    self.settingsStore.toggleDarkMode()

    NotificationCenter.default.post(name: NotificationName.DarkModeToggledNotification, object: nil)
  }

}
