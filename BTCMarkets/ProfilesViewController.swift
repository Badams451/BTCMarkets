//
//  ProfilesViewController.swift
//  BTCMarkets
//
//  Created by Stephen Yao on 14/1/18.
//  Copyright © 2018 Stephen Yao. All rights reserved.
//

import UIKit

class ProfilesViewController: UITableViewController {
  let applicationData = ApplicationData.sharedInstance
  var profiles: [Profile] {
    return applicationData.profiles
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()    
    applicationData.subscribeProfileChange(target: String(describing: self)) { [weak self] profiles in
      self?.tableView.reloadData()
    }
  }
  
  deinit {
    applicationData.unsubscribe(target: String(describing: self))
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
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, success) in
      let profile = self.profiles[indexPath.row]
      self.applicationData.delete(profile: profile)
    }
    
    deleteAction.backgroundColor = .red
    
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let profile = self.profiles[indexPath.row]
    
    applicationData.setSelectedProfile(profile: profile)
  }
}
