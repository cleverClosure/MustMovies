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
    
    var viewModel: RecommendationViewViewModel? {
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
        stack.isHidden = false
        stack.addArrangedSubview(heading)
        stack.addArrangedSubview(subHeading)
        return stack
    }()
    
    lazy fileprivate var menuStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.isHidden = true
        for status in WatchedStatus.allValues {
            let label = UILabel()
            label.font = UIFont.headingFont()
            label.textColor = .gray
            label.text = status.rawValue
            stack.addArrangedSubview(label)
        }
        return stack
    }()
    
    var cellSize: CGSize {
        let width = view.frame.width / 1.5
        let size = CGSize(width: width, height: width * 1.5)
        return size
    }
    
    var sectionInset: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 25, bottom: 10, right: view.frame.width - cellSize.width - minimumLineSpacing)
    }
    
    var minimumLineSpacing: CGFloat = 22
    
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
    var shouldRecognizeSimultaneously = true

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
        view.addSubview(menuStack)
        view.backgroundColor = .white
        layoutViews()
    }
   
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    fileprivate func layoutViews() {
        collectionView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview()
        }
        headingStack.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(collectionView.snp.top).offset(-10)
            maker.leading.equalToSuperview().offset(22)
        }
        
        menuStack.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(22)
            maker.top.equalTo(headingStack)
        }
    }
    
    
    fileprivate func fetchMovies() {
        let movies = [Movie(posterFilename:"bladerunner",subtitle:"Based on your rate for interstellar", watchedStatus: nil),
                      Movie(posterFilename:"t2",subtitle:"Based on novel", watchedStatus: nil),
                      Movie(posterFilename:"thedouble",subtitle:"Based on your preferences", watchedStatus: nil),
                      Movie(posterFilename:"thedouble",subtitle:"Based on your preferences", watchedStatus: nil),
                      Movie(posterFilename:"thedouble",subtitle:"Based on your preferences", watchedStatus: nil)]
        viewModel = RecommendationViewViewModel(recommendations: movies)
    }

}

extension RecommendationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / 1.5
        return CGSize(width: width, height: width * 1.5)
    }
    
}

extension RecommendationViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.visibleCells.forEach {
            $0.gestureRecognizers?[0].isEnabled = false
        }
        let cell = collectionView.cellForItem(at: IndexPath(item: currentCellIndex, section: 0))
        cell?.gestureRecognizers?[0].isEnabled = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        
        let layout = self.collectionViewLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        
        let roundedIndex = round(index)
        
        currentCellIndex = Int(roundedIndex)
        print("#### \(currentCellIndex)")
        
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
    func hideHeading() {
        headingStack.isHidden = true
        menuStack.isHidden = false
    }
    
    func showHeading() {
        headingStack.isHidden = false
        menuStack.isHidden = true
    }
}

extension RecommendationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberOfRecommendations()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendationMovieCell.ID, for: indexPath) as! RecommendationMovieCell
        cell.subtitleLabel.text = viewModel!.recommedationSubtitle(for: indexPath.item)
        cell.poster.image = UIImage(named: viewModel!.recommedationPosterFilename(for: indexPath.item)!)
        if cell.gestureRecognizers == nil || cell.gestureRecognizers!.count == 0 {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
            pan.delegate = self
            pan.isEnabled = indexPath.item == 0 ? true : false
            pan.name = "pan"
            cell.addGestureRecognizer(pan)
        }
        
        
        return cell
    }
}

extension RecommendationViewController {

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
    
        switch recognizer.state {
        case .began:
            shouldRecognizeSimultaneously = false
            cellCenter = recognizer.view!.center
        case .changed:
            
            let translation = recognizer.translation(in: self.view)
            if let view = recognizer.view {
                var changeY = view.center.y + translation.y
                var diffY = changeY - cellCenter!.y
                
                if diffY > view.frame.height * 0.4 || diffY <= 0{
                    changeY = view.center.y
                    diffY = view.center.y - cellCenter!.y
                }
                view.center = CGPoint(x:view.center.x,
                                      y:changeY)
                
                menuChange(diffY: diffY)
            }
            
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        case .ended:
            shouldRecognizeSimultaneously = true
            showHeading()
            headingStack.snp.updateConstraints { (make) in
                make.bottom.equalTo(collectionView.snp.top).offset(-10)
            }
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { [unowned self] in
                recognizer.view!.center = self.cellCenter ?? CGPoint.zero
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        default:
            print("default")
        }
    }
    
    func menuChange(diffY: CGFloat) {
        let maxVal = collectionViewLayout.itemSize.height * 0.4
        let percentage = diffY / maxVal
        if percentage >= 0.2 {
            hideHeading()
        }
        if percentage < 0.2 {
            showHeading()
        }
        switch percentage {
        case 0...0.2:
            headingStack.snp.updateConstraints { (make) in
                make.bottom.equalTo(collectionView.snp.top).offset(-10 + (100 * percentage))
            }
        default:
            var index = Int(round((percentage / (CGFloat(WatchedStatus.allValues.count) / CGFloat(10))))) - 1
            index = max(index, 0)
            index = min(index, menuStack.arrangedSubviews.count)
            chooseMovieStatus(index: index)
        }
    }
    
    func chooseMovieStatus(index: Int) {
        (menuStack.arrangedSubviews as! [UILabel]).forEach {
            $0.textColor = .gray
        }
        (menuStack.arrangedSubviews[index] as! UILabel).textColor = .black
    }
    
}

extension RecommendationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
