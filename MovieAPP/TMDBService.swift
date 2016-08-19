/* TMDBService.swift
   MovieAPP
 
   Created by Nicholas Moignard on 27/7/16.
   Copyright © 2016 Elena. All rights reserved.
 
  Synopsis:
      class to interact with the film data base api
  
   Data members:
      baseURL
      baseImageURL
  
   Methods:
      getImage(path: String, size: String = "default size", completionHandler: (UIImage?) -> Void) -> Void
      initFilmFromID(id: Int, completionHandler: (Movie?) -> Void) -> Void
      getMoviePoster(id: String) -> Void
      getPageOfTMDBDiscoverData(searchParameters: [String: AnyObject], completionHandler: (JSON) -> Void) -> Void
 
 
 
 
 
    Future Updates:
 
*/


import Foundation
import Firebase
import UIKit
import SwiftyJSON
import Alamofire

enum Sorting: String {
  case PopularityAsc = "popularity.asc"
  case PopularityDesc = "popularity.desc"
  case ReleaseDateAsc = "release_date.asc"
  case RevenueAsc = "revenue.asc"
  case RevenueDesc = "revenue.desc"
  case PrimaryReleaseDateAsc = "primary_release_date.asc"
  case PrimaryReleaseDateDesc = "primary_release_date.desc"
  case OriginalTitleAsc = "original_title.asc"
  case OriginalTitleDesc = "original_title.desc"
  case VoteAverageAsc = "vote_average.asc"
  case VoteAverageDesc = "vote_average.desc"
  case VoteCountAsc = "vote_count.asc"
  case VoteCountDesc = "vote_count.desc"
}

enum Genre: Int {
  case Action = 28
  case Adventure = 12
  case Animation = 16
  case Comedy = 35
  case Crime = 80
  case Documentary = 99
  case Drama = 18
  case Family = 10751
  case Fantasy = 14
  case Foreign = 10769
  case History = 36
  case Horror = 27
  case Music = 10402
  case Mystery = 9648
  case Romance = 10749
  case ScienceFiction = 878
  case TVMovie = 10770
  case Thriller = 53
  case War = 10752
  case Western = 37
}

struct TMDBService: FilmDataBaseDelegate {
  let MIN_BUFFER: Int = 10
  let BUFFER_EMPTY: Int = 1
  let baseURL = NSURL(string: "https://api.themoviedb.org")!
  let baseImageURL = NSURL(string: "https://image.tmdb.org/t/p/")!
  let api = NetworkOperation()
  let firebase = FirebaseService()
  
  var downloadingPageFromTMDB: Bool = false
  var numberOfDownloadingMovies: Int = 0
  var bufferedMovies = [Movie]()
  var searchParameters: [String: AnyObject]? = nil
  
  init() {
    print("init call from tmdbservice")
    firebase.getMostRecentSearch() {
      (searchDict) in
      // This completionHandler will get executed everytime the user saves a new search
      print("\nhopefully i see this line 2wice\n")
      self.searchParameters = searchDict
    }
  }

  
  func initFilmFromID(id: Int, completionHandler: (Movie?) -> Void) {
    /* Download a movies assets for a given film id */
    
    // Construct URL
    let url = NSURL(string: "3/movie/\(id)", relativeToURL: self.baseURL)!
    let urlParameters = [
      "api_key": "\(getAPIKey("tMDB"))",
      "append_to_response": "credits"
    ]
    
    // Download data - Create Movie Struct with json object
    api.downloadJSONFromURL(url, parameters: urlParameters) {
      json in
      if let json = json {
        let _ = Movie(json: json, dataBaseDelegate: self) {
          movieStruct in
          completionHandler(movieStruct)
        }
      }
    }
  }
  
