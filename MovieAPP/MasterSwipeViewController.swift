/*
 MasterDummyViewController.swift
 MovieAPP
 
 Created by Nicholas Moignard on 30/7/16.
 
 Synopsis:
    Master SwipeViewController is the main view controller of the cinefile
 
      ~ It controlls the loading and varoving of Child ViewControllers in the
        form of swipeable cards
 
      ~ As such it determines weather or not to display tips, user log in, films
        or advertisments and in which order
 
      ~ We present the core card swiping functionality of app in this view. The
        view controller acts as a parent to each subview (card)
 
 Data Members:
    ~ INITIAL_NO_CARDS
    ~ ASPECT_RATIO_OF_CARD
    ~ CARD_SIZE_TO_VIEW_SIZE_RATIO
    ~ tMDB
    ~ firebase
    ~ childrenViewControllersInView
 
    Lazyily loaded variables:
      ~ loginSwipeableCardViewController: LoginSwipeableCardViewController
 
 Methods:
    UIViewController Methods:
      ~ viewDidLoad() -> Void
    
    Setup:
      ~ initialSetup() -> Void
 
    View Controllers as children:
      ~ createFilmCardViewController(movie: Movie) -> FilmCardViewController
      ~ addViewControllerAsChildViewController(viewController: FilmCardViewController) -> Void
      ~ addViewControllerAsChildViewController(viewController: LoginSwipeableCardViewController) -> Void
      ~ removeViewControllerAsChildViewController(viewController: UIViewController) -> Void
    
    Master Swipe VC Delegate Methods:
      ~ cardSwiped() -> Void
      ~ cardSwipedRight(card: SwipeableCardView) -> Void
      ~ cardSwipedLeft(card: SwipeableCardView) -> Void
 
 Developer Notes:
    Class still undergoing heavy development
 
 */

import UIKit
import Darwin


class MasterSwipeViewController: SwipeViewController, LoginMasterSwipeViewControllerDelegate {

  // MARK: - Variables & Constant declarations
  
  let INITIAL_NO_CARDS = 3,
      ASPECT_RATIO_OF_CARD: CGFloat = 1.49,
      CARD_SIZE_TO_VIEW_SIZE_RATIO:CGFloat = 0.6
  
  let tMDB = TMDBService(),
      firebase = FirebaseService()
  
  var childrenViewControllersInView = [FilmCardViewController]()
  
