/*
 MasterDummyViewController.swift
 MovieAPP
 
 Created by Nicholas Moignard on 30/7/16.
 
 Synopsis:
 Data Members:
 Mehtods:
 Developer Notes:
 
 */

import UIKit
import Darwin


class MasterSwipeViewController: UIViewController, LoginSwipeableViewControllerDelegate, MasterSwipeViewControllerDelegate {
  /*  Master SwipeViewController is the main view controller of the cinefile
        ~ it controlls the loading and removing of Child ViewControllers in the form of swipeable cards
        ~ as such it determines weather or not to display tips, user log in, films or advertisments and in which order
  */
  
  
  // list of cards in view
  var childrenViewControllersInView = [FilmCardViewController]()
  
  let INITIAL_NO_CARDS = 3
  let ASPECT_RATIO_OF_CARD: CGFloat = 1.49
  let CARD_SIZE_TO_VIEW_SIZE_RATIO:CGFloat = 0.8
  
  var tMDB = TMDBService()
  let firebase = FirebaseService()
  
  override func viewDidLoad() {
      super.viewDidLoad()
      setupView()
      checkIfLoggedIn()
      tMDB.viewController = self
      tMDB.addMoviesToBufferedArray() {
        _ in
        print("\(self.tMDB.bufferedMovies.count)")
        self.initialSetup()  // begin loading films into the view
        
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
    

  func setupView() {
    // Helper function - configure and set information in view
    updateViews()
  }
  
  func updateViews() {
    // Show and hide the child views
        filmCardViewController.view.hidden = true
   }
  
  // MARK: - User Login
  func checkIfLoggedIn() {
    // Heleper Function to clean up viewDidLoad
    if (FBSDKAccessToken.currentAccessToken() != nil) {
      // user is already logged in
      loginSwipeableCardViewController.view.hidden = true
      firebase.logUserIntoFirebase()
    } else {
      // user is not logged in
      loginSwipeableCardViewController.view.hidden = false
    }
  }
  
  func loadFilmCards() {
    print("Delegate method call worked")
  }
  
  // MARK: - ViewControllers as Children
  
  private func addViewControllerAsChildViewController(viewController: FilmCardViewController) {
    /*
    */
    // Add child ViewController
    addChildViewController(viewController)
    
    // Add child View as subview
    view.addSubview(viewController.view)
    
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
    viewController.delegate = self
  }
  
  
  
  private func removeViewControllerAsChildViewController(viewController: UIViewController) {
    // Notify child ViewController
    viewController.willMoveToParentViewController(nil)
    
    // Remove child View from super View
    viewController.view.removeFromSuperview()
    
    // Notify child ViewController
    viewController.removeFromParentViewController()
  }
  
  
  // MARK: - Card Stack


  
  func initialSetup() {
    /* Helper function, initialize card stack after finished getting assets */
    for _ in 0..<self.INITIAL_NO_CARDS {
      
      // Get movie from tmdb service
      let movie = tMDB.getNextMovie()
      if let movie = movie {
        
        // Add viewController as child
        let movieVC = self.createFilmCardViewController(movie)
        self.childrenViewControllersInView.append(movieVC)
        self.addViewControllerAsChildViewController(movieVC)
      }
    }
  }

  private func createFilmCardViewController(movie: Movie) -> FilmCardViewController {
    // Load storyboardfind
    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    
    // Instantiate ViewController
    let viewController = storyboard.instantiateViewControllerWithIdentifier("FilmCardViewController") as! FilmCardViewController
    viewController.movie = movie
    
    return viewController
  }
  
  lazy var filmCardViewController: FilmCardViewController = {
      // Load storyboard
      let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    
      // Instantiate ViewController
      let viewController = storyboard.instantiateViewControllerWithIdentifier("FilmCardViewController") as! FilmCardViewController
    
      // Add ViewController as a child
      self.addViewControllerAsChildViewController(viewController)
    
      return viewController
  }()
  
  lazy var loginSwipeableCardViewController: LoginSwipeableCardViewController = {

    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    let viewController = storyboard.instantiateViewControllerWithIdentifier("LoginSwipeableCardViewController") as! LoginSwipeableCardViewController
    self.addViewControllerAsChildViewController(viewController)
    
    return viewController
  }()

}



//  func setupCardStack() {
//    // Helper method to keep viewDidLoad uncluttered
//    let INITIAL_NO_CARDS = 5
//    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
//    var viewControllersAdded = 0
//    self.fillBufferedViewControllersInBackground(INITIAL_NO_CARDS)
//
//    dispatch_async(dispatch_get_global_queue(priority, 0)) {
//      print("got of the main queue broooo")
//
//
//      while (viewControllersAdded < INITIAL_NO_CARDS) {
//          sleep(2)
//          print("we out here dispatching")
//          for i in 0..<self.bufferedViewControllers.count {
//            if viewControllersAdded < INITIAL_NO_CARDS {
//              self.addViewControllerAsChildViewController(self.bufferedViewControllers[i])
//              self.childrenViewControllersInView.append(self.bufferedViewControllers[i])
//              viewControllersAdded += 1
//            } else {
//              break
//            }
//          }
//        }
//
//      self.bufferedViewControllers.removeFirst(viewControllersAdded)
//    }
//  }

