//
//  HamburgerTableViewController.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 28/9/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import UIKit

class HamburgerTableViewController: UITableViewController {
  
  let viewControllers = ["masterSwipe", "profile"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewControllers.count
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.row {
    case 0:
      self.performSegueWithIdentifier("showMasterSwipe", sender: self)
      
    case 1:
      self.performSegueWithIdentifier("showProfile", sender: self)
    
    default:
      print("AHHHH HAMBURGER MENU VC FUCK UP didSelectRowAtIndexPath!!!")
      break
    }
    
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
    cell.textLabel?.text = viewControllers[indexPath.row]
    
    return cell
  }
}
