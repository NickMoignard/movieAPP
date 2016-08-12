//
//  Movie.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 27/7/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

struct Movie {
  var title: String?, releaseDate: String?, director: String?, poster: UIImage? = nil, jsonData: JSON
  var hasPoster: Bool? = nil
  var delegate: FilmDataBaseDelegate
  
  init(json: JSON, dataBaseDelegate: FilmDataBaseDelegate, completionHandler: (Movie) -> Void ) {

    title = json["title"].string
    releaseDate = json["release_date"].string
    jsonData = json
    
    // Get directors name from credits
    if let crew_list = json["credits"]["crew"].array {
      for i in 0...crew_list.count - 1 {
        if let job = crew_list[i]["job"].string {
          if job == "Director" {
            if let film_director = crew_list[i]["name"].string {
              self.director = film_director
            }
          }
        }
      }
    }
    
    
    
    delegate = dataBaseDelegate
    delegate.getMoviePoster(json, size: "w300") {
        poster in
        self.poster = poster
        completionHandler(self)
    }
    
  }
}