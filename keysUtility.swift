//
//  keysUtility.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 27/7/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import Foundation

func getAPIKey(serviceName: String) -> String {
    // get a service key from the api keys plist
  
    let filePath = NSBundle.mainBundle().pathForResource("keys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile: filePath!)
    let value: String = plist?.valueForKey("tMDB") as! String
  
    return value
}
