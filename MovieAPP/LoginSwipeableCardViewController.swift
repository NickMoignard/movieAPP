//
//  LoginSwipeableCardViewController.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 12/8/16.
//  Copyright © 2016 Elena. All rights reserved.
//
// when user logs in, need to call a delegate method in the MasterViewController that removes the card from the screen
import UIKit
import Firebase

class LoginSwipeableCardViewController: SwipeViewController, FBSDKLoginButtonDelegate {
  
  var cardOrigin: CGPoint? = nil
  
  let firebase = FirebaseService()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addFBLoginButton()
  }
  
  // MARK: - Overlay View
  func addOverlayView() {
    // ...
  }

  // MARK: - Facebook Login Button and Delegate Methods
  
  func addFBLoginButton() {
    
    // Adjust SubView Center
    var center = self.view.center
    print(center)
//    print(cardOrigin)
    if let cardOrigin = self.cardOrigin {
      center.x -= cardOrigin.x
      center.y -= cardOrigin.y
      print(center)
    }
    
    
    let loginView:  FBSDKLoginButton = FBSDKLoginButton()
    self.view.addSubview(loginView)
    loginView.center = center
    loginView.readPermissions = ["public_profile", "email"]
    loginView.delegate = self
  }
  
  func returnUserData() {
    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
    graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
      
      if ((error) != nil) {
        // Process error
        print("Error: \(error)")
        
      } else {
        print("fetched user: \(result)")
        let userName : NSString = result.valueForKey("name") as! NSString
        print("User Name is: \(userName)")
        let userEmail : NSString = result.valueForKey("email") as! NSString
        print("User Email is: \(userEmail)")
        
      }
    })
  }
  
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    // DELEGATE METHOD
    print("User Logged In")
    
    if ((error) != nil)
    {
      // Process error
      print("there was an error!")
    }
    else if result.isCancelled {
      // Handle cancellations
      print("user cancelled")
    }
    else {
      // If you ask for multiple permissions at once, you
      // should check if specific permissions missing
      firebase.logUserIntoFirebase()
    }
  }
  

  
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    print("User Logged Out")
  }
}
