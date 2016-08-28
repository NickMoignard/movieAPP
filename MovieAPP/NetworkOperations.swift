




/*
  MovieAPP
  NetworkOperations.swift
  Created by Nicholas Moignard on 27/7/16.
  
  Synopsis:
  Data Members:
  Mehtods:
  Developer Notes:
 
 */


import Foundation
import Alamofire
import SwiftyJSON
import UIKit


struct NetworkOperation {
  // Networking Class
  // Methods: 
  //    downloadJSONFromURL: retrieves json from a url .GET, has optional arg parameters
  //    downloadImageFromURL: retrieves a UIImage object from .GET at specified URL
  
  
  // MARK: - .GET HTTP REQUEST
  
  func downloadJSONFromURL(url: NSURL ,completionHandler: (JSON?) -> Void)    {

    Alamofire.request(.GET, url).validate().response {
      (_, _, data, _) in
      
      let jsonDictionary = JSON(data: data!)
      completionHandler(jsonDictionary)
    }
  }
  
  func downloadJSONFromURL(url: NSURL, parameters: [String: AnyObject] ,completionHandler: (JSON?) -> Void) {

    Alamofire.request(.GET, url, parameters: parameters).validate().response {
      (request, response, data, _) in
      
      let jsonDictionary = JSON(data: data!)
      completionHandler(jsonDictionary)
    }
  }
  
  func downloadImageFromURL(url: NSURL, completionHandler: (UIImage?) -> Void) {

    Alamofire.request(.GET, url).response() {
      (request, response, data, error) in
      
      let image = UIImage(data: data!)
      completionHandler(image)
    }
  }
  
}