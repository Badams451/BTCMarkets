//
//  NewProfileViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 15/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class NewProfileViewController: UIViewController {

  @IBOutlet var textField: UITextField!
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let profileName = textField.text else {
      displayAlert(message: "Profile must have a name")
      return
    }
    
    let profile = Profile(profileName: profileName, currency: .aud, instruments: Currency.allValues.filter { $0 != .aud })    
    
    if let configureProfileViewController = segue.destination as? ConfigureProfileViewController {
      configureProfileViewController.configure(withProfile: profile)
    }
    
    super.prepare(for: segue, sender: sender)
  }
}
