
/*
 MovieAPPFirebaseService.swift
 
 Created by Nicholas Moignard on 27/7/16.
 
 Synopsis:
 Data Members:
 Mehtods:
 Developer Notes:
  ~ Inside getObjectFromFirebaseWithKeyValuePairs():
        Throw an error if firebase returns with more than one object.
 */


import Foundation
import Firebase



class FirebaseService {
  
  var userLoggedInWhenAppOpened: Bool = false
  
  func getUsersFilms(completionHandler: ([String: AnyObject]) -> Void) {
    /* Get a list of all users films from firebase */
    let ref = FIRDatabase.database().reference()
    if let user = FIRAuth.auth()?.currentUser {
      ref.child("reviews/\(user.uid)").observeEventType(FIRDataEventType.Value, withBlock: {
        snapshot in
        
        let snapDict = snapshot.value as! [String: AnyObject]
        
       
        completionHandler(snapDict)
        // check if null else pass snapshot to completion handler
      })
    }
  }
  
  func checkIdAgainstUsersHistory(filmID: Int, completionHandler: (Bool) -> Void) {
    /* Check users firebase to determine if they have seen a card return result of search */
    
    let ref = FIRDatabase.database().reference()
    if let user = FIRAuth.auth()?.currentUser {
      ref.child("reviews/\(user.uid)/\(filmID)").observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
        (snapshot) in
        // card seen
        if snapshot.value is NSNull {
//          print("film is unseen")
          completionHandler(true)
        } else {
          print("film no. \(filmID) has been seen \n\(snapshot)")
          completionHandler(false)
        }
      }) {
        (error) in
        completionHandler(true)
      }
    } else {
      // No user logged in
      completionHandler(true)
    }
  }
  
  func saveSearch(search_uid: String?, searchParameters: [String: AnyObject]) {
    /* PRIVATE function that saves a search to the database.
          However before a search can be saved, it must be checked and formated for the database. so this function shouldn't
          be called unless preceeded by search parameter formating
    */
    let ref = FIRDatabase.database().reference()
    var key: String
    var params = searchParameters
    let timestamp = NSDate().timeIntervalSince1970
    
    params.updateValue(timestamp, forKey: "timestamp")

    if let user = FIRAuth.auth()?.currentUser {
      let userID = user.uid
      
      if let uid = search_uid {
        key = uid
      } else {
        key = ref.child("/searches/\(userID)").childByAutoId().key
      }
      
      let childUpdates = ["/searches/\(userID)/\(key)": params]
      ref.updateChildValues(childUpdates)
    } else {
      // User isn't logged in
      
    }
  }
  
  func saveFilm(uid: String? = nil, id: Int, list: Constants.Review) {
    let ref = FIRDatabase.database().reference(),
        key: String,
        params: [String: AnyObject] = [
          "film_id" : id,
          "list" : list.rawValue
        ]
    
    if let user =  FIRAuth.auth()?.currentUser {
      // user is logged in
      let userID = user.uid
      
      if uid != nil {
        key = uid!
      } else {
        key = ref.child("/reviews/\(userID)").childByAutoId().key
      }
      
      let childUpdates = ["/reviews/\(userID)/\(key)": params]
      ref.updateChildValues(childUpdates)
      
    } else {
      // user isnt logged in
    }
  }
  
  func saveFilm(movie: Movie, list: Constants.Review) {
    let ref = FIRDatabase.database().reference(),
    key: String,
    params: [String: AnyObject] = [
      "film_id" : movie.id!,
      "title" : movie.title!,
//      "release_date" : movie.releaseDate!,
//      "director" : movie.director!,
      "poster_path" : movie.jsonData["poster_path"].string!,
      "list" : list.rawValue
    ]
    
    if let user =  FIRAuth.auth()?.currentUser {
      // user is logged in
      let userID = user.uid
      key = ref.child("/reviews/\(userID)").childByAutoId().key
    
      
      let childUpdates = ["/reviews/\(userID)/\(key)": params]
      ref.updateChildValues(childUpdates)
      
    } else {
      // user isnt logged in
    }
  }
  
  
  
  func getMostRecentSearch(completionHandler: ([String: AnyObject]?) -> Void) {
    /*  Get the most recently used search parameters from firebase
    */
    
    if let user = FIRAuth.auth()?.currentUser {
      let path = "searches/\(user.uid)",
          ref = FIRDatabase.database().reference(),
          query = ref.child(path).queryOrderedByChild("timestamp").queryLimitedToFirst(1)
      
      query.observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
        (snapshot) in
        if let snap = snapshot.value {
          
          // No searches in firebase -> Create a search
          if snap is NSNull {
            print("no searches in firebase")
            completionHandler(nil)
            
          // Found most recent search
          } else {
            let snapDict = snap as! [String: AnyObject],
                (_, search) = snapDict.first!,
                searchParams = search as! [String: AnyObject]
            completionHandler(searchParams)
          }
        }
      })
    } else {
      // user not logged in
      completionHandler(nil)
    }
 }
  
  func createUsersFirstSearch() -> [String: AnyObject] {
    /* User has no search history so initialize the first search */
    
    let search = TMDBService().createSearchParametersDictForFirebase(Constants.Sorting.PopularityDesc, minVoteAvg: nil, genre: nil, year: nil)
    self.saveSearch(nil, searchParameters: search)
    
    return search
  }
  
  func getSearchFromFirebaseWithExactKeyValuePairs(dictionary: [String: AnyObject], completionHandler:(((String, [String: AnyObject])? ) -> Void)  ) {
    /* Looks through users previous search history and checks for a single identical search not considering timestamps and results page number */
    
    // FUNCTION WILL FAIL IF USER IS NOT LOGGED IN
    
    if let user = FIRAuth.auth()?.currentUser {
      let userID = user.uid
      let pathToChild = "searches/\(userID)"
      let params = ["sort_by", "no_params", "vote_averageGTE", "with_genres", "year"]
      let ref = FIRDatabase.database().reference().child(pathToChild)
      let query = ref.queryOrderedByChild("page")
    
      // Get all users searches
      query.observeSingleEventOfType(FIRDataEventType.Value, withBlock: {
        (snapshot) in
        if let snapshot = snapshot.value {
        
          if snapshot is NSNull {  // No objects at the location determined by path
            print("User has no search history")
            let firstSearch = self.createUsersFirstSearch()
          
            completionHandler((userID, firstSearch))
          
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
                  
                  print("number of parameters in search: \(noParams)")
                  print("number of correct: \(correctParams)")
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
}



















