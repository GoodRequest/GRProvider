//
//  DPTableViewProvider.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import DeepDiff

@available(iOS 11.0, *)
public class DPTableViewProvider<Section: Sectionable>: TableViewProvider<Section>, UITableViewDelegate, UITableViewDataSource {
        
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(self, tableView, indexPath, sections[indexPath]) ?? UITableViewCell()
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
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureDidScroll?(scrollView)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.refreshControl?.isRefreshing ?? false {
            configureRefreshGesture?(scrollView)
        }
    }
    
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: configureTrailingSwipeGesture?(tableView, indexPath, sections[indexPath]) ?? [])
    }
    
}

extension UITableView {
    
    open func items<Section: Sectionable>(_ dataProvider: DPTableViewProvider<Section>, sections: [Section], animated: Bool = true, completion: @escaping () -> () = {}) {
        dataProvider.tableView = self
        dataProvider.sections = sections
        self.dataSource = dataProvider
        self.delegate = dataProvider
        
        reloadData(animated: animated) {
            completion()
        }
    }
    
    open func items<Item>(_ dataProvider: DPSimpleTableViewProvider<Item>, items: [Item], animated: Bool = true, completion: @escaping () -> () = {}) {
        dataProvider.tableView = self
        dataProvider.sections = [.init(items)]
        self.dataSource = dataProvider
        self.delegate = dataProvider
        
        reloadData(animated: animated) {
            completion()
        }
    }
    
    open func items<Section>(_ dataProvider: DPTableViewProvider<Section>,
    sections: [Section],
    onComplete: @escaping () -> () = {}) where Section: Sectionable, Section.Item: DiffAware {
        items(dataProvider, sections: sections, insertionAnimation: .fade, onComplete: onComplete)
    }
    
    func reloadData(animated: Bool = false, completion: @escaping () -> ()) {
        UIView.transition(with: self, duration: animated ? 0.5 : 0.0, options: .transitionCrossDissolve, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
}
