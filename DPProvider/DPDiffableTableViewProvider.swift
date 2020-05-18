//
//  DPDiffableTableViewProvider.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
public class DPDiffableTableViewProvider<Section: Sectionable>: TableViewProvider<Section> where Section: Hashable, Section.Item: Hashable {
    
    var diffableTableViewProvider: DiffableTableViewProvider<Section>!
    
    public init(tableView: UITableView, configureCell: @escaping TableViewProvider<Section>.CellFactory) {
        super.init(configureCell: configureCell)
        
        self.diffableTableViewProvider = .init(tableView: tableView, cellProvider: { [unowned self] tv, indexPath, item in
            self.configureCell(self, tv, indexPath, item) ?? UITableViewCell()
        })
        
    }
    
    public override var sections: [Section] {
        get {
            diffableTableViewProvider.sections
        }
        
        set {
            diffableTableViewProvider.sections = newValue
        }
    }
    
    public override var configureCellHeight: CellHeightFactory? {
        didSet {
            diffableTableViewProvider.configureCellHeight = { [unowned self] in
                self.configureCellHeight?(self, $0, $1, $2) ?? 0
            }
        }
    }
    
    public override var configureEstimatedCellHeight: CellHeightFactory? {
        didSet {
            diffableTableViewProvider.configureEstimatedCellHeight? = { [unowned self] in
                self.configureEstimatedCellHeight?(self, $0, $1, $2) ?? 0
            }
        }
    }
    
    public override var estimatedHeightForRow: CGFloat? {
        didSet {
            diffableTableViewProvider.estimatedHeightForRow = estimatedHeightForRow
        }
    }
    
    public override var configureDidScroll: ScrollFactory? {
        didSet {
            diffableTableViewProvider.configureDidScroll = { [unowned self] in
                self.configureDidScroll?($0)
            }
        }
    }
    
    public override var configureSectionHeader: SectionHeaderFooterFactory? {
        didSet {
            diffableTableViewProvider.configureSectionHeader = { [unowned self] in
                self.configureSectionHeader?(self, $0)
            }
        }
    }
    public override var configureSectionFooter: SectionHeaderFooterFactory? {
        didSet {
            diffableTableViewProvider.configureSectionFooter = { [unowned self] in
                self.configureSectionFooter?(self, $0)
            }
        }
    }
    
    public override var configureSectionHeaderHeight: SectionHeaderFooterHeightFactory? {
        didSet {
            diffableTableViewProvider.configureSectionHeaderHeight = { [unowned self] in
                self.configureSectionHeaderHeight?(self, $0)
            }
        }
    }
    public override var configureSectionFooterHeight: SectionHeaderFooterHeightFactory? {
        didSet {
            diffableTableViewProvider.configureSectionFooterHeight = { [unowned self] in
                self.configureSectionFooterHeight?(self, $0)
            }
        }
    }
    
    public override var configureOnItemSelected: ItemSelectionFactory? {
        didSet {
            diffableTableViewProvider.configureOnItemSelected = { [unowned self] in
                self.configureOnItemSelected?(self, $0, $1, $2)
            }
        }
    }
    
    public override var configureTrailingSwipeGesture: SwipeGestureFactory? {
        didSet {
            diffableTableViewProvider.configureTrailingSwipeGesture = { [unowned self] in
                self.configureTrailingSwipeGesture?($0, $1, $2) ?? []
            }
        }
    }
    
    public override var configureRefreshGesture: ScrollFactory? {
        didSet {
            diffableTableViewProvider.configureRefreshGesture = { [unowned self] in
                self.configureRefreshGesture?($0)
            }
        }
    }
    
    public override var heightForFooterInSection: CGFloat? {
        didSet {
            diffableTableViewProvider.heightForFooterInSection = heightForFooterInSection
        }
    }
    
    public override var heightForHeaderInSection: CGFloat? {
        didSet {
            diffableTableViewProvider.heightForHeaderInSection = heightForHeaderInSection
        }
    }
    
}

@available(iOS 13.0, *)
public class DiffableTableViewProvider<Section: Sectionable>: UITableViewDiffableDataSource<Section, Section.Item>, UITableViewDelegate where Section: Hashable, Section.Item: Hashable {
    
    // MARK: - Factories
    
    public typealias CellFactory = (UITableView, IndexPath, Section.Item) -> UITableViewCell
    public typealias CellHeightFactory = (UITableView, IndexPath, Section.Item) -> CGFloat
    public typealias ScrollFactory = (UIScrollView) -> ()
    public typealias SectionHeaderFooterFactory = (Int) -> UIView?
    public typealias SectionHeaderFooterHeightFactory = (Int) -> CGFloat?
    public typealias SwipeGestureFactory = (UITableView, IndexPath, Section.Item) -> ([UIContextualAction])
    public typealias ItemSelectionFactory = (UITableView, IndexPath, Section.Item) -> ()
    
    // MARK: - Private properties
    
    weak var tableView: UITableView!
    
    public var sections: [Section] = []
    
    public init(tableView: UITableView, cellProvider: @escaping CellFactory) {
        super.init(tableView: tableView) { tv, index, item -> UITableViewCell? in
            cellProvider(tv, index, item)
        }
    }
    
    public var configureCellHeight: CellHeightFactory? = nil
    public var configureEstimatedCellHeight: CellHeightFactory? = nil
    public var estimatedHeightForRow: CGFloat?
    
    public var configureDidScroll: ScrollFactory? = nil
    
    public var configureSectionHeader: SectionHeaderFooterFactory? = nil
    public var configureSectionFooter: SectionHeaderFooterFactory? = nil
    
    public var configureSectionHeaderHeight: SectionHeaderFooterHeightFactory? = nil
    public var configureSectionFooterHeight: SectionHeaderFooterHeightFactory? = nil
    
    public var configureOnItemSelected: ItemSelectionFactory? = nil
    
    public var configureTrailingSwipeGesture: SwipeGestureFactory? = nil
    
    public var configureRefreshGesture: ScrollFactory? = nil
    
    public var heightForFooterInSection: CGFloat?
    public var heightForHeaderInSection: CGFloat?
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return snapshot().numberOfSections
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        return configureSectionHeader?(section) ?? UIView(frame: frame)
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        return configureSectionFooter?(section) ?? UIView(frame: frame)
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        (heightForFooterInSection ?? configureSectionFooterHeight?(section)) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (heightForHeaderInSection ?? configureSectionHeaderHeight?(section)) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return estimatedHeightForRow ?? 0
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return estimatedHeightForRow ?? 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configureCellHeight?(tableView, indexPath, sections[indexPath]) ?? UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath]
        configureOnItemSelected?(tableView, indexPath, selectedItem)
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return configureEstimatedCellHeight?(tableView, indexPath, sections[indexPath]) ?? estimatedHeightForRow ?? UITableView.automaticDimension
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
