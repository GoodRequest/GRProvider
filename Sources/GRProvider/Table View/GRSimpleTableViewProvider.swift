//
//  GRSimpleTableViewProvider.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit

final public class GRSimpleTableViewProvider<Item>: GRTableViewProvider<SimpleSection<Item>> {
    
    public var count: Int {
        return sections[safe: 0]?.items.count ?? 0
    }
    
    // MARK: - Binding

    /// This method is legacy method and be careful with using it. It, breaks the logic of auto reloading TableView. Use it wisely.
    /// Items represents array of section items
    public func bindSilently(to tableView: UITableView, items: [Item]) {
        self.tableView = tableView
        self.sections = [.init(items)]
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    /// Load items from based on the data provider configuration.
    public func bind(to tableView: UITableView, items: [Item], animated: Bool = true, onComplete: @escaping () -> () = {}) {
        self.tableView = tableView
        self.sections = [.init(items)]
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.reloadData(animated: animated) {
            onComplete()
        }
    }
    
}
