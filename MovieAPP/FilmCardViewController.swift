/*
 FilmCardViewController.swift
 MovieAPP
 
 Created by Nicholas Moignard on 30/7/16.
 
 Synopsis: 
    View Controller for individual film cards in the card stack
 
 Data Members:
    directorLabel:
        UILabel, interface builder outlet. displays the directors name
    
    posterView:
        UIImage: interface builder outlet, displays film poster
    
    filmCardView:
        FilmCardView, variable to allow downcasting current view inorder to
        access to views methods
 
    cardOrigin:
        CGPoint, the location of self.origin as determined by parent class
        needed for determining where the overlay view should be placed
 
    movie:
        Movie struct, data to be loaded into view
 
 Methods:
        loadDataFromMovie(movie: Movie) -> Void
        /* Helper function, updates outlets in the view with movie data. */
 
        addOverlayView() -> Void
        /*  Add overlay view over current view with coordinate info from parent
            controller.
            Method to be called by parent when view is added to superview.
        */
 
 Developer Notes:
 
 */

import UIKit

class FilmCardViewController: SwipeViewController {
  // MARK: - Outlets, Constants & Variables
  
  @IBOutlet weak var directorLabel: UILabel!
  @IBOutlet weak var posterView: UIImageView!
  
  var filmCardView: FilmCardView? = nil,
      cardOrgin: CGPoint? = nil,
      movie: Movie? = nil
  
  // MARK: - View Setup
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.filmCardView = (self.view as! FilmCardView)
    if let movie = self.movie {
      loadDataFromMovie(movie)
    }
  }
  
  func loadDataFromMovie(movie: Movie) {
    /* Helper function, updates outlets in the view with movie data.
    */
    print("trying to load data from movie struct")
    if let director = movie.director, poster = movie.poster {
        self.directorLabel.text = director
        self.posterView.image = poster
    } else {
      print("well that didn't work")
    }
  }
  
  func addOverlayView() {
    /*  Add overlay view over current view with coordinate info from parent
        controller.
        Method to be called by parent when view is added to superview.
    */
    var cardFrame = self.view.frame
    cardFrame.origin.x = 0
    cardFrame.origin.y = 0
   
    if let cardOrgin = cardOrgin {
      let overlayView = SwipeableCardOverlayView(frame: cardFrame, center: self.view.center, swipeableCardOriginPoint: cardOrgin)
      self.view.addSubview(overlayView)
      self.filmCardView?.overlayView = overlayView
    }
  }
}
