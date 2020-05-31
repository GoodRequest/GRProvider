//
//  DeepDiffTableViewProvider.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/31/20.
//

import Foundation
import UIKit
import DeepDiff

final public class GRDeepDiffTableViewProvider<Section: Sectionable & DiffAware>: GRTableViewProvider<Section> where Section.Item: DiffAware {
    
    override public func bind(to tableView: UITableView, sections: [Section], animated: Bool = true, onComplete: @escaping () -> () = {}) {
        bind(to: tableView,
             sections: sections,
             insertionAnimation: animated ? .automatic : .none,
             deletionAnimation: animated ? .automatic : .none,
             replacementAnimation: animated ? .automatic : .none,
             onComplete: onComplete)
    }
    
    ///Binds items to collection view with using DeepDiff framework. Animates cells and sections using `performBatchUpdate` method
    
    public func bind(to tableView: UITableView,
                     sections: [Section],
                     insertionAnimation: UITableView.RowAnimation = .automatic,
                     deletionAnimation: UITableView.RowAnimation = .automatic,
                     replacementAnimation: UITableView.RowAnimation = .automatic,
                     onComplete: @escaping () -> () = {})  {
        self.tableView = tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
                
        if self.sections.isEmpty {
            self.sections = sections
            tableView.reloadData(animated: insertionAnimation != .none) { onComplete() }
            return
        }
                        
        let (sectionChanges, itemsChanges, sectionsIndexes) = DeepDiffHelper.intersect(oldSections: self.sections, newSections: sections)
        
        tableView.reload(changes: itemsChanges, sectionsChanges: sectionChanges, sections: sectionsIndexes, insertionAnimation: insertionAnimation, deletionAnimation: deletionAnimation, replacementAnimation: replacementAnimation, updateData: {
            self.sections = sections
        }) { (_) in
            onComplete()
        }
    }
}
