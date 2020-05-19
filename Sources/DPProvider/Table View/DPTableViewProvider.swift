//
//  DPTableViewProvider.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import DeepDiff

open class DPTableViewProvider<Section: Sectionable>: TableViewProvider<Section>, UITableViewDelegate, UITableViewDataSource {
        
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // MARK: - TableView Data Source

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell?(self, tableView, indexPath, sections[indexPath]) ?? UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        return configureSectionHeader?(self, section) ?? UIView(frame: frame)
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        return configureSectionFooter?(self, section) ?? UIView(frame: frame)
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        (heightForFooterInSection ?? configureSectionFooterHeight?(self, section)) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (heightForHeaderInSection ?? configureSectionHeaderHeight?(self, section)) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return estimatedHeightForRow ?? 0
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return estimatedHeightForRow ?? 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configureCellHeight?(self, tableView, indexPath, sections[indexPath]) ?? UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath]
        configureOnItemSelected?(self, tableView, indexPath, selectedItem)
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return configureEstimatedCellHeight?(self, tableView, indexPath, sections[indexPath]) ?? estimatedHeightForRow ?? UITableView.automaticDimension
    }
    
    // MARK: - TableView Delegate

    
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: configureTrailingSwipeGesture?(self, tableView, indexPath, sections[indexPath]) ?? [])
    }
    
    open func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: configureLeadingSwipeGesture?(self, tableView, indexPath, sections[indexPath]) ?? [])
    }
    
    // MARK: - Scroll View delegate

    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureDidScroll?(scrollView)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        configureDidEndDragging?(scrollView, decelerate)
        
        if scrollView.refreshControl?.isRefreshing ?? false {
            configureRefreshGesture?(scrollView)
        }
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        configureWillEndDragging?(scrollView, velocity, targetContentOffset)
    }   
    
    // MARK: - Bindings
    
    /// This method is legacy method and be careful with using it. It, breaks the logic of auto reloading TableView. Use it wisely.
       /// Items represents array of sections
       public func bindSilently(to tableView: UITableView, sections: [Section]) {
           self.tableView = tableView
           self.sections = sections
           
           self.tableView.dataSource = self
           self.tableView.delegate = self
       }
    
       /// Load sections from based on the data provider configuration.
       public func bind(to tableView: UITableView, sections: [Section], animated: Bool = true, onComplete: @escaping () -> () = {}) {
           self.tableView = tableView
           self.sections = sections
           
           tableView.dataSource = self
           tableView.delegate = self
           
           tableView.reloadData(animated: animated) {
               onComplete()
           }
       }

}
