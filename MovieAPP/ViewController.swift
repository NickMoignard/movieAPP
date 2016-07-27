//
//  ViewController.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 27/7/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  let tmdb = TMDBService()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tmdb.initFilmFromID(550) {
      movie in
      print("never got here")
      print("\(movie)")
    }
    
  }
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

