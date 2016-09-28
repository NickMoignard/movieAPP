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
  var delegate: MasterSwipeViewControllerDelegate?
  
  var parentViewController: FilmCardViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.nextResponder()
      if let viewController = parentResponder as? FilmCardViewController {
        return viewController
      }
    }
    return nil
  }
  
//  var overlayView: SwipeableCardOverlayView? = nil,
//      oCenter: CGPoint? = nil,
//      oOrigin: CGPoint? = nil
//  
  
  
  
  
  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
//  convenience init(frame: CGRect, overlayCenter: CGPoint, overlayOrigin: CGPoint) {
//    self.init(frame: frame)
//    oCenter = overlayCenter
//    oOrigin = overlayOrigin
//    setup()
//  }
  
  // MARK: - Setup
  
  func setup () {
    // Will need to determine importance, atm there is no empty view in storyboard to fill
    addPanGestureRecognizer()
    addDoubleTapGestureRecognizer()
    embelishCardAppearance()
    
  }
  
  
  // NOTE: - Pretty Sure this function is unecessary as im not using the interface builder atm
  
//  func fillEmptyStoryBoardView() {
//    /*  property initialized from method(???)
//        customize frame and autoresizing mask inorder to fill empty view
//        frame equals bounds from the placeholder view in storyboard
//        add view to self
//    */
//    
//    view = loadViewFromNib()
//    view.frame = self.bounds
////    view.layer.cornerRadius = 10 
//    view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//    addSubview(view)
//  }
  
  
  func loadViewFromNib () -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: nibName, bundle: bundle)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    
    return view
  }
  
  func embelishCardAppearance() {
    
    self.layer.cornerRadius = 9
    
    self.layer.shadowRadius = 9
    self.layer.shadowOpacity = 0.05
    self.layer.shadowOffset = CGSizeMake(0, 0)
  }
  
  
  
//  func updateOverlay(distance: CGPoint, actionMargin: CGFloat) {
//    // Update overlay for user gestures
//    
//    let MIN_ALPHA: CGFloat = 0.9
//    
//    if distance.x > 0 {
//      self.overlayView?.setMode(.Right)
//      self.overlayView?.alpha = min(fabs(distance.x) / actionMargin, MIN_ALPHA)
//      
//    } else if distance.x < 0 {
//      self.overlayView?.setMode(.Left)
//      self.overlayView?.alpha = min(fabs(distance.x) / actionMargin, MIN_ALPHA)
//    }
//  }
  
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
                                Constants().getAnimateOutDuration(),
                                animations: {
                                  self.center = finishPoint
                                },
                                completion: {
                                  (value: Bool) in
                                  self.delegate?.removeCardFromView()
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
      
      self.parentViewController?.updateOverlay(pointFromCenter, actionMargin: ACTION_MARGIN)
      
      break
      
    case .Ended:
      // When gesture ends animate the view back to original position and remove transformations (importantly: issue some form of action)
      if (xFromCenter > ACTION_MARGIN) {
        // Right action

        let rightEdge = CGPointMake(500, 2*yFromCenter + self.originalPoint.y)
        animateCardOutTo(rightEdge)
        cardSwipedRight()
        
        
      } else if (xFromCenter < -ACTION_MARGIN) {
        // Left action
        
        let leftEdge = CGPointMake(-500, 2*yFromCenter + self.originalPoint.y)
        animateCardOutTo(leftEdge)
        cardSwipedLeft()
        
      } else {
        // Animate card back
        
        UIView.animateWithDuration(Constants().getAnimateOutDuration()) {
          self.center = self.originalPoint
          self.transform = CGAffineTransformMakeRotation(0)
          self.parentViewController?.resetOverlayAlpha()
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
  
  
  // Overideable functions
  
  func cardDoubleTapped() {
    delegate?.showDetail()
  }
  
  func cardSwipedRight() {
    delegate?.cardSwipedRight()
  }
  
  func cardSwipedLeft() {
    delegate?.cardSwipedLeft()
  }
  
}


extension SwipeableCardView {
  /*  stack overflow
      http://stackoverflow.com/questions/1372977/given-a-view-how-do-i-get-its-viewcontroller
      The UIResponder class does not store or set the next responder automatically, instead returning nil by default. Subclasses must override this method to set the next responder. UIView implements this method by returning the UIViewController object that manages it (if it has one) or its superview (if it doesn’t); UIViewController implements the method by returning its view’s superview; UIWindow returns the application object, and UIApplication returns nil.
      So, if you recurse a view’s nextResponder until it is of type UIViewController, then you have any view’s parent viewController.
   
      Note that it still may not have a parent view controller. But only if the view has not part of a viewController’s view’s view hierarchy.
  */
  
//  var parentViewController: FilmCardViewController? {
//    var parentResponder: UIResponder? = self
//    while parentResponder != nil {
//      parentResponder = parentResponder!.nextResponder()
//      if let viewController = parentResponder as? FilmCardViewController {
//        return viewController
//      }
//    }
//    return nil
//  }
}


