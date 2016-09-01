/*
 SwipeViewController.swift
 MovieAPP
 
 Created by Nicholas Moignard on 28/7/16.

 Synopsis:
 Data Members:
 Mehtods:
 Developer Notes:
 
 */

import Foundation
import UIKit

class SwipeViewController: UIViewController, MasterSwipeViewControllerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func removeCardFromView() {
    // override me
  }
  func addOverlayView(overlay: CGPoint) {
    // ... override me baby
  }
  
  // MARK: - SwipeableCardViewDelgate Implementation
  
  func cardSwipedLeft() {
    // ...
    print("i was called")
    cardSwiped()
  }
  func cardSwipedRight() {
    // ...
    cardSwiped()
  }
  
  func showDetail() {
    // ...1
  }
  
  func cardSwiped () -> Void {
    //  Remove Card from loaded cards index and then if there are more cards to load, load the next card.
  }
  
  func loadFilmCards() -> Void {
    // ...
  }
  
  func determineAction(viewController: AnyObject) {
    // ...
  }
  
}
