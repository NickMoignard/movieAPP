//
//  SuperSwipeableCardView.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 12/8/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import UIKit

class SuperSwipeableCardView: UIView {
  // MARK: - Outlets, Variables, Constants
  
  let ACTION_MARGIN = CGFloat(120)      // distance from center where the action applies. Higher = swipe further in order for the action to be called
  let SCALE_STRENGTH = CGFloat(4)       // how quickly the card shrinks. Higher = slower shrinking
  let SCALE_MAX = CGFloat(0.93)         // upper bar for how much the card shrinks. Higher = shrinks less
  let ROTATION_MAX = CGFloat(1)         // the maximum rotation allowed in radians.  Higher = card can keep rotating longer
  let ROTATION_STRENGTH = CGFloat(320)  // strength of rotation. Higher = weaker rotation
  let ROTATION_ANGLE = CGFloat(M_PI/8)  // Higher = stronger rotation angle
  
  var panGestureRecognizer = UIPanGestureRecognizer()
  var view: UIView!
  var originalPoint = CGPoint(), xFromCenter = CGFloat(), yFromCenter = CGFloat()
  var overlayView: SwipeableCardOverlayView? = nil
  var delegate: SwipeableCardViewDelegate?

  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addPanGestureRecognizer()
    addShadowToCard()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    addPanGestureRecognizer()
    addShadowToCard()
  }
  
  // MARK: - Design Implementation
  
  func addShadowToCard() {
    self.layer.shadowRadius = 8
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSizeMake(2, 2)
    self.layer.cornerRadius = 5
  }

  // MARK: - Overlay View
  
  func updateOverlay(distance: CGPoint, actionMargin: CGFloat) {
    // Update overlay for user gestures
    
    let MIN_ALPHA: CGFloat = 0.99
    
    if distance.x > 0 {
      overlayView?.setMode(.Right)
      overlayView?.alpha = min(fabs(distance.x) / actionMargin, MIN_ALPHA)
    } else if distance.x < 0{
      overlayView?.setMode(.Left)
      overlayView?.alpha = min(fabs(distance.x) / actionMargin, MIN_ALPHA)
    }
  }
  
  // MARK: - Gesture Recognition
  /* two dragging parameters: Rotation & Scale. These parameters are linked to  "Drag Force" (how long the finger was dragged over the X-Axis) */
  
  func addPanGestureRecognizer() {
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.beingDraged(_:)))
    self.addGestureRecognizer(panGestureRecognizer)
  }
  
  func animateCardOutTo(finishPoint: CGPoint) {
    UIView.animateWithDuration(
      0.4,
      animations: {
        self.center = finishPoint
      },
      completion: {
        (value: Bool) in
        self.removeFromSuperview()
      }
    )
  }
  
  func beingDraged(gestureRecognizer: UIPanGestureRecognizer) {
    let pointFromCenter = gestureRecognizer.translationInView(self)
    xFromCenter = pointFromCenter.x
    yFromCenter = pointFromCenter.y
    
    switch(gestureRecognizer.state) {
    case .Began:
      // Save original position of view before dragging event
      self.originalPoint = self.center
      break
      
    case .Changed:
      // Determine gesture strength
      let rotationStrength = min(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX)
      
      // Calculate the pan gesture 'strength', calculate the rotation and scale changes
      let rotationAngle = (ROTATION_ANGLE * rotationStrength)
      let scale = max(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)
      let transform = CGAffineTransformMakeRotation(rotationAngle)
      let scaleTransfrom = CGAffineTransformScale(transform, scale, scale)

      // Every time the gesture changes update the Scale + Rotation of view and the Position
      self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter)
      self.transform = scaleTransfrom
      self.updateOverlay(pointFromCenter, actionMargin: ACTION_MARGIN)
      
      break
      
    case .Ended:
      // When gesture ends animate the view back to original position and remove transformations (importantly: issue some form of action)
      if (xFromCenter > ACTION_MARGIN) {
        // Right action
        let rightEdge = CGPointMake(500, 2*yFromCenter + self.originalPoint.y)
        animateCardOutTo(rightEdge)
        // delegate?.cardSwipedRight(self)
      } else if (xFromCenter < -ACTION_MARGIN) {
        // Left action
        let leftEdge = CGPointMake(-500, 2*yFromCenter + self.originalPoint.y)
        animateCardOutTo(leftEdge)
        // delegate?.cardSwipedLeft(self)
      } else {
        // Animate card back
        UIView.animateWithDuration(0.3) {
          self.center = self.originalPoint
          self.transform = CGAffineTransformMakeRotation(0)
          self.overlayView?.alpha = 0
        }
      }
      break
      
    default:
      break
    }
  }
}
