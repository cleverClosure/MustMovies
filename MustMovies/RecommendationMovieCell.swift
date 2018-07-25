//
//  RecommendationMovieCell.swift
//  MustMovies
//
//  Created by Tim on 23.07.2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import SnapKit

class RecommendationMovieCell: UICollectionViewCell {
    
    static let ID = "RecommendationMovieCellID"
    
    var innerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var poster: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "thedouble")
        view.layer.cornerRadius = self.frame.width / 50
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtitle"
        label.font = UIFont.subTitleFont()
        label.numberOfLines = 2
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(innerView)
        innerView.addSubview(poster)
        innerView.addSubview(subtitleLabel)
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func layoutViews() {
        innerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
        }
        poster.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
    }
    
}
