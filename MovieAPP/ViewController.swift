/*
 ViewController.swift
 MovieAPP
 
 Created by Nicholas Moignard on 27/7/16.

 
 Synopsis: unecessary view controller
 Data Members:
 Mehtods:
 Developer Notes:
 
 */

import UIKit

class ViewController: UIViewController {
  let tmdb = TMDBService()
  var cardStack = [FilmCardView]()
  
  let ASPECT_RATIO_OF_CARD: CGFloat = 1.49
  let CARD_SIZE_TO_VIEW_SIZE_RATIO:CGFloat = 0.60
  let HEIGHT_OF_TAB_BAR: CGFloat = 0
  let HEIGHT_OF_NAV_BAR: CGFloat = 0
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tmdb.initMovieFromID(550) {
      data in
      if let movie = data {
        let cardView = self.createCardForView(
          movie,
          cardToViewRatio: self.CARD_SIZE_TO_VIEW_SIZE_RATIO,
          aspectRatio: self.ASPECT_RATIO_OF_CARD,
          navBarHeight: self.HEIGHT_OF_NAV_BAR,
          tabBarHeight: self.HEIGHT_OF_TAB_BAR
        )
        self.cardStack.append(cardView)
        self.view.addSubview(cardView)
//        self.cardStack[0].imageView.image = UIImage(named: "fight_club")
      }
    }
  }
  
  
  func setupInformationInCardView (data: Movie?) {
    // Load information into Outlets call this method from inside the view controller within the animations completionHandler
  }
  
  func createCardForView(data: Movie, cardToViewRatio: CGFloat, aspectRatio: CGFloat, navBarHeight: CGFloat, tabBarHeight: CGFloat) -> FilmCardView {
    // set the location and frame of card view
    // then initialize a new card with the above
    
    let cardHeight = self.view.frame.height * cardToViewRatio
    let cardWidth = cardHeight / aspectRatio
    let cardFrame = CGRectMake(
      self.view.center.x - (cardWidth / 2),
      self.view.center.y - (cardHeight / 2),
      cardWidth,
      cardHeight
    )
    
    let newCard = FilmCardView(frame: cardFrame, data: data)
    
    return newCard
  }

}

