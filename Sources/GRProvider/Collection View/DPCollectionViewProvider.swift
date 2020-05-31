//
//  GRCollectionViewProvider.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import DeepDiff
import UIKit

open class GRCollectionViewProvider<Section: Sectionable>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public typealias ItemProvider = (GRCollectionViewProvider, UICollectionView, IndexPath, Section.Item) -> UICollectionViewCell
    public typealias ItemSizeProvider = (GRCollectionViewProvider, UICollectionView, IndexPath, Section.Item) -> CGSize
    public typealias SupplementaryViewProvider = (GRCollectionViewProvider, UICollectionView, IndexPath, String) -> UICollectionReusableView
    public typealias SwipeGestureProvider = (GRCollectionViewProvider, UICollectionView, IndexPath, Section.Item) -> ([UIContextualAction])
    public typealias SectionInsetProvider = (GRCollectionViewProvider, UICollectionView, Section) -> UIEdgeInsets
    public typealias ItemSelectionProvider = (GRCollectionViewProvider, UICollectionView, Section.Item) -> ()
    public typealias MinLineSpacingProvider = (GRCollectionViewProvider, UICollectionView, Section) -> CGFloat
    
    public typealias ScrollProvider = (UIScrollView) -> ()
    public typealias DidEndDraggingProvider = (UIScrollView, Bool) -> ()
    public typealias WillEndDraggingProvider = (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> ()
    
    weak var collectionView: UICollectionView!
    
    ///Arrat of sections
    internal (set) public var sections: [Section] = []
    
    ///Configure cells based on the section item.
    open var configureCell: ItemProvider? = nil
    
    ///Returns Suplementary view for section
    open var configureSupplementaryElementOfKind: SupplementaryViewProvider? = nil
    
    ///Configure item size based on the cell section item
    open var configureCellSize: ItemSizeProvider? = nil {
        didSet {
            guard cellSize != nil else { return }
            assertionFailure("⚠️ *cellSize* property is already initialized. Property *itemSize* will be ignored and this closure will be used.")
        }
    }
    
    ///Configure sections insets based on the cell section item.
    open var configureSectionInsets: SectionInsetProvider? = nil {
        didSet {
            guard sectionInsets != nil else { return }
            assertionFailure("⚠️ *sectionInsets* property already initialized. Property *sectionInsets* will be ignored.")
        }
    }
    
    ///Configure min spacing for sections on the cell section item.
    open var configureMinLineSpacingForSection: MinLineSpacingProvider? = nil {
        didSet {
            guard minimumLineSpacingForSection != nil else { return }
            assertionFailure("⚠️ *sectionInsets* property already initialized. Property *sectionInsets* will be ignored.")
        }
    }
    
    ///Configure min spacing for sections on the cell section item.
    open var configureMinInteritemSpacingForSection: MinLineSpacingProvider? = nil {
        didSet {
            guard minInteritemSpacingForSection != nil else { return }
            assertionFailure("⚠️ *sectionInsets* property already initialized. Property *sectionInsets* will be ignored.")
        }
    }

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
    
    /// Variable representing item size for the row.
    open var cellSize: CGSize? {
        didSet {
            guard configureCell != nil else { return }
            assertionFailure("⚠️ *configureCell* is already assigned.")
        }
    }
    
    /// Variable representing sections instets for whole collection view
    open var sectionInsets: UIEdgeInsets? {
        didSet {
             guard configureSectionInsets != nil else { return }
            assertionFailure("⚠️ *configureSectionInsets* is already assigned. this property will be ignored.")
        }
    }
    
    /// Variable minimum line spacing of sections for whole collection view
    open var minimumLineSpacingForSection: CGFloat?
    {
        didSet {
             guard configureMinLineSpacingForSection != nil else { return }
            assertionFailure("⚠️ *configureMinLineSpacingForSection* is already assigned. this property will be ignored.")
        }
    }
    
    /// Variable minimum line spacing of sections for whole collection view
    open var minInteritemSpacingForSection: CGFloat?
    {
        didSet {
             guard configureMinInteritemSpacingForSection != nil else { return }
            assertionFailure("⚠️ *configureMinInteritemSpacingForSection* is already assigned. this property will be ignored.")
        }
    }
    
    public var count: Int {
        return sections.map { $0.items.count }.reduce(0, +)
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return configureCell?(self, collectionView, indexPath, sections[indexPath]) ?? UICollectionViewCell()
    }
        
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath]
        configureOnItemSelected?(self, collectionView, selectedItem)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return configureSectionInsets?(self, collectionView, sections[section]) ?? sectionInsets ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
        
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return configureCellSize?(self, collectionView, indexPath, sections[indexPath]) ?? cellSize ?? .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return configureMinLineSpacingForSection?(self, collectionView, sections[section]) ?? minimumLineSpacingForSection ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return configureMinInteritemSpacingForSection?(self, collectionView, sections[section]) ?? minInteritemSpacingForSection ?? 0
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
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return configureSupplementaryElementOfKind?(self, collectionView, indexPath, kind) ?? UICollectionReusableView(frame: .zero)
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
    public func bind(to collectionView: UICollectionView, sections: [Section], animated: Bool = true, onComplete: @escaping () -> () = {}) {
        self.collectionView = collectionView
        self.sections = sections
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        collectionView.reloadData(animated: animated) {
            onComplete()
        }
    }

}
