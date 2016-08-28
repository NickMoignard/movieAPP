
/*
 MovieAPP
 FilmDataBaseDelegate.swift
 Created by Nicholas Moignard on 27/7/16.
 
 Synopsis:
 Data Members:
 Mehtods:
 Developer Notes:
 
 */

import Foundation
import UIKit
import SwiftyJSON

protocol FilmDataBaseDelegate {
  func getMoviePoster(json: JSON, size: String,completionHandler: (UIImage?) -> Void) -> Void
  
}