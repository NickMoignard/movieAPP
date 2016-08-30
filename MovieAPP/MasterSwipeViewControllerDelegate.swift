/*
 MasterSwipeViewControllerDelegate.swift
 MovieAPP
 
 Created by Nicholas Moignard on 24/8/16.

 Synopsis:
 Data Members:
 Mehtods:
 Developer Notes:
 
 */
import Foundation

protocol MasterSwipeViewControllerDelegate {
  func loadFilmCards() -> Void
  func cardSwipedRight() -> Void
  func cardSwipedLeft() -> Void
  func showDetail() -> Void
  
//  func cardFinishedAnimatingOut() -> Void
}