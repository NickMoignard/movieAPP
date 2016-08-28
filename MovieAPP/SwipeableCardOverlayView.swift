
/*
  SwipeableCardOverlayView.swift
  MovieAPP

  Created by Nicholas Moignard on 28/7/16.
  Synopsis:
  Data Members:
  Mehtods:
  Developer Notes:
 
 */
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
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  convenience init(frame: CGRect, center: CGPoint, swipeableCardOriginPoint: CGPoint) {
    self.init(frame: frame)

    setView()
    addImageView(center, swipeableCardOriginPoint: swipeableCardOriginPoint)
  }
  // MARK: - Setup
  
  func setView() {
    self.backgroundColor = UIColor.clearColor()
  }
  
  func addImageView(center: CGPoint, swipeableCardOriginPoint: CGPoint) {
    //set image view frame
    // need to get coordinates from superview, so ill need to set the super view
    print(swipeableCardOriginPoint)
    imageView.frame = CGRect(
      // center point is in relation to the superview and hence need to subtract subview origin point 
                          x: center.x - swipeableCardOriginPoint.x - 50,
                          y: center.y - swipeableCardOriginPoint.y - 50,
                          width: 100,
                          height: 100
    )
    imageView.contentMode = .ScaleAspectFit
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
      imageView.image = UIImage(named: "dislike")
      break
      
    case .Right:
      imageView.image = UIImage(named: "like")
      break

    case .None:
      break
    }
  }
  
}
