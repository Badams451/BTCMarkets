//
//  UserStatisticsStore.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 6/8/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import Foundation
import UIKit

class AppThemeStore {
  private let userDefaults = UserDefaults.standard
  static var sharedInstance: AppThemeStore = AppThemeStore()

  enum Theme {
    case light
    case dark

    static var current: Theme = SettingsStore.sharedInstance.isDarkModeOn ? .dark : .light
    var textColor: UIColor {
      switch self {
      case .light:
        return .black
      case .dark:
        return .white
      }
    }

    var cellBackgroundColor: UIColor {
      switch self {
      case .light:
        return .white
      case .dark:
        return .black
      }
    }

    var barTintcolor: UIColor {
      switch self {
      case .light:
        return .white
      case .dark:
        return .black
      }
    }

    var tintColor: UIColor? {
      switch self {
      case .light:
        return nil
      case .dark:
        return nil
      }
    }

    var barStyle: UIBarStyle {
      switch self {
      case .light:
        return .default
      case .dark:
        return .black
      }
    }

    var navigationBarTitleColor: UIColor {
      switch self {
      case .light:
        return .black
      case .dark:
        return .white
      }
    }

    var cellSelectStyle: UITableViewCellSelectionStyle {
      switch self {
      case .light:
        return .default
      case .dark:
        return .none
      }
    }
  }

  func startObserving() {
    NotificationCenter.default.addObserver(self, selector: #selector(setTheme), name: NotificationName.DarkModeToggledNotification, object: nil)
    setTheme()
  }

  func stopObserving() {
    NotificationCenter.default.removeObserver(self)
  }

  @objc func setTheme() {
    let theme: Theme = Theme.current

    UITabBar.appearance().barTintColor = theme.barTintcolor
    UITabBar.appearance().barStyle = theme.barStyle
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.navigationBarTitleColor]
    UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.navigationBarTitleColor]
    UINavigationBar.appearance().tintColor = theme.tintColor
    UINavigationBar.appearance().barTintColor = theme.barTintcolor
    UILabel.appearance().textColor = theme.textColor
    UITableViewCell.appearance().backgroundColor = theme.cellBackgroundColor
    UITableView.appearance().backgroundColor = theme.cellBackgroundColor
    UITableViewCell.appearance().selectionStyle = theme.cellSelectStyle

    let windows = UIApplication.shared.windows
    for window in windows {
      for view in window.subviews {
        view.removeFromSuperview()
        window.addSubview(view)
      }
    }
  }
}
