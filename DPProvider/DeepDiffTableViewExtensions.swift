//
//  DeepDiffTableViewExtensions.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import DeepDiff

extension UITableView {
    
    open func items<Section>(_ dataProvider: DPTableViewProvider<Section>,
                             sections: [Section],
                             insertionAnimation: UITableView.RowAnimation = .fade,
                             deletionAnimation: UITableView.RowAnimation = .fade,
                             replacementAnimation: UITableView.RowAnimation = .none,
                             onComplete: @escaping () -> () = {}) where Section: Sectionable, Section.Item: DiffAware {
        dataProvider.tableView = self
        self.dataSource = dataProvider
        self.delegate = dataProvider
        
        guard !dataProvider.sections.isEmpty else {
            dataProvider.sections = sections
            reloadData(animated: true) { onComplete() }
            return
        }
        
        var allChanges: [[Change<Section.Item>]] = []
        var allSections: [Int] = []
        
        for (index, section) in sections.enumerated() {
            
            let oldItems = dataProvider.sections[safe: index]?.items ?? []
            let changes = diff(old: oldItems, new: section.items)
            
            if !changes.isEmpty {
                allChanges.append(changes)
                allSections.append(index)
            }
        }
        
        self.reload(changes: allChanges, sections: allSections, insertionAnimation: insertionAnimation, deletionAnimation: deletionAnimation, replacementAnimation: replacementAnimation, updateData: {
            dataProvider.sections = sections
        }) { (_) in
            onComplete()
        }
    }
    
    private func reload<T: DiffAware>(
        changes: [[Change<T>]],
        sections: [Int],
        insertionAnimation: UITableView.RowAnimation = .automatic,
        deletionAnimation: UITableView.RowAnimation = .automatic,
        replacementAnimation: UITableView.RowAnimation = .automatic,
        updateData: () -> Void,
        completion: ((Bool) -> Void)? = nil) {
        
        let changessWithIndexPath = sections.enumerated().map { IndexPathConverter().convert(changes: changes[$0.offset], section: $0.element) }
        let changesWithIndexPath: ChangeWithIndexPath = changessWithIndexPath.reduce(ChangeWithIndexPath(inserts: [], deletes: [], replaces: [], moves: [])) { (old, new) -> ChangeWithIndexPath in
            return ChangeWithIndexPath(inserts: old.inserts + new.inserts, deletes: old.deletes + new.deletes, replaces: old.replaces + new.replaces, moves: old.moves + new.moves)
        }
        
        unifiedPerformBatchUpdates({
            updateData()
            self.insideUpdate(
                changesWithIndexPath: changesWithIndexPath,
                insertionAnimation: insertionAnimation,
                deletionAnimation: deletionAnimation
            )
        }, completion: { finished in
            completion?(finished)
        })
        
        // reloadRows needs to be called outside the batch
        outsideUpdate(changesWithIndexPath: changesWithIndexPath, replacementAnimation: replacementAnimation)
    }
    
    private func unifiedPerformBatchUpdates(
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
    
    private func insideUpdate(
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
    
    private func outsideUpdate(
        changesWithIndexPath: ChangeWithIndexPath,
        replacementAnimation: UITableView.RowAnimation) {
        
        changesWithIndexPath.replaces.executeIfPresent {
            reloadRows(at: $0, with: replacementAnimation)
        }
    }
    
}

