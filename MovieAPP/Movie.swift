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
  var title: String?, releaseDate: String?, poster: UIImage? = nil, jsonData: JSON
  var hasPoster: Bool? = nil
  var delegate: FilmDataBaseDelegate
  
  init(json: JSON, dataBaseDelegate: FilmDataBaseDelegate, completionHandler: (Movie) -> Void ) {

    title = json["title"].string
    releaseDate = json["release_date"].string
    jsonData = json
    delegate = dataBaseDelegate
    
    delegate.getMoviePoster(json, size: "w150") {
      poster in
      self.poster = poster
      completionHandler(self)
    }
    
  }
}