/* TMDBService.swift
   MovieAPP
 
   Created by Nicholas Moignard on 27/7/16.
 
 
  Synopsis:
      class to interact with the film data base api
  
    Data members:
      MIN_BUFFER:
        Constant, Minimum number of films in buffer before downloading more data
        from The Movie Database (tmdb).
 
      BUFFER_EMPTY:
        Constant, Minimum number of films before presenting the user with a
        loading screen as to prevent the user from swiping to an empty screen.
 
      BASEURL:
        Constant, The base url for tmdb api.
 
      BASEIMAGEURL:
        Constant, The base url for tmdb image api.
 
      network:
        Instance of the networking struct for downloading json and images.
 
      firebase:
        Instance of the firebase struct as to cleanly interact with the real
        time database.
 
      downloadingPageFromTMDB:
        Flag variable, for determining weather or not to download another page
        of tmdb data
 
      numberOfDownloadingMovies:
        Counter, by contrasting the number of films in buffered array and film
        assets currently downloading we can determine if we need to download
        more film assets to maintain buffered array length
 
      bufferedMovies:
        Array of Movie structs with poster images & film metadata downloaded
 
      searchParameters:
        Dictionary of last known search parameters for a discover request to
        tmdb. This ensures we keep users films relevant and new.
 
      viewController:
        Optional delegate for sending a message back to the controller to
        inform when assets have finished downloading/ ready to load cards into
        view.

 
    Methods:
 
      Initializers
        ~ init()
 
      Film Buffer Management
        ~ getNextMovie() -> Movie?
          /*  Getter method for a single Movie from the buffered array
          */
 
        ~ checkBufferedMovies()
          /*  Check & maintain the items within buffered films array
          */
        
        ~ addMoviesToBufferedArray(completionHandler: (String) -> Void) -> Void
          /* Start the download of a new page of tmdb discover data */


      Movie Database API Interaction
        ~ initFilmFromID(id: Int, completionHandler: (Movie?) -> Void)
          /*  Download a movies assets for a given film id
          */
 
        ~ getPageOfTMDBDiscoverData(searchParameters: [String: AnyObject], completionHandler: (JSON) -> Void)
          /*  Download a page of data from tMDB Discover function
          */
 
        ~ parseSearchParametersDictForTMDB(fbSearchObject: [String: AnyObject]) -> [String: AnyObject]
          /*  Prepare search parameters for url encoding in a request to tmdb
              api
          */
 
        ~ getMoviePoster(json: JSON, size: String, completionHandler: (UIImage?) -> Void) -> Void
          /*  Download movie poster from tmdb image api
          */
 
      Firebase Interaction
        ~ getUsersMostRecentSearchParameters() -> [String: AnyObject]
          /*  Getter method for recent search parameters data member
          */
 
        ~ createSearchParametersDictForFirebase(sorting: Constants.Sorting, minVoteAvg: Float?, genre: Constants.Genre?, year: Int?) -> [String: AnyObject]
          /*  Build correct search parameters for a tmdb discover .GET request
          */
 
        ~ updateSearchParametersWithCorrectPageNo(searchParameters: [String: AnyObject], completionHandler: ([String: AnyObject] -> Void))
          /*  Before adding any additional search objects to a users firebase,
              check that they do not exist yet and update accordingly
          */
 
    Development Notes:
      This Struct is yet to be completed
 
*/


import Foundation
import Firebase
import UIKit
import SwiftyJSON
import Alamofire

class TMDBService: FilmDataBaseDelegate {
  
 
  // MARK: - Variable, Constant Declarations
  
  var MIN_BUFFER: Int = 10,
      BUFFER_EMPTY: Int = 1,
      BASEURL: NSURL,
      BASEIMAGEURL: NSURL
  
  let network = NetworkOperation(),
      firebase = FirebaseService()
  
  var downloadingPageFromTMDB: Bool = false,
      numberOfDownloadingMovies: Int = 0,
      bufferedMovies: [Movie] = [],
      usersMostRecentSearchParameters: [String: AnyObject]? = nil
//      viewController: MasterSwipeViewControllerDelegate? = nil
  
  
  // MARK: - Initializers
  
  init() {
    self.BASEURL =  NSURL(string: "https://api.themoviedb.org")!
    self.BASEIMAGEURL = NSURL(string: "https://image.tmdb.org/t/p/")!
  }

  
  // MARK: - Film Buffer Management
  
  func getNextMovie() -> Movie? {
    print("getting movie from buffer")
    /* Getter method for a single Movie from the buffered array */
    
    self.checkBufferedMovies()
    let movie = self.bufferedMovies.removeFirst()
    return movie
  }
  
  func checkBufferedMovies() {
    print("checking buffered movies")
    /* Check & maintain the items within buffered films array */
    
    // Get current state of the array and downloads
    let lengthBufferedArray = self.bufferedMovies.count
    let noFilmsDownloading = self.numberOfDownloadingMovies
    let buffer: Int = lengthBufferedArray + noFilmsDownloading
    
    // Start additional downloads & present user with loading screen if needed
    if (buffer <= BUFFER_EMPTY) {
      // Present the loading card and wait until buffer reaches minimum count
      self.addMoviesToBufferedArray({ _ in })
    } else if buffer < MIN_BUFFER && !downloadingPageFromTMDB {
      self.addMoviesToBufferedArray({_ in })
    }
  }
  
  func addMoviesToBufferedArray(completionHandler: (finished: Bool) -> Void) {
    /* Start the download of a new page of tmdb discover data */
    print("adding movies to buffered array")
    // Get off main queue
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
      
      // Get search parameters
      self.getUsersLastSearch() {
        params in
      
        self.updateSearchParametersWithCorrectPageNo(params) {
          correctSearchParameters in
        
          // Download page of films
          self.getPageOfTMDBDiscoverData(correctSearchParameters){
            json in
            if let array = json["results"].array {
              var numResults = array.count
              // Check each film against previously seen films
              array.forEach({
                (movieJSON) in
                if let filmID = movieJSON["id"].int {
                  self.firebase.checkIdAgainstUsersHistory(filmID) {
                    (unseen) in
                    if unseen {
                    
                      // Download film assets
                      self.numberOfDownloadingMovies += 1
                      let _ = Movie(json: movieJSON, dataBaseDelegate: self) {
                        movie in
                      
                        // get back on main queue and add films to buffer
                        dispatch_async(dispatch_get_main_queue()) {
                          self.numberOfDownloadingMovies -= 1
                          numResults -= 1
                          self.bufferedMovies.append(movie)
                        
                          // let viewController know if all films are finished downloading
                          if (self.numberOfDownloadingMovies < 1) && (numResults == 0)  {
                            completionHandler(finished: true)
                          }
                        }
                      }
                    } else {  // already seen the film
                      numResults -= 1
                    }
                  }
                }
              })
            }
          }
        }
      }
    }
  }
  
  // MARK: - Movie Database API Interaction
  
  func initMovieFromID(id: Int, completionHandler: (Movie?) -> Void) {
    /* Download a movies assets for a given film id */
    
    // Construct URL
    let url = NSURL(string: "3/movie/\(id)", relativeToURL: self.BASEURL)!
    let urlParameters = [
      "api_key": "\(getAPIKey("tMDB"))",
      "append_to_response": "credits"
    ]
    
    // Download data - Create Movie Struct with json object
    network.downloadJSONFromURL(url, parameters: urlParameters) {
      json in
      if let json = json {
        let _ = Movie(json: json, dataBaseDelegate: self) {
          movieStruct in
          completionHandler(movieStruct)
        }
      }
    }
  }
  
  func getPageOfTMDBDiscoverData(searchParameters: [String: AnyObject], completionHandler: (JSON) -> Void) {
    /*  Download a page of data from tMDB Discover function */
    
    // Construct url
    let url = NSURL(string: "3/discover/movie", relativeToURL: self.BASEURL)!
    let urlParameters = parseSearchParametersDictForTMDB(searchParameters)
    
    // Download data
    network.downloadJSONFromURL(url, parameters: urlParameters) {
      json in
      if let json = json {
        completionHandler(json)
      }
    }
  }
  
  func parseSearchParametersDictForTMDB(fbSearchObject: [String: AnyObject]) -> [String: AnyObject] {
    /* Prepare search parameters for url encoding in a request to tmdb api  */
    var search = fbSearchObject
  
    // Fix vote_average.gte key
    if let vote_avg = search["vote_averageGTE"] {
      // vote avg key exists
      search.removeValueForKey("vote_averageGTE")
      search.updateValue(vote_avg, forKey: "vote_average.gte")
    }
  
    // Remove extranuous pairs
    search.removeValueForKey("no_params")
    search.removeValueForKey("timestamp")
  
    // Add API Key
    search.updateValue("\(getAPIKey("tMDB"))", forKey: "api_key")
  
    return search
  }
  
  func getMoviePoster(json: JSON, size: String, completionHandler: (UIImage?) -> Void) -> Void {
    /* Download movie poster from tmdb image api */
    if let path = json["poster_path"].string {
      let url = NSURL(string: "\(size)/\(path)", relativeToURL: self.BASEIMAGEURL)!
      self.network.downloadImageFromURL(url) {
        poster in
        completionHandler(poster)
      }
    }
  }
  
  // MARK: - Firebase Interaction
  

  
  
  func createSearchParametersDictForFirebase(sorting: Constants.Sorting, minVoteAvg: Float?, genre: Constants.Genre?, year: Int?) -> [String: AnyObject] {
    /* Build correct search parameters for a tmdb discover .GET request */
    
    // Required Parameters
    var search: [String: AnyObject] = [
      "page" : 0, // initialize page number but need to get correct value from firebase
      "sort_by" : sorting.rawValue
    ]
    
    // Optional Filters
    if (minVoteAvg != nil) { search.updateValue(minVoteAvg!, forKey: "vote_averageGTE") } // Could come up with a better solution in future
    if (genre != nil) { search.updateValue(genre!.rawValue, forKey: "with_genres") }
    if (year != nil) { search.updateValue(year!, forKey: "year") }
    
    // Add number of search parameters for specific firebase querying
    let lengthOfDict = search.count + 2
    search.updateValue(lengthOfDict, forKey: "no_params")
    
    return search
  }
  
  func updateSearchParametersWithCorrectPageNo(searchParameters: [String: AnyObject], completionHandler: ([String: AnyObject] -> Void)) {
    /* Before adding any additional search objects to a users firebase, check that they do not exist yet and update accordingly */
    
    // Create the path to users previous searches inside firebase
    if (FIRAuth.auth()?.currentUser) != nil {
      
      // Page no is the varibale from firebase we are interested in retrieving
      var params = searchParameters
      params.removeValueForKey("page")
      
      // Get search history from firebase
      firebase.getSearchFromFirebaseWithExactKeyValuePairs(params) {
        (optTuple) in
        if let searchTuple = optTuple {  // The search returned a result
          
          // Parse Firebase data
          let (search_uid, search) = searchTuple
          var searchDict = search
          
          // Increment results page number
          if let pageNo = searchDict["page"]{
            let page = pageNo as! Int + 1
            searchDict.updateValue(page, forKey: "page")
          }
          
          self.firebase.saveSearch(search_uid, searchParameters: searchDict)
          
          completionHandler(searchDict)
          
        } else {  // The search does not exist yet
          
          var searchDict = searchParameters
          searchDict.updateValue(1, forKey: "page")
          
          self.firebase.saveSearch(nil, searchParameters: searchDict)
          completionHandler(searchDict)
        }
      }
    }
  }
  
  
  // MARK: - Unfinished Work
  
  func initMostRecentSearchDataMember(completionHandler: ([String: AnyObject]?) -> Void ) -> Void {
    /* Getter method for recent search parameters data member */
    
    if self.usersMostRecentSearchParameters == nil {
      
      print("No search parameters where present, getting most recent from firebase")
      
      // download most recent search parameters from firebase
      firebase.getMostRecentSearch() {
        (searchParams) in
        if searchParams == nil {
          // create search
        }
        // This block of code is executed whenever the users searches update in firebase
        print("Got users most recent search parameters from firebase")
        self.usersMostRecentSearchParameters = searchParams
        completionHandler(searchParams)
      }
    }
  }
  
  func getUsersLastSearch(completionHandler: ([String: AnyObject]) -> Void ) {
    if let search = self.usersMostRecentSearchParameters {
      completionHandler(search)
    } else {
      self.initMostRecentSearchDataMember(){
        search in
        if search != nil {
          completionHandler(search!)
        } else {
          print("ERRORERROOROROROEOREREERO!")
        }
      }
    }
  }
}