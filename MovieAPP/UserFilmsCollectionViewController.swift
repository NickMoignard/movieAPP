//
//  UserFilmsCollectionViewController.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 25/9/16.
//  Copyright © 2016 Elena. All rights reserved.
//


/*
  get list of users films from firebase
  
  array of tuples? [(string, image?)]
 
  download posters
*/


import UIKit
import Firebase

class UserFilmsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  let firebase = FirebaseService()
  let tMDB = TMDBService()
  
  let itemsPerRow: CGFloat = 3
  let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)  // margins
  
  var array = [String](),
      posterArray = [UIImage](),
      movieArray = [Movie]()
    
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    someName()
    
    

  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.movieArray.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("poster", forIndexPath: indexPath) as UICollectionViewCell
    
    let label = cell.viewWithTag(1) as! UILabel,
        imageView = cell.viewWithTag(2) as! UIImageView
    label.text = self.movieArray[indexPath.row].title!
    imageView.image = self.movieArray[indexPath.row].poster!
    
    
    return cell
  }
  
  func someName() {
    firebase.getUsersFilms(){
      dict in
      
      dict.forEach({
        (_, review) in
        
        let revDict = review as! [String: AnyObject]
        
        self.tMDB.getMoviePoster(revDict["poster_path"] as! String, size: "w154") {
          poster in
          if let image = poster {
            self.movieArray.append(Movie(delegate: self.tMDB, title: revDict["title"] as? String, releaseDate: nil, director: nil, poster: image, jsonData: nil, id: nil))
            self.collectionView?.reloadData()
          } else {
            print("could not download poster")
          }
        }
      })
    }
  }
  
  // MARK: - Image layout
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return sectionInsets.left
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    /* determine size for each cell */
    
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1),
        availableWidth = view.frame.width - paddingSpace,
        widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem * 1.65)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  
  
  
  
  
  
  
  
  
  
}
