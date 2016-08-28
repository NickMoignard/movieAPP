
/*
 MovieAPP
 Constants.swift
 Created by Nicholas Moignard on 27/7/16.
 
 Synopsis:
  File for storing global constants as to clean up the code base
 
 Data Members:
 Mehtods:
 Developer Notes:
 
 */

import Foundation

struct Constants {
  
  
  enum Sorting: String {
    case PopularityAsc = "popularity.asc"
    case PopularityDesc = "popularity.desc"
    case ReleaseDateAsc = "release_date.asc"
    case RevenueAsc = "revenue.asc"
    case RevenueDesc = "revenue.desc"
    case PrimaryReleaseDateAsc = "primary_release_date.asc"
    case PrimaryReleaseDateDesc = "primary_release_date.desc"
    case OriginalTitleAsc = "original_title.asc"
    case OriginalTitleDesc = "original_title.desc"
    case VoteAverageAsc = "vote_average.asc"
    case VoteAverageDesc = "vote_average.desc"
    case VoteCountAsc = "vote_count.asc"
    case VoteCountDesc = "vote_count.desc"
  }
  
  enum Genre: Int {
    case Action = 28
    case Adventure = 12
    case Animation = 16
    case Comedy = 35
    case Crime = 80
    case Documentary = 99
    case Drama = 18
    case Family = 10751
    case Fantasy = 14
    case Foreign = 10769
    case History = 36
    case Horror = 27
    case Music = 10402
    case Mystery = 9648
    case Romance = 10749
    case ScienceFiction = 878
    case TVMovie = 10770
    case Thriller = 53
    case War = 10752
    case Western = 37
  }
  
}


