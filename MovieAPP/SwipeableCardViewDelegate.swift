//
//  SwipeableCardViewDelegate.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 28/7/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import Foundation

protocol SwipeableCardViewDelegate { 
  func cardSwipedRight(card: SwipeableCardView) -> Void
  func cardSwipedLeft(card: SwipeableCardView) -> Void
  func showDetail(card: SwipeableCardView) -> Void
}
