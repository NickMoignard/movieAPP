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
  
  func checkIdAgainstUsersHistory(filmID: Int, completionHandler: (Bool) -> Void) {
    /* Check users firebase to determine if they have seen a card return result of search */
    
    let ref = FIRDatabase.database().reference()
    if let user = FIRAuth.auth()?.currentUser {
      ref.child("viewed_cards/\(user.uid)/\(filmID)").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
        (snapshot) in
        // card seen
        print("film no. \(filmID) has been seen \n\(snapshot)")
        completionHandler(false)
      }) {
        (error) in
        // card unseen
        print("film no. \(filmID) is unseen \n\(error)")
        completionHandler(true)
      }
    } else {
      // No user logged in
      completionHandler(true)
    }
  }
  
  func logUserIntoFirebase () -> Void {
    // swap facebook for firebase credentials and pass that to Firebase
    let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
    FIRAuth.auth()?.signInWithCredential(credential) {
      (user, error) in
      print("login didCompleteWithResult")
    }
  }
  
  
  func saveSearch(search_uid: String?, searchParameters: [String: AnyObject]) {
    let ref = FIRDatabase.database().reference()
    var key: String
    var params = searchParameters
    let timestamp = NSDate().timeIntervalSince1970
    
    params.updateValue(timestamp, forKey: "timestamp")
    
    if let uid = search_uid {
      key = uid
    } else {
      key = ref.child("searches").childByAutoId().key
    }

    if let user = FIRAuth.auth()?.currentUser {
      let userID = user.uid
      
      let childUpdates = ["/searches/\(userID)/\(key)": params]
      ref.updateChildValues(childUpdates)
    } else {
      // User isn't logged in
    }
  }
  
  func getMostRecentSearch(completionHandler: ([String: AnyObject]) -> Void) {
    
    if let user = FIRAuth.auth()?.currentUser {
      let path = "searches/\(user.uid)"
      let ref = FIRDatabase.database().reference()
      let query = ref.child(path).queryOrderedByChild("timestamp").queryLimitedToFirst(1)
      
      query.observeEventType(FIRDataEventType.Value, withBlock: {
        (snapshot) in
        if let snap = snapshot.value {
          let snapDict = snap as! [String: AnyObject]
          let (_, search) = snapDict.first!
          let searchParams = search as! [String: AnyObject]
          
          completionHandler(searchParams)
        }
        
      })
    }
    
 }
  
  func getObjectFromFirebaseWithKeyValuePairs(pathToChild: String, dictionary: [String: AnyObject], completionHandler: (([String: AnyObject]?) -> Void)) {
    /* Get specific object from the database which contain specified key-value pairs */
    
    let ref = FIRDatabase.database().reference()
    
    let mySearchQuery = ref.child(pathToChild)
    
    
    
    //MARK: - Error!!!
    /* 
     vote_average.gte
     5
     2016-08-16 23:08:58.329 MovieAPP[6372:330515] *** Terminating app due to uncaught exception 'InvalidKeyValidation', reason: '(queryEqualToValue:childKey:) Must be a non-empty string and not contain '/' '.' '#' '$' '[' or ']''
    */
    
    // Add filters to search query
    dictionary.forEach() {
      (key, value) in
      mySearchQuery.queryEqualToValue(value, childKey: key)
    }
    
    // Attach observer and callback to query
    mySearchQuery.observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
      (snapshot) in
      if let snapshot = snapshot.value {
        let object = snapshot as! [String: AnyObject]
        completionHandler(object)
      }
    }) {
      (error) in
      print(error)
      completionHandler(nil)
    }
  }
}



















