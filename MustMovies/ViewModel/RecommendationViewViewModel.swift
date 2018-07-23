//
//  RecommendationViewModel.swift
//  MustMovies
//
//  Created by Tim on 23.07.2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation

struct RecommendationViewViewModel {
    var recommendations: [Movie]?
    
    func numberOfRecommendations() -> Int {
        return recommendations?.count ?? 0
    }
    
    func recommedationSubtitle(for index: Int) -> String? {
        return recommendations?[index].subtitle
    }
    
    func recommedationPosterFilename(for index: Int) -> String? {
        return recommendations?[index].posterFilename
    }
}
