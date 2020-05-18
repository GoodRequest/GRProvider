//
//  DiffableTableViewExtensions.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
extension UITableView {
    
    open func items<Section>(_ dataProvider: DPDiffableTableViewProvider<Section>,
                                   sections: [Section],
                                   animated: Bool = true,
                                   onComplete: @escaping () -> () = {}) where Section: Sectionable & Hashable, Section.Item: Hashable {
        dataProvider.sections = sections
        dataProvider.tableView = self
        self.delegate = dataProvider.diffableTableViewProvider
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()
        
        snapshot.appendSections(sections)
        
        sections.forEach {
            snapshot.appendItems($0.items, toSection: $0)
        }
                        
        dataProvider.diffableTableViewProvider.apply(snapshot, animatingDifferences: animated, completion: onComplete)
    }
        
}

