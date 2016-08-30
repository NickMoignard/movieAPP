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
  
  /*  send self to delegate
      where the delegate will determine what the card is with istype() function and a switch statement
  */
  
  
  
  
  
//  func createCard(cardToViewRatio: CGFloat, aspectRatio: CGFloat, navBarHeight: CGFloat, tabBarHeight: CGFloat) -> SwipeableCardView {
//    // Initialise a Swipeable Card View
//    
//    let cardHeight = self.view.frame.height * cardToViewRatio
//    let cardWidth = cardHeight / aspectRatio
//    let cardFrame = CGRectMake(
//      self.view.center.x - (cardWidth / 2),
//      self.view.center.y - (cardHeight / 2),
//      cardWidth,
//      cardHeight
//    )
//    
//    let newCard = SwipeableCardView(frame: cardFrame, data: movieStuctDummy)
//    newCard.delegate = self
//    
//    return newCard
//  }
  

  
//  func loadNextCard () -> Void {
//    //  Takes an initialized CardView from the bufferedCards array and puts it into a seperate array for loadedCards then either inserts it above the Main View or inserts it below a previously loaded CardView.
//    if bufferedCardsArray.count != 0 {
//      loadedCards.append(bufferedCardsArray.removeFirst())
//      
//      if loadedCards.count > 1 {
//        self.view.insertSubview(loadedCards[loadedCards.count - 1], belowSubview: loadedCards[loadedCards.count - 2])
//      }   else {
//        self.view.insertSubview(loadedCards[0], aboveSubview: self.view)
//      }
//    } else {
//      print("no cards ready to be loaded")
//    }
//  }
  
}
