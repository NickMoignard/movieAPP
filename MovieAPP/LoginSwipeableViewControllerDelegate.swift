/*
 LoginSwipeableViewControllerDelegate.swift
 MovieAPP
 
 Created by Nicholas Moignard on 12/8/16.

 
 Synopsis:
 Data Members:
 Mehtods:
 Developer Notes:
 
*/

import Foundation

protocol LoginMasterSwipeViewControllerDelegate {
  func loginViewDismissed() -> Void
  func userLoggedIn() -> Void
  func userLoggedOut() -> Void
}