//
//  ViewController.swift
//  MustMovies
//
//  Created by Tim on 23.07.2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import SnapKit

class RecommendationViewController: UIViewController {
    
    var movies: [Movie]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var heading: UILabel = {
        let label = UILabel()
        label.text = "Movies"
        label.textColor = .black
        label.font = UIFont.headingFont()
        return label
    }()
    
    var subHeading: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.headingFont()
        label.text = "Next to watch"
        return label
    }()
    
    lazy fileprivate var headingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.isHidden = false
        stack.addArrangedSubview(heading)
        stack.addArrangedSubview(subHeading)
        return stack
    }()
    
    lazy fileprivate var menu: PosterMenu = {
        let items = WatchedStatus.allValues.map {$0.rawValue}
        let menu = PosterMenu(items: items)
        menu.isHidden = true
        return menu
    }()
    
    var cellSize: CGSize {
        let width = view.frame.width / 1.5
        let size = CGSize(width: width, height: width * 1.5)
        return size
    }
    
    var sectionInset: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 0, right: view.frame.width - cellSize.width - minimumLineSpacing)
    }
    
    var minimumLineSpacing: CGFloat = 20
    
    lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = minimumLineSpacing
        layout.sectionInset = sectionInset
        layout.itemSize = cellSize
        return layout
    }()
    
    var currentCellIndex: Int = 0
    
    var cellCenter: CGPoint?
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .white
        collectionView.layer.masksToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMovies()
        view.addSubview(collectionView)
        collectionView.register(RecommendationMovieCell.self, forCellWithReuseIdentifier: RecommendationMovieCell.ID)
        view.addSubview(headingStack)
        view.addSubview(menu)
        view.backgroundColor = .white
        layoutViews()
    }
    
    fileprivate func layoutViews() {
        collectionView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(collectionView.snp.width)
            make.centerY.equalToSuperview()
        }
        headingStack.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(collectionView.snp.top).offset(Constants.headingStackOffset)
            maker.leading.equalToSuperview().offset(Constants.leftEdgeOffset)
        }
        
        menu.snp.makeConstraints { (maker) in
            maker.leading.equalTo(headingStack)
            maker.top.equalTo(headingStack)
        }
    }
    
    fileprivate func fetchMovies() {
        let movies = [Movie(posterFilename:"bladerunner",subtitle:"Based on your rate for interstellar", watchedStatus: nil),
                      Movie(posterFilename:"t2",subtitle:"Based on novel", watchedStatus: nil),
                      Movie(posterFilename:"thedouble",subtitle:"Based on your preferences", watchedStatus: nil),
                      Movie(posterFilename:"thedouble",subtitle:"Based on your preferences", watchedStatus: nil),
                      ]
        self.movies = movies
    }

}

extension RecommendationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 1.5
        return CGSize(width: width, height: width * 1.5)
    }
    
}

extension RecommendationViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.visibleCells.forEach {
            $0.gestureRecognizers?.filter { type(of: $0) == UIPanGestureRecognizer.self }.first?.isEnabled = false
        }
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCellIndex, section: 0))
        cell?.gestureRecognizers?.filter { type(of: $0) == UIPanGestureRecognizer.self }.first?.isEnabled = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let layout = self.collectionViewLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing

        let roundedIndex = round(index)

        currentCellIndex = Int(roundedIndex)

        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
    func hideHeading() {
        headingStack.isHidden = true
        menu.isHidden = false
    }
    
    func showHeading() {
        headingStack.isHidden = false
        menu.isHidden = true
    }
}

extension RecommendationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let movies = movies else { return 0 }
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationMovieCell.ID, for: indexPath) as! RecommendationMovieCell
        if let movies = movies {
            let movie = movies[indexPath.item]
            cell.subtitleLabel.text = movie.subtitle
            let filename = movie.posterFilename
            cell.poster.image = UIImage(named: filename)
            
            if cell.gestureRecognizers == nil || cell.gestureRecognizers!.count == 0 {
                let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
                pan.delegate = self
                pan.isEnabled = indexPath.item == 0 ? true : false
                cell.addGestureRecognizer(pan)
            }
        }
        
        return cell
    }
}

extension RecommendationViewController {

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        guard let posterCell = recognizer.view else {
            return
        }
        switch recognizer.state {
        case .began:
            cellCenter = recognizer.view?.center
        case .changed:
            let translation = recognizer.translation(in: self.view)
            if let view = recognizer.view {
                var changeY = posterCell.center.y + translation.y
                var diffY = changeY - cellCenter!.y
                
                if diffY > posterCell.frame.height * Constants.panRangeMultiplier || diffY <= 0 {
                    changeY = posterCell.center.y
                    diffY = posterCell.center.y - cellCenter!.y
                }
                view.center = CGPoint(x:posterCell.center.x, y:changeY)
                menuChange(diffY: diffY)
            }
            
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        case .ended:
            showHeading()
            animateHeadingUp()
            animatePosterUp(view: posterCell)
        default:
            print("default")
        }
    }
    
    func animateHeadingUp() {
        
        animate {
            self.headingStack.snp.updateConstraints { (make) in
                make.bottom.equalTo(self.collectionView.snp.top).offset(Constants.headingStackOffset)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func animatePosterUp(view: UIView) {
        animate {
            view.center = self.cellCenter ?? CGPoint.zero
        }
    }
    
    func animate(animations: @escaping ()->()) {
        let animation = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.7) {
            animations()
        }
        animation.startAnimation()
    }
    
    func menuChange(diffY: CGFloat) {
        let threshold: CGFloat = 0.38
        let maxVal = collectionViewLayout.itemSize.height * Constants.panRangeMultiplier
        
        let percentage = diffY / maxVal
        if percentage >= threshold {
            hideHeading()
        }
        if percentage < threshold {
            showHeading()
        }
        switch percentage {
        case 0...threshold:
            headingStack.snp.updateConstraints { (make) in
                make.bottom.equalTo(collectionView.snp.top).offset(Constants.headingStackOffset + (100 * percentage))
            }
        default:
            var index = Int(round((percentage / CGFloat(WatchedStatus.allValues.count)) * CGFloat(10))) - 1
            index = max(index, 0)
            index = min(index, menu.items.count)
            menu.chooseItem(at: index)
        }
    }
    

    
}

extension RecommendationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: self.view)
            if fabs(translation.y) > fabs(translation.x) {
                return true
            }
            return false
        }
        return false
    }
}

