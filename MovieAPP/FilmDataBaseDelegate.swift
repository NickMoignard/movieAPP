//
//  FilmDataBaseDelegate.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 27/7/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

protocol FilmDataBaseDelegate {
  func getMoviePoster(json: JSON, size: String,completionHandler: (UIImage?) -> Void) -> Void
  
}