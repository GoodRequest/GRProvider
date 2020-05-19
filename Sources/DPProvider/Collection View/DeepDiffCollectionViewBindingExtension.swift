//
//  DeepDiffCollectionViewBindingExtension.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/27/20.
//

import UIKit
import DeepDiff

extension UICollectionView {
    
    func reload<T: DiffAware>(
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
    
    func reload<T: DiffAware, S: DiffAware>(
      changes: [[Change<T>]],
      sectionsChanges: [Change<S>],
      sections: [Int],
      updateData: () -> Void,
      completion: ((Bool) -> Void)? = nil) {
        
        let convertedChangesWithIndexPath = sections.enumerated().map { IndexPathConverter().convert(changes: changes[$0.offset], section: $0.element) }
    
        let mergedChangesWithIndexPath: ChangeWithIndexPath = convertedChangesWithIndexPath.reduce(ChangeWithIndexPath(inserts: [], deletes: [], replaces: [], moves: [])) { (old, new) -> ChangeWithIndexPath in
            return ChangeWithIndexPath(inserts: old.inserts + new.inserts, deletes: old.deletes + new.deletes, replaces: old.replaces + new.replaces, moves: old.moves + new.moves)
        }
        
        let changesWithIndex = SectionIndexConverter().convert(changes: sectionsChanges)

        
        performBatchUpdates({
            updateData()
            insideSectionUpdate(changesWithIndexPath: changesWithIndex)
            insideUpdate(changesWithIndexPath: mergedChangesWithIndexPath)
        }, completion: { finished in
            completion?(finished)
        })
        
        // reloadRows needs to be called outside the batch
        outsideUpdate(changesWithIndexPath: mergedChangesWithIndexPath)
        outsideSectionUpdate(changesWithIndexPath: changesWithIndex)
    }
    
}
