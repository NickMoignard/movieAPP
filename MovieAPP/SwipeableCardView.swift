/*
 SwipeableCardView.swift
 MovieAPP
 
 Created by Nicholas Moignard on 28/7/16.
 
 Synopsis:
 Data Members:
 Mehtods:
 Developer Notes:
    ~   MovieStruct & OverlayView are currently Optionals and being forced unwrapped for development speed,
        but cannot be optionals for a working version of app
 
    ~  Fix the gesture recognizers Selector Syntax
 
 */

import UIKit

class SwipeableCardView: UIView {
  
  // MARK: - Outlets, Variables
  
  var view: UIView!
  var nibName = "SwipeableCardView"
  var movieStruct: Movie?
  var delegate: SwipeableCardViewDelegate?
  
  var overlayView: SwipeableCardOverlayView? = nil
  
  
  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  
  convenience init (frame: CGRect, data: Movie?) {
    self.init(frame: frame)
    setup()
    movieStruct = data!
    setupInformationInView(movieStruct!)
  }
  
  // MARK: - Setup
  
  func setup () {
    // Will need to determine importance, atm there is no empty view in storyboard to fill
//    fillEmptyStoryBoardView()
    addPanGestureRecognizer()
    addDoubleTapGestureRecognizer()
    addShadowToCard()
    addOverlayView()
  }
  
  func setupInformationInView (data: Movie) {
    // Load information into Outlets call this method from inside the view controller within the animations completionHandler
  }
  
  
  
  
  // NOTE: - Pretty Sure this function is unecessary as im not using the interface builder atm
  
  func fillEmptyStoryBoardView() {
    /*  property initialized from method(???)
        customize frame and autoresizing mask inorder to fill empty view
        frame equals bounds from the placeholder view in storyboard
        add view to self
    */
    
    view = loadViewFromNib()
    view.frame = self.bounds
//    view.layer.cornerRadius = 10 
    view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    addSubview(view)
  }
  
  
  func loadViewFromNib () -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: nibName, bundle: bundle)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    
    return view
  }
  
  func addShadowToCard() {
    self.layer.shadowRadius = 8
    self.layer.shadowOpacity = 0.1
    self.layer.shadowOffset = CGSizeMake(2, 2)
  }
  
  func addOverlayView() {
    let SOME_CONSTANT: CGFloat = 100
    let frame = CGRectMake(
      self.frame.size.width / 2 - SOME_CONSTANT,
      self.frame.size.height / 2 - SOME_CONSTANT,
      SOME_CONSTANT,
      SOME_CONSTANT
    )
    overlayView = SwipeableCardOverlayView(frame: frame)
    addSubview(overlayView!)
  }
  
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
  
  // two dragging parameters: Rotation & Scale. These parameters are linked to  "Drag Force" (how long the finger was dragged over the X-Axis)
  
  var panGestureRecognizer = UIPanGestureRecognizer()
  var originalPoint = CGPoint(), xFromCenter = CGFloat(), yFromCenter = CGFloat()
  let ACTION_MARGIN = CGFloat(120) // distance from center where the action applies. Higher = swipe further in order for the action to be called
  let SCALE_STRENGTH = CGFloat(4) // how quickly the card shrinks. Higher = slower shrinking
  let SCALE_MAX = CGFloat(0.93) // upper bar for how much the card shrinks. Higher = shrinks less
  let ROTATION_MAX = CGFloat(1) // the maximum rotation allowed in radians.  Higher = card can keep rotating longer
  let ROTATION_STRENGTH = CGFloat(320) // strength of rotation. Higher = weaker rotation
  let ROTATION_ANGLE = CGFloat(M_PI/8) // Higher = stronger rotation angle
  
  
  func addPanGestureRecognizer () {
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
        delegate?.cardSwipedRight(self)
        
      } else if (xFromCenter < -ACTION_MARGIN) {
        // Left action
        
        let leftEdge = CGPointMake(-500, 2*yFromCenter + self.originalPoint.y)
        animateCardOutTo(leftEdge)
        delegate?.cardSwipedLeft(self)
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
  
  // MARK: - Show Detail Gesture Recognizer
  func addDoubleTapGestureRecognizer() {
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.cardDoubleTapped))
    recognizer.numberOfTapsRequired = 2
    self.addGestureRecognizer(recognizer)
  }
  
  func cardDoubleTapped() {
    delegate?.showDetail(self)
  }
  // MARK: - Actions
  
  
}





