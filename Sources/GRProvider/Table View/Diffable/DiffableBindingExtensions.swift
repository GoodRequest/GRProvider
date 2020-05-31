//
//  BindingExtensions.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/27/20.
//

import UIKit
import DeepDiff

@available(iOS 13.0, *)
extension GRDiffableTableViewProvider {
    
    /// Load sections from based on the data provider configuration.
    public func bind(to tableView: UITableView,
                     sections: [Section],
                     animated: Bool = true,
                     onComplete: @escaping () -> () = {}) {
        self.tableView = tableView
        self.sections = sections
        
        tableView.delegate = self.diffableTableViewProvider
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()
        
        snapshot.appendSections(sections)
        
        sections.forEach {
            snapshot.appendItems($0.items, toSection: $0)
        }
                          
        self.diffableTableViewProvider.apply(snapshot, animatingDifferences: animated, completion: onComplete)
    }
        
}