  func createSearchParametersDictForFirebase(sorting: Sorting, minVoteAvg: Float?, genre: Genre?, year: Int?) -> [String: AnyObject] {
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
  
  
  func getPageOfTMDBDiscoverData(searchParameters: [String: AnyObject], completionHandler: (JSON) -> Void) {
    /*  Download a page of data from tMDB Discover function */
    
    // Construct url
    let url = NSURL(string: "3/discover/movie", relativeToURL: self.baseURL)!
    let urlParameters = parseSearchParametersDictForTMDB(searchParameters)
    
    // Download data
    api.downloadJSONFromURL(url, parameters: urlParameters) {
      json in
      if let json = json {
        completionHandler(json)
      }
    }
  }

  func getMoviePoster(json: JSON, size: String, completionHandler: (UIImage?) -> Void) -> Void {
    if let path = json["poster_path"].string {
      let url = NSURL(string: "\(size)/\(path)", relativeToURL: self.baseImageURL)!
      self.api.downloadImageFromURL(url) {
        poster in
        completionHandler(poster)
      }
    }
  }
  
  func updateSearchParametersWithCorrectPageNo(searchParameters: [String: AnyObject], completionHandler: ([String: AnyObject] -> Void)) {
    /* Before adding any additional search objects to a users firebase, check that they do not exist yet and update accordingly */
    
    // Create the path to users previous searches inside firebase
    if let user = FIRAuth.auth()?.currentUser {
      
      let userID = user.uid
      let path = "searches/\(userID)"
      
      // Page no is the varibale from firebase we are interested in retrieving
      var params = searchParameters
      params.removeValueForKey("page")
      
      // Get search history from firebase
      firebase.getSearchFromFirebaseWithExactKeyValuePairs(path, dictionary: params) {
        (optTuple) in
        if let searchTuple = optTuple {  // The search returned a result
          
          // Parse Firebase data
          let (search_uid, search) = searchTuple
          var searchDict = search
          
          print(searchDict)
          
          // Increment results page number
          if let pageNo = searchDict["page"]{
            let page = pageNo as! Int + 1
            searchDict.updateValue(page, forKey: "page")
          }
          
          self.firebase._saveSearch(search_uid, searchParameters: searchDict)
          
          completionHandler(searchDict)
          
        } else {  // The search does not exist yet
          
          var searchDict = searchParameters
          searchDict.updateValue(1, forKey: "page")
          
          self.firebase._saveSearch(nil, searchParameters: searchDict)
          completionHandler(searchDict)
        }
      }
    }
  }
  
  
//    mutating func addMoviesToBufferedArray() {
//      // start download of a new page of tmdb discover data and add this to buffered films array
//      let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
//      dispatch_async(dispatch_get_global_queue(priority, 0)) {
//        self.getSearchParameters(nil) {
//          searchParams in
//          self.getPageOfTMDBDiscoverData(searchParams) {
//            json in
//            if let array = json["results"].array {
//              let unseenFilmsJSONArray = array.filter() {
//                movieJSON in
//                if let filmID = movieJSON["id"].int {
//                  return self.firebase.checkIdAgainstUsersHistory(filmID)
//                } else {
//                  return false
//                }
//              }
//  
//              self.numberOfDownloadingMovies = unseenFilmsJSONArray.count
//  
//              unseenFilmsJSONArray.forEach() {
//                jsonFilm in
//                let _ = Movie(json: jsonFilm, dataBaseDelegate: self) {
//                  movie in
//                  self.numberOfDownloadingMovies -= 1
//                  self.bufferedMovies.append(movie)
//                }
//              }
//            }
//          }
//        }
//      }
//    }
  
  
//  mutating func checkBufferedMovies() {
//    // maintain the movies buffer
//    let lengthBufferedArray: Int = 0
//    let noFilmsDownloading: Int = 0
//    let buffer: Int = lengthBufferedArray + noFilmsDownloading
//    
//    if (buffer <= BUFFER_EMPTY) {
//      // Present the loading card and wait until buffer reaches minimum count
//      self.addMoviesToBufferedArray()
//      
//    } else if buffer < MIN_BUFFER && !downloadingPageFromTMDB {
//      self.addMoviesToBufferedArray()
//    }
//  }
  
//  mutating func getNextFilmInBuffer() -> Movie? {
//    // Get first element from the Movie Struct Array
//    checkBufferedMovies()
//    return bufferedMovies.removeFirst()
//  }
  

}