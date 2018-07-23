
//
//  File.swift
//  MustMovies
//
//  Created by Tim on 23.07.2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit


struct Movie {
    var posterFilename: String
    var subtitle: String
    var watchedStatus: WatchedStatus? = nil
}

enum WatchedStatus: String {
    case want = "Want"
    case watched = "Watched"
    case disliked = "Don't like this"
    static let allValues = [want, watched, disliked]
}
