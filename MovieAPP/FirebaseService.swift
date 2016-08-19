//
//  FirebaseService.swift
//  Pods
//
//  Created by Nicholas Moignard on 11/8/16.
//
//




/* 
  Future Updates:
    ~ Inside getObjectFromFirebaseWithKeyValuePairs():
        Throw an error if firebase returns with more than one object.
*/

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
  
  
  func _saveSearch(search_uid: String?, searchParameters: [String: AnyObject]) {
    /* PRIVATE function that saves a search to the database.
          However before a search can be saved, it must be checked and formated for the database. so this function shouldn't
          be called unless preceeded by search parameter formating
    */
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
  
  
  
  func getSearchFromFirebaseWithExactKeyValuePairs(pathToChild: String, dictionary: [String: AnyObject], completionHandler:(((String, [String: AnyObject])? ) -> Void)  ) {
    /* Looks through users previous search history and checks for a single identical search not considering timestamps and results page number */

    let params = ["sort_by", "no_params", "vote_averageGTE", "with_genres", "year"]
    let ref = FIRDatabase.database().reference().child(pathToChild)
    let query = ref.queryOrderedByChild("page")
    
    // Get all users searches
    query.observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
      (snapshot) in
      if let snapshot = snapshot.value {
        
        if snapshot is NSNull {  // No objects at the location determined by path
          print("NSNull was returned from firebase.\nPath Error!")
          completionHandler(nil)
          
        } else {
          
          // Get individual object from firebase data as a dict
          let firebaseData = snapshot as! [String: AnyObject]
          let filteredFirebaseData = firebaseData.filter() {
            (uid, jsonObject) in
            
            var boolReturn: Bool = false
            let dict = jsonObject as? [String: AnyObject]
            if let dict = dict {
              
              
              
              // Check if object from firebase is the same as input dictionary
              var correctParams: Int = 0
              params.forEach({
                (key) in
                
                // correctly cast the dictionay values as to work with the swift comparison functions (==. !=)
                switch key {
                  case "sort_by":
                    let firebaseValue = dict[key] as? String
                    let inputValue = dictionary[key] as? String
                  
                    if (firebaseValue == nil && inputValue == nil)  {
                      // check next key
                      break
                    } else if (firebaseValue == nil && inputValue != nil) || (firebaseValue != nil && inputValue == nil) {
                      // this key: value pair is wrong
                      break
                    } else if firebaseValue! != inputValue! {
                      // this key: value pair is wrong
                      break
                    } else {
                      // key: value pair is correct
                      correctParams += 1
                    }

                  case "no_params":
                    let firebaseValue = dict[key] as? Int
                    let inputValue = dictionary[key] as? Int
                    if (firebaseValue == nil && inputValue == nil)  {
                      break
                    } else if (firebaseValue == nil && inputValue != nil) || (firebaseValue != nil && inputValue == nil) {
                      break
                    } else if firebaseValue! != inputValue! {
                      break
                    } else {
                      correctParams += 1
                    }
                  
                  case "vote_averageGTE":
                    let firebaseValue = dict[key] as? Float
                    let inputValue = dictionary[key] as? Float
                    if (firebaseValue == nil && inputValue == nil)  {
                      break
                    } else if (firebaseValue == nil && inputValue != nil) || (firebaseValue != nil && inputValue == nil) {
                      break
                    } else if firebaseValue! != inputValue! {
                      break
                    } else {
                      correctParams += 1
                    }
                  
                  case "with_genres":
                    let firebaseValue = dict[key] as? Int
                    let inputValue = dictionary[key] as? Int
                    if (firebaseValue == nil && inputValue == nil)  {
                      break
                    } else if (firebaseValue == nil && inputValue != nil) || (firebaseValue != nil && inputValue == nil) {
                      break
                    } else if firebaseValue! != inputValue! {
                      break
                    } else {
                      correctParams += 1
                    }
                  
                  case "year":
                    let firebaseValue = dict[key] as? Int
                    let inputValue = dictionary[key] as? Int
                    if (firebaseValue == nil && inputValue == nil)  {
                      break
                    } else if (firebaseValue == nil && inputValue != nil) || (firebaseValue != nil && inputValue == nil) {
                      break
                    } else if firebaseValue! != inputValue! {
                      break
                    } else {
                      correctParams += 1
                    }
                  
                  default:
                    break
                }
              })
              
              
              /* 7 parameters in firebase only 5 are comparable. (timestamp and page arn't comparable) */
              
              if let noParams = dictionary["no_params"] as? Int {
                if noParams - 2 == correctParams {
                  // This is the correct dictionary object
                  boolReturn = true
                }
              }
            }
            return boolReturn
          }
          
          // return the correct search parameters
          if filteredFirebaseData.count == 1{
            let search = filteredFirebaseData.first!.1 as! [String: AnyObject]
            let uid = filteredFirebaseData.first!.0
            completionHandler((uid, search))
          } else {
            completionHandler(nil)
          }
        }
      }
    }) {
      (error) in  //  Firebase Error
      print(error)
      completionHandler(nil)
    }
  }
}



















