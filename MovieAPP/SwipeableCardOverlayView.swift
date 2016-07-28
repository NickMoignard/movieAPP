//
//  SwipeableCardOverlayView.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 28/7/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import UIKit

enum OverlayViewMode {
  case None
  case Left
  case Right
}

class SwipeableCardOverlayView: UIView {
  var imageView = UIImageView()
  var mode = OverlayViewMode.None
  
  
  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setView()
    addImageView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setView() {
    self.backgroundColor = UIColor.clearColor()
  }
  
  func addImageView() {
    //set image view frame
    imageView.frame = CGRect(x: 50,y: 50,width: 100,height: 100)
    self.addSubview(imageView)
  }
  
  
  
  func setMode(mode: OverlayViewMode) {
    // Method called by the SwipeableCardView on which this view is overlaying
    
    if (self.mode == mode){
      return
    }
    
    self.mode = mode
    
    switch (mode) {
      
    case .Left:
      imageView.image = UIImage(named: "disliked")
      break
      
    case .Right:
      imageView.image = UIImage(named: "liked")
      break

    case .None:
      break
    }
  }
  
}
