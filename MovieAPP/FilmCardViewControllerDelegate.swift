//
//  FilmCardViewControllerDelegate.swift
//  MovieAPP
//
//  Created by Nicholas Moignard on 1/9/16.
//  Copyright © 2016 Elena. All rights reserved.
//

import Foundation

protocol FilmCardViewControllerDelegate {
  func updateOverlay(distance: CGPoint, actionMargin: CGFloat) -> Void
  func resetOverlayAlpha() -> Void
}