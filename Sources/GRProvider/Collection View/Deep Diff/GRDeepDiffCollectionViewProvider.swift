//
//  GRDeepDiffCollectionViewProvider.swift
//  Sample
//
//  Created by Dominik Pethö on 5/31/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit
import DeepDiff

final public class GRDeepDiffCollectionViewProvider<Section: Sectionable & DiffAware>: GRCollectionViewProvider<Section> where
Section.Item: DiffAware {
    
    override public func bind(to collectionView: UICollectionView, sections: [Section], animated: Bool = true, onComplete: @escaping () -> () = {}) {
        bind(to: collectionView, sections: sections, onComplete: onComplete)
    }
    
    /// Binds items to collection view with using DeepDiff framework. Animates sections and cells using `performBatchUpdate` method
    public func bind(to collectionView: UICollectionView,
                                sections: [Section],
                                onComplete: @escaping () -> () = {}) {
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        guard !self.sections.isEmpty else {
            self.sections = sections
            collectionView.reloadData(animated: true) { onComplete() }
            return
        }
        
        let (sectionChanges, itemsChanges, sectionsIndexes) = DeepDiffHelper.intersect(oldSections: self.sections, newSections: sections)
        
        collectionView.reload(changes: itemsChanges, sectionsChanges: sectionChanges, sections: sectionsIndexes, updateData: {
            self.sections = sections
        }) { (_) in
           onComplete()
        }
    }
    
}
