//
//  PosterMenu.swift
//  MustMovies
//
//  Created by Tim on 25.07.2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import SnapKit


class PosterMenu: UIView {
    
    var items: [String]
    
    lazy fileprivate var menuStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        for status in self.items {
            let label = UILabel()
            label.font = UIFont.headingFont()
            label.textColor = .gray
            label.text = status
            stack.addArrangedSubview(label)
        }
        return stack
    }()
    
    init(items: [String]) {
        self.items = items
        super.init(frame: CGRect.zero)
        self.layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func layoutViews() {
        addSubview(menuStack)
        menuStack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func chooseItem(at index: Int) {
        guard 0..<items.count ~= index  else {
            return
        }
        menuStack.arrangedSubviews.forEach {
            let label = ($0 as? UILabel)
            label?.textColor = .gray
        }
        let labelToHighlight = (menuStack.arrangedSubviews[index] as? UILabel)
        labelToHighlight?.textColor = .black
    }
}

