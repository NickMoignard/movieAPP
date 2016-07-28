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
      getImage(path: String, size: String = "default size", completionHandler: (UIImage?) -> Void)
      initFilmFromID(id: Int, completionHandler: (Movie?) -> Void)
      func getMoviePoster(id: String) -> Void
*/


import Foundation
import UIKit
import SwiftyJSON
import Alamofire

struct TMDBService: FilmDataBaseDelegate {
  
  let baseURL = NSURL(string: "https://api.themoviedb.org")!
  let baseImageURL = NSURL(string: "https://image.tmdb.org/t/p/")!
  let api = NetworkOperation()
  
  func initFilmFromID(id: Int, completionHandler: (Movie?) -> Void) {
    // create a movie struct from the given film id
    let url = NSURL(string: "3/movie/\(id)", relativeToURL: self.baseURL)!
    let urlParameters = [
      "api_key": "\(getAPIKey("tMDB"))",
      "append_to_response": "credits"
    ]
    api.downloadJSONFromURL(url, parameters: urlParameters) {
      // Initialize Movie Struct from JSON
      json in
      if let json = json {
        let _ = Movie(json: json, dataBaseDelegate: self) {
          movieStruct in
          // the Movie.init() has a callback that returns itself after a poster has been downloaded and added to the struct
          completionHandler(movieStruct)
        }
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
}