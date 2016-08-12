//
//  DummyViewController.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 30/7/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import UIKit

class FilmCardViewController: SwipeViewController {

  @IBOutlet weak var directorLabel: UILabel!
  @IBOutlet weak var posterView: UIImageView!
//  @IBOutlet weak var progressView: UIProgressView!
  var filmCardView: FilmCardView? = nil
  var cardOrgin: CGPoint? = nil
  var movie: Movie? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.filmCardView = (self.view as! FilmCardView)
    
//    progressView.transform = CGAffineTransformScale(progressView.transform, 1, 5)
    
    if let movie = self.movie {
      loadDataFromMovie(movie)
    }
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func loadDataFromMovie(movie: Movie) {
    if let director = movie.director, poster = movie.poster {
        self.directorLabel.text = director
        self.posterView.image = poster
    }
  }
  
  // MARK: - Overlay View
  
  func addOverlayView() {
    var cardFrame = self.view.frame
    cardFrame.origin.x = 0
    cardFrame.origin.y = 0
   
    if let cardOrgin = cardOrgin {
      let overlayView = SwipeableCardOverlayView(frame: cardFrame, center: self.view.center, swipeableCardOriginPoint: cardOrgin)
      self.view.addSubview(overlayView)
      self.filmCardView?.overlayView = overlayView
    }
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
