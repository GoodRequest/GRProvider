//
//  UpdateExtensions.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/27/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit
import DeepDiff

extension UITableView {
    
    func reload<T: DiffAware>(
        changes: [[Change<T>]],
        sections: [Int],
        insertionAnimation: UITableView.RowAnimation = .automatic,
        deletionAnimation: UITableView.RowAnimation = .automatic,
        replacementAnimation: UITableView.RowAnimation = .automatic,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil) {
        
        let convertedChangesWithIndexPath = sections.enumerated().map { IndexPathConverter().convert(changes: changes[$0.offset], section: $0.element) }
        
        let mergedChangesWithIndexPath: ChangeWithIndexPath = convertedChangesWithIndexPath.reduce(ChangeWithIndexPath(inserts: [], deletes: [], replaces: [], moves: [])) { (old, new) -> ChangeWithIndexPath in
            return ChangeWithIndexPath(inserts: old.inserts + new.inserts, deletes: old.deletes + new.deletes, replaces: old.replaces + new.replaces, moves: old.moves + new.moves)
        }
        
        unifiedPerformBatchUpdates({
            updateData()
            self.insideUpdate(
                changesWithIndexPath: mergedChangesWithIndexPath,
                insertionAnimation: insertionAnimation,
                deletionAnimation: deletionAnimation
            )
        }, completion: { finished in
            completion?(finished)
        })
        
        // reloadRows needs to be called outside the batch
        outsideUpdate(changesWithIndexPath: mergedChangesWithIndexPath,
                      replacementAnimation: replacementAnimation)
    }
    
    func reload<T: DiffAware, S: DiffAware>(
        changes: [[Change<T>]],
        sectionsChanges: [Change<S>],
        sections: [Int],
        insertionAnimation: UITableView.RowAnimation = .automatic,
        deletionAnimation: UITableView.RowAnimation = .automatic,
        replacementAnimation: UITableView.RowAnimation = .automatic,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil) {
        
        let convertedChangesWithIndexPath = sections.enumerated().map { IndexPathConverter().convert(changes: changes[$0.offset], section: $0.element) }
        
        let mergedChangesWithIndexPath: ChangeWithIndexPath = convertedChangesWithIndexPath.reduce(ChangeWithIndexPath(inserts: [], deletes: [], replaces: [], moves: [])) { (old, new) -> ChangeWithIndexPath in
            return ChangeWithIndexPath(inserts: old.inserts + new.inserts, deletes: old.deletes + new.deletes, replaces: old.replaces + new.replaces, moves: old.moves + new.moves)
        }
                        
        let changesWithIndex = SectionIndexConverter().convert(changes: sectionsChanges)
        
        unifiedPerformBatchUpdates({
            updateData()
            self.insideSectionUpdate(
                changesWithIndexPath: changesWithIndex,
                insertionAnimation: insertionAnimation,
                deletionAnimation: deletionAnimation)
            
            self.insideUpdate(
                changesWithIndexPath: mergedChangesWithIndexPath,
                insertionAnimation: insertionAnimation,
                deletionAnimation: deletionAnimation
            )
        }, completion: { finished in
            completion?(finished)
        })
        
        // reloadRows needs to be called outside the batch
        outsideSectionUpdate(changesWithIndexPath: changesWithIndex,
                             replacementAnimation: replacementAnimation)
        outsideUpdate(changesWithIndexPath: mergedChangesWithIndexPath,
                      replacementAnimation: replacementAnimation)
    }
    
    func unifiedPerformBatchUpdates(
        _ updates: (() -> Void),
        completion: (@escaping (Bool) -> Void)) {
        
        if #available(iOS 11, tvOS 11, *) {
            performBatchUpdates(updates, completion: completion)
        } else {
            beginUpdates()
            updates()
            endUpdates()
            completion(true)
        }
    }
    
    func insideSectionUpdate(
        changesWithIndexPath: ChangeWithIndex,
        insertionAnimation: UITableView.RowAnimation,
        deletionAnimation: UITableView.RowAnimation) {
        
        changesWithIndexPath.deletes.executeIfPresent {
            deleteSections(IndexSet($0), with: deletionAnimation)
        }
        
        changesWithIndexPath.inserts.executeIfPresent {
            insertSections(IndexSet($0), with: deletionAnimation)
        }
        
        changesWithIndexPath.moves.executeIfPresent {
            $0.forEach { move in
                moveSection(move.from, toSection: move.to)
            }
        }
    }
    
    func outsideSectionUpdate(
        changesWithIndexPath: ChangeWithIndex,
        replacementAnimation: UITableView.RowAnimation) {
        
        changesWithIndexPath.replaces.executeIfPresent {
            reloadSections(IndexSet($0), with: replacementAnimation)
        }
    }
    
    func insideUpdate(
        changesWithIndexPath: ChangeWithIndexPath,
        insertionAnimation: UITableView.RowAnimation,
        deletionAnimation: UITableView.RowAnimation) {
        
        changesWithIndexPath.deletes.executeIfPresent {
            deleteRows(at: $0, with: deletionAnimation)
        }
        
        changesWithIndexPath.inserts.executeIfPresent {
            insertRows(at: $0, with: insertionAnimation)
        }
        
        changesWithIndexPath.moves.executeIfPresent {
            $0.forEach { move in
                moveRow(at: move.from, to: move.to)
            }
        }
    }
    
    func outsideUpdate(
        changesWithIndexPath: ChangeWithIndexPath,
        replacementAnimation: UITableView.RowAnimation) {
        
        changesWithIndexPath.replaces.executeIfPresent {
            reloadRows(at: $0, with: replacementAnimation)
        }
    }
    
}