  // MARK: - Lazy loading custom View Controllers=
  
//  lazy var loginSwipeableCardViewController: LoginSwipeableCardViewController = {
//    /* Instantiate View Controller then save it when variable is called upon */
//    
//    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//    let viewController = storyboard.instantiateViewControllerWithIdentifier("LoginSwipeableCardViewController") as! LoginSwipeableCardViewController
//    self.addViewControllerAsChildViewController(viewController)
//    
//    return viewController
//  }()
  
  
  // MARK: - UIViewController Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // show login view controller
    presentLoginViewController()
    
    
    // Start downloading movies
    self.tMDB.addMoviesToBufferedArray() {
      _ in
      self.initialSetup()
    }
  }
  
  
  // MARK: - Setup
  
  func initialSetup() {
    /* Helper function, initialize card stack after finished getting assets */
    
    for _ in 0..<self.INITIAL_NO_CARDS {
      
      // Get movie from tmdb service
      if let movie = tMDB.getNextMovie() {
        
        // Add viewController as child
        let movieVC = self.createFilmCardViewController(movie)
        self.childrenViewControllersInView.append(movieVC)
//        self.childrenViewControllersInView.insert(movieVC, atIndex: 0)
        self.addViewControllerAsChildViewController(movieVC)
      }
      
    }
  }
  
  
  // MARK: - ViewControllers as Children
  
  
  
  private func presentLoginViewController() {
    /* Add login card to the view */
    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    let viewController = storyboard.instantiateViewControllerWithIdentifier("LoginSwipeableCardViewController") as! LoginSwipeableCardViewController
    self.addViewControllerAsChildViewController(viewController)
  }
  
  private func createFilmCardViewController(movie: Movie) -> FilmCardViewController {
    // Load storyboardfind
    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    
    // Instantiate ViewController
    let viewController = storyboard.instantiateViewControllerWithIdentifier("FilmCardViewController") as! FilmCardViewController
    
    viewController.movie = movie
    
    return viewController
  }
  
  private func addViewControllerAsChildViewController(viewController: FilmCardViewController) {
    /*
    */
    print("adding view controller as child")
    
    // Add child ViewController
    addChildViewController(viewController)
    
    // Add child View as subview
//    view.addSubview(viewController.view)
    view.insertSubview(viewController.view, atIndex: 0)
    
    // Configure child View
    let cardHeight = self.view.frame.height * CARD_SIZE_TO_VIEW_SIZE_RATIO,
        cardWidth = cardHeight / ASPECT_RATIO_OF_CARD,
        cardFrame = CGRectMake(
      self.view.center.x - (cardWidth / 2),
      self.view.center.y - (cardHeight / 2),
      cardWidth,
      cardHeight
    )
    
    // Set frame and resizing mask
    viewController.view.frame = cardFrame
    viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
      
    // Notify child ViewController
    viewController.didMoveToParentViewController(self)
  
    // pass the orgin point to the controller
    viewController.cardOrgin = cardFrame.origin
    viewController.addOverlayView()
    
    // Get notifications from gesture recoginizers
    let swipeableView = viewController.view as! SwipeableCardView
    swipeableView.delegate = self
  }
  
  private func addViewControllerAsChildViewController(viewController: LoginSwipeableCardViewController) {
    /*
    */
    addChildViewController(viewController)
    view.addSubview(viewController.view)

    let cardHeight = self.view.frame.height * CARD_SIZE_TO_VIEW_SIZE_RATIO,
        cardWidth = cardHeight / ASPECT_RATIO_OF_CARD,
        cardFrame = CGRectMake(
      self.view.center.x - (cardWidth / 2),
      self.view.center.y - (cardHeight / 2),
      cardWidth,
      cardHeight
    )
    
    viewController.view.frame = cardFrame
    viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    viewController.didMoveToParentViewController(self)
    
    // Set information in viewController
    viewController.cardOrigin = cardFrame.origin
    viewController.addOverlayView()
    viewController.addFBLoginButton()
    
    let swipeableCardView = viewController.view as! LoginSwipeableView
    swipeableCardView.masterViewController = self
  }
  
  private func removeViewControllerAsChildViewController(viewController: UIViewController) {
    // Notify child ViewController
    viewController.willMoveToParentViewController(nil)
    
    // Remove child View from super View
    viewController.view.removeFromSuperview()
    
    // Notify child ViewController
    viewController.removeFromParentViewController()
  }
  
  

  
  
  // MARK: - Master Swipe VC Delegate Methods
  
  func loginViewDismissed() {
    //....
    print("we dismissed the login view")
  }
  
  override func cardSwiped() {
    // add an additional card to the stack
    if let movie = self.tMDB.getNextMovie() {
      // Add viewController as child
      print("got next movie")
      let movieVC = self.createFilmCardViewController(movie)
            self.childrenViewControllersInView.append(movieVC)
      self.addViewControllerAsChildViewController(movieVC)
    }
    
    
    
    print("we swiped a card away")
    // Remove the first card after delay
    
    
    
    let vc = self.childrenViewControllersInView.removeAtIndex(0)
    self.removeViewControllerAsChildViewController(vc)
    
    
  }
  
  override func cardSwipedRight() {
    
    let vc = self.childrenViewControllersInView.first
    
    if let id = vc?.id {
      firebase.saveFilm(id: id, list: Constants.Review.Save)
    }
    
    
    self.cardSwiped()

    
    print("swiped right")
    
  }
  
  override func cardSwipedLeft() {
    let vc = self.childrenViewControllersInView.first
    
    if let id = vc?.id {
      firebase.saveFilm(id: id, list: Constants.Review.Remove)
    }
    
    
    self.cardSwiped()
    
    
    print("swiped left")
    
  }
}


