//
//  FirebaseService.swift
//  Pods
//
//  Created by Nicholas Moignard on 11/8/16.
//
//

import Foundation
import Firebase

class FirebaseService {
  
//  var ref = FIRDatabase.database().reference()
  
  
  func logUserIntoFirebase () -> Void {
    // swap facebook for firebase credentials and pass that to Firebase
    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
    FIRAuth.auth()?.signInWithCredential(credential) {
      (user, error) in
      print("login didCompleteWithResult")
    }
  }
}
