//
//  LoginSwipeableView.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 30/8/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import Foundation

class LoginSwipeableView: SwipeableCardView {
  
  var masterViewController: LoginMasterSwipeViewControllerDelegate? = nil
  
  override func cardSwipedLeft() {
    masterViewController?.loginViewDismissed()
  }
  
  override func cardSwipedRight() {
    masterViewController?.loginViewDismissed()
  }
}
