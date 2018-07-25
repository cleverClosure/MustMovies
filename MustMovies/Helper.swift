//
//  Helper.swift
//  MustMovies
//
//  Created by Tim on 23.07.2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

extension UIFont {
    static func headingFont() -> UIFont {
        return UIFont(name: "SFProDisplay-Bold", size: 27) ?? UIFont.systemFont(ofSize: 27, weight: UIFont.Weight.bold)
    }
    static func subTitleFont() -> UIFont {
        return UIFont(name: "SFProDisplay-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold)
    }
}


enum Constants {
    static let headingStackOffset: CGFloat = -12
    static let leftEdgeOffset: CGFloat = 25
    static let panRangeMultiplier: CGFloat = 0.45
}
