//
//  GRDiffableCollectionViewProvider.swift
//  GRProvider
//
//  Created by Marek Spalek on 23/10/2020.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
open class GRDiffableCollectionViewProvider<Section: Sectionable>: NSObject, UICollectionViewDelegate where Section: Hashable, Section.Item: Hashable {
    
    public typealias DataSource = UICollectionViewDiffableDataSource<Section, Section.Item>
    public typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>
    
    public typealias ItemProvider = (GRDiffableCollectionViewProvider, UICollectionView, IndexPath, Section.Item) -> UICollectionViewCell
    public typealias SupplementaryViewProvider = (GRDiffableCollectionViewProvider, UICollectionView, IndexPath, String) -> UICollectionReusableView
    public typealias SwipeGestureProvider = (GRDiffableCollectionViewProvider, UICollectionView, IndexPath, Section.Item) -> ([UIContextualAction])
    public typealias ItemSelectionProvider = (GRDiffableCollectionViewProvider, UICollectionView, IndexPath, Section.Item) -> ()
    
    public typealias ScrollProvider = (UIScrollView) -> ()
    public typealias DidEndDraggingProvider = (UIScrollView, Bool) -> ()
    public typealias WillEndDraggingProvider = (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> ()
    
    public init(collectionView: UICollectionView) {
        super.init()
        
        dataSource = DataSource(collectionView: collectionView) { [unowned self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            return self.configureCell?(self, collectionView, indexPath, item)
        }
        
        dataSource?.supplementaryViewProvider = { [unowned self] (collectionView, string, indexPath) -> UICollectionReusableView? in
            return self.configureSupplementaryElementOfKind?(self, collectionView, indexPath, string)
        }
    }
    
    ///Data source
    private(set) var dataSource: DataSource?
    
    ///Array of sections
    public var sections: [Section] {
        return dataSource?.snapshot().sectionIdentifiers ?? []
    }
    
    ///Configure cells based on the section item.
    open var configureCell: ItemProvider? = nil
    
    ///Returns Suplementary view for section
    open var configureSupplementaryElementOfKind: SupplementaryViewProvider? = nil

    ///Configure sections insets based on the cell section item
    open var configureDidScroll: ScrollProvider? = nil
    
    ///Configure on item selection action based on the selected item
    open var configureOnItemSelected: ItemSelectionProvider? = nil
        
    /// Closure calls when user scrolls in table view. It's closure of UIScrollViewDelegate method `scrollViewDidScroll`
    open var configureRefreshGesture: ScrollProvider? = nil
    
    /// Closure calls when `scrollViewDidEndDragging` fires up.
    open var configureDidEndDragging: DidEndDraggingProvider? = nil
    
    /// Closure calls when `scrollViewDidEndDragging` fires up.
    open var configureWillEndDragging: WillEndDraggingProvider? = nil
    
    public var count: Int {
        return sections.map { $0.items.count }.reduce(0, +)
    }
        
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath]
        configureOnItemSelected?(self, collectionView, indexPath, selectedItem)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Displayable {
            cell.willDisplayCell()
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Displayable {
            cell.didEndDisplayCell()
        }
    }
        
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureDidScroll?(scrollView)
    }
    
    // MARK: - Scroll View delegate

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        configureDidEndDragging?(scrollView, decelerate)
        
        if scrollView.refreshControl?.isRefreshing ?? false {
            configureRefreshGesture?(scrollView)
        }
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        configureWillEndDragging?(scrollView, velocity, targetContentOffset)
    }
    
    // MARK: - Binding
    
    /// Binds items to collection view with default reload animation
    public func bind(to collectionView: UICollectionView,
                     sections: [Section],
                     animated: Bool = true,
                     onComplete: @escaping () -> () = {}) {
        var snapshot = Snapshot()
                
        collectionView.delegate = self
        
        snapshot.appendSections(sections)
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: animated, completion: onComplete)
    }

}
