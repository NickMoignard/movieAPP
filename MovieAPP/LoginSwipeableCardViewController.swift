/*
 LoginSwipeableCardViewController.swift
 MovieAPP
 
 Created by Nicholas Moignard on 12/8/16.

 Synopsis:
 Data Members:
 Mehtods:
 Developer Notes:
  ~   When user logs in, need to call a delegate method in the
      MasterViewController that removes the card from the screen
 
 */

import UIKit
import Firebase

class LoginSwipeableCardViewController: SwipeViewController, FBSDKLoginButtonDelegate {
  
  var cardOrigin: CGPoint? = nil
//  var delegate: LoginSwipeableViewControllerDelegate? = nil
  
  let firebase = FirebaseService()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Overlay View
  func addOverlayView() {
    // ...
  }

  // MARK: - Facebook Login Button and Delegate Methods
  
  func addFBLoginButton() {
    // Adjust SubView Center
    var center = self.view.center
    if let cardOrigin = self.cardOrigin {
      center.x -= cardOrigin.x
      center.y -= cardOrigin.y
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
    
    if error != nil {
      print("there was an error logging in with facebook!")
      
    }
    else if result.isCancelled {
      print("user cancelled logging in with facebook")
      
    } else {
      // Swap facebook credentials with firebase credentials, then login to firebase
      let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
      FIRAuth.auth()?.signInWithCredential(credential) {
        (user, error) in
        if error != nil {
          print("There was an error logging in to firebase after getting facebook credentials")
        }
      }
    }
  }
  

  
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    print("User Logged Out")
  }
}
