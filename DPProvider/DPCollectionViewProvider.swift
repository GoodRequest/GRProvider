//
//  DPCollectionViewProvider.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import DeepDiff
import UIKit

public final class DPCollectionViewProvider<Section>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public typealias CellFactory = (UICollectionView, IndexPath, Section) -> UICollectionViewCell
    public typealias CellSizeFactory = (UICollectionView, IndexPath, Section) -> CGSize
    public typealias ScrollFactory = (UIScrollView) -> ()
    public typealias SwipeGestureFactory = (UICollectionView, IndexPath, Section) -> ([UIContextualAction])
    public typealias ItemSelectionFactory = (UICollectionView, Section) -> ()
        
    var sections: [Section] = []
    fileprivate weak var collectionView: UICollectionView!
    
    public var configureCell: CellFactory? = nil
    public var configureDidScroll: ScrollFactory? = nil
    public var configureOnItemSelected: ItemSelectionFactory? = nil
    public var configureTrailingSwipeGesture: SwipeGestureFactory? = nil
    public var configureRefreshGesture: ScrollFactory? = nil
    public var configureItemSize: CellSizeFactory? = nil
    public var sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    public var minimumLineSpacingForSection: CGFloat = 0
    
    var count: Int {
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return configureCell?(collectionView, indexPath, sections[indexPath.row]) ?? UICollectionViewCell()
    }
        
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath.row]
        configureOnItemSelected?(collectionView, selectedItem)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return configureItemSize?(collectionView, indexPath, sections[indexPath.row]) ?? CGSize(width: collectionView.bounds.width, height: 170)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacingForSection
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Displayable {
            cell.willDispayCell()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureDidScroll?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.refreshControl?.isRefreshing ?? false {
            configureRefreshGesture?(scrollView)
        }
    }
    
}

extension UICollectionView {
    
    func items<Item>(_ dataSource: DPCollectionViewProvider<Item>, items: [Item], animated: Bool = true, completion: @escaping () -> () = {}) {
        dataSource.collectionView = self
        dataSource.sections = items
        self.dataSource = dataSource
        self.delegate = dataSource
        
        reloadData(animated: animated) {
            completion()
        }
    }
    
    private func reloadData(animated: Bool = false, completion: @escaping () -> ()) {
        UIView.transition(with: self, duration: animated ? 0.5 : 0.0, options: .transitionCrossDissolve, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    public func items<Section>(_ dataSource: DPCollectionViewProvider<Section>,
                                sections: [Section],
                                onComplete: @escaping () -> () = {}) where Section: Sectionable, Section.Item: DiffAware {
        dataSource.collectionView = self
        self.dataSource = dataSource
        self.delegate = dataSource
        
        guard !dataSource.sections.isEmpty else {
            dataSource.sections = sections
            reloadData(animated: true) { onComplete() }
            return
        }
        
        var allChanges: [[Change<Section.Item>]] = []
        var allSections: [Int] = []
        
        for (index, section) in sections.enumerated() {
            
            let oldItems = dataSource.sections[safe: index]?.items ?? []
            let changes = diff(old: oldItems, new: section.items)
                        
            if !changes.isEmpty {
                allChanges.append(changes)
                allSections.append(index)
            }
        }
        self.reload(changes: allChanges, sections: allSections, updateData: {
            dataSource.sections = sections
        }) { (_) in
           onComplete()
        }
    }
    
}

extension UICollectionView {
    
    private func reload<T: DiffAware>(
      changes: [[Change<T>]],
      sections: [Int],
      updateData: () -> Void,
      completion: ((Bool) -> Void)? = nil) {
        
        let changessWithIndexPath = sections.enumerated().map { IndexPathConverter().convert(changes: changes[$0.offset], section: $0.element) }
        let changesWithIndexPath: ChangeWithIndexPath = changessWithIndexPath.reduce(ChangeWithIndexPath(inserts: [], deletes: [], replaces: [], moves: [])) { (old, new) -> ChangeWithIndexPath in
            return ChangeWithIndexPath(inserts: old.inserts + new.inserts, deletes: old.deletes + new.deletes, replaces: old.replaces + new.replaces, moves: old.moves + new.moves)
        }
        
        performBatchUpdates({
            updateData()
            insideUpdate(changesWithIndexPath: changesWithIndexPath)
        }, completion: { finished in
            completion?(finished)
        })
        
        // reloadRows needs to be called outside the batch
        outsideUpdate(changesWithIndexPath: changesWithIndexPath)
    }
    
    // MARK: - Helper
    
    private func insideUpdate(changesWithIndexPath: ChangeWithIndexPath) {
        changesWithIndexPath.deletes.executeIfPresent {
            deleteItems(at: $0)
        }
        
        changesWithIndexPath.inserts.executeIfPresent {
            insertItems(at: $0)
        }
        
        changesWithIndexPath.moves.executeIfPresent {
            $0.forEach { move in
                moveItem(at: move.from, to: move.to)
            }
        }
    }
    
    private func outsideUpdate(changesWithIndexPath: ChangeWithIndexPath) {
        changesWithIndexPath.replaces.executeIfPresent {
            self.reloadItems(at: $0)
        }
    }
    
}
