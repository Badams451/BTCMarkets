//
//  ProfilesViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 14/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class ProfilesViewController: UITableViewController {
  var profiles: [Profile] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let applicationData = ApplicationData()
    profiles = applicationData.profiles
  }
  
  @IBAction func closeButtonTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return profiles.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilesViewCell", for: indexPath)
    let profile = profiles[indexPath.row]
    
    cell.textLabel?.text = "\(profile.profileName) \(profile.currency) \(profile.instruments)"
    
    return cell
  }
  
}
