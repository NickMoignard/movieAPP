//
//  MasterDummyViewController.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 30/7/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import UIKit
import Darwin


class MasterSwipeViewController: UIViewController, LoginSwipeableViewControllerDelegate {
  /*  Master SwipeViewController is the main view controller of the cinefile
        ~ it controlls the loading and removing of Child ViewControllers in the form of swipeable cards
        ~ as such it determines weather or not to display tips, user log in, films or advertisments and in which order
  */
  
  
  
  
  let ASPECT_RATIO_OF_CARD: CGFloat = 1.49
  let CARD_SIZE_TO_VIEW_SIZE_RATIO:CGFloat = 0.60
  
  let tMDB = TMDBService()
  let firebase = FirebaseService()

  override func viewDidLoad() {
      super.viewDidLoad()
      setupView()
//    initialSetup()
      checkIfLoggedIn()

    let searchParams = tMDB.createSearchParametersDictForFirebase(Sorting.PopularityDesc, minVoteAvg: 5.0, genre: nil, year: nil)
    
    tMDB.updateSearchParametersWithCorrectPageNo(searchParams) {
      correctSearchParameters in
      print("updated search parameterswithCorrectPageNo")
      print(correctSearchParameters)
      self.tMDB.getPageOfTMDBDiscoverData(correctSearchParameters){
        json in
        print("we got here")
        print(json)
      }
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    print("sleep begin")
    sleep(3)
    print("sleep end")
    let searchParams = tMDB.createSearchParametersDictForFirebase(Sorting.RevenueDesc, minVoteAvg: 8, genre: nil, year: nil)
    firebase.saveSearch(nil, searchParameters: searchParams)
    
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
        filmCardViewController.view.hidden = false
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
  
  
  
  
  
  
  
  
  
  
  // MARK: - ViewControllers as Children
  
  private func addViewControllerAsChildViewController(viewController: FilmCardViewController) {
    // Add child ViewController
    addChildViewController(viewController)
    
    // Ad child View as subview
    view.addSubview(viewController.view)
    
    // Configure child View
    let cardHeight = self.view.frame.height * CARD_SIZE_TO_VIEW_SIZE_RATIO
    let cardWidth = cardHeight / ASPECT_RATIO_OF_CARD
    let cardFrame = CGRectMake(
      self.view.center.x - (cardWidth / 2),
      self.view.center.y - (cardHeight / 2),
      cardWidth,
      cardHeight
    )
      
    viewController.view.frame = cardFrame
      
    viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
      
    // Notify child ViewController
    viewController.didMoveToParentViewController(self)
      
    // pass the orgin point to the controller
    viewController.cardOrgin = cardFrame.origin
    viewController.addOverlayView()
  }
  
  private func addViewControllerAsChildViewController(viewController: LoginSwipeableCardViewController) {
    // Add child ViewController
    addChildViewController(viewController)
    
    // Ad child View as subview
    view.addSubview(viewController.view)
    
    // Configure child View
    let cardHeight = self.view.frame.height * CARD_SIZE_TO_VIEW_SIZE_RATIO
    let cardWidth = cardHeight / ASPECT_RATIO_OF_CARD
    let cardFrame = CGRectMake(
      self.view.center.x - (cardWidth / 2),
      self.view.center.y - (cardHeight / 2),
      cardWidth,
      cardHeight
    )
    
    viewController.view.frame = cardFrame
    
    viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    
    // Notify child ViewController
    viewController.didMoveToParentViewController(self)
    
    // pass the orgin point to the controller
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
  
  var fincherList = [550, 807, 1949, 2649, 4547, 8077, 37799, 65754, 210577]

  // list of cards to be downloaded
  var listOfFilmsFromFirebase = [Int]()
  
  // list of cards downloaded and instantiated
  var bufferedViewControllers = [FilmCardViewController]()
  
  // list of cards in view
  var childrenViewControllersInView = [FilmCardViewController]()
  
  func initialSetup() {
    let INITIAL_NO_CARDS = 3
    var completions = 0
    
    for _ in 0..<INITIAL_NO_CARDS {
      self.getNextFilmCardViewController() {
        viewController in
        
        self.bufferedViewControllers.append(viewController)
        
        if completions <= 3 {
            self.addViewControllerFromBufferedArrayAsAChild()
        }
        
        completions += 1
      }
    }
    
    
  }
  
  // MARK: - Manage Buffered Array

  func addViewControllerFromBufferedArrayAsAChild() {
    // pop viewcontroller
    if let viewController = self.bufferedViewControllers.popLast() {
      
      // add to view
      self.childrenViewControllersInView.append(viewController)
      self.addViewControllerAsChildViewController(viewController)
      
      // get next filmCardViewController
      self.getNextFilmCardViewController() {
        viewController in
        
        // add to array
        self.bufferedViewControllers.append(viewController)
      }
    }
  }
  
  
  
  func getNextFilmCardViewController(completionHandler: (FilmCardViewController) -> Void) {
    // get off main queue, download film data, get back onto main queue, create view controller, pass viewController into completion handler
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
      self.getNextMovieInList() {
        movie in
        dispatch_async(dispatch_get_main_queue()) {
          if let movie = movie {
            let viewController = self.createFilmCardViewController(movie)
            completionHandler(viewController)
          }
        }
      }
    }
  }
  
  // get data and make a card method
  private func getNextMovieInList( completionHandler: (Movie?) -> Void) {
    
    // SHITTY CODE. KEEPS FAILING
    
    if fincherList.isEmpty {
      print("no more films in list")
      completionHandler(nil)
    } else {
      if let nextID = fincherList.popLast() {
        self.tMDB.initFilmFromID(nextID) {
          movie in
          completionHandler(movie)
        }
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

