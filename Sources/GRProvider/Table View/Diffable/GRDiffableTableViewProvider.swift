//
//  GRDiffableTableViewProvider.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
open class GRDiffableTableViewProvider<Section: Sectionable>: TableViewProvider<Section> where Section: Hashable & Equatable, Section.Item: Hashable & Equatable {
    
    var diffableTableViewProvider: DiffableTableViewProvider<Section>!
    
    public init(tableView: UITableView) {
        super.init()
        self.diffableTableViewProvider = .init(tableView: tableView, cellProvider: { [unowned self] tv, indexPath, item in
            self.configureCell?(self, tv, indexPath, item) ?? UITableViewCell()
        })        
    }
    
    open override var sections: [Section] {
        get {
            diffableTableViewProvider.sections
        }
        
        set {
            diffableTableViewProvider.sections = newValue
        }
    }
    
    open override var configureCellHeight: CellHeightProvider? {
        didSet {
            diffableTableViewProvider.configureCellHeight = { [unowned self] in
                self.configureCellHeight?(self, $0, $1, $2) ?? 0
            }
        }
    }
    
    open override var configureEstimatedCellHeight: CellHeightProvider? {
        didSet {
            diffableTableViewProvider.configureEstimatedCellHeight? = { [unowned self] in
                self.configureEstimatedCellHeight?(self, $0, $1, $2) ?? 0
            }
        }
    }
    
    open override var estimatedHeightForRow: CGFloat? {
        didSet {
            diffableTableViewProvider.estimatedHeightForRow = estimatedHeightForRow
        }
    }
    
    open override var configureSectionHeader: SectionHeaderFooterProvider? {
        didSet {
            diffableTableViewProvider.configureSectionHeader = { [unowned self] in
                self.configureSectionHeader?(self, self.tableView, $0, self.sections[$0])
            }
        }
    }
    open override var configureSectionFooter: SectionHeaderFooterProvider? {
        didSet {
            diffableTableViewProvider.configureSectionFooter = { [unowned self] in
                self.configureSectionFooter?(self, self.tableView, $0, self.sections[$0])
            }
        }
    }
    
    open override var configureSectionHeaderHeight: SectionHeaderFooterHeightProvider? {
        didSet {
            diffableTableViewProvider.configureSectionHeaderHeight = { [unowned self] in
                self.configureSectionHeaderHeight?(self, self.tableView, $0, self.sections[$0])
            }
        }
    }
    open override var configureSectionFooterHeight: SectionHeaderFooterHeightProvider? {
        didSet {
            diffableTableViewProvider.configureSectionFooterHeight = { [unowned self] in
                self.configureSectionFooterHeight?(self, self.tableView, $0, self.sections[$0])
            }
        }
    }
    
    open override var configureOnItemSelected: ItemSelectionProvider? {
        didSet {
            diffableTableViewProvider.configureOnItemSelected = { [unowned self] in
                self.configureOnItemSelected?(self, $0, $1, $2)
            }
        }
    }
    
    open override var configureTrailingSwipeGesture: SwipeGestureProvider? {
        didSet {
            diffableTableViewProvider.configureTrailingSwipeGesture = { [unowned self] in
                self.configureTrailingSwipeGesture?(self, $0, $1, $2) ?? []
            }
        }
    }
    
    open override var configureLeadingSwipeGesture: SwipeGestureProvider? {
        didSet {
            diffableTableViewProvider.configureLeadingSwipeGesture = { [unowned self] in
                self.configureTrailingSwipeGesture?(self, $0, $1, $2) ?? []
            }
        }
    }
    
    open override var configureDidScroll: ScrollProvider? {
        didSet {
            diffableTableViewProvider.configureDidScroll = { [unowned self] in
                self.configureDidScroll?($0)
            }
        }
    }
    
    open override var configureDidEndDragging: DidEndDraggingProvider? {
        didSet {
            diffableTableViewProvider.configureDidEndDragging = { [unowned self] in
                self.configureDidEndDragging?($0, $1)
            }
        }
    }
    
    open override var configureWillEndDragging: WillEndDraggingProvider? {
        didSet {
            diffableTableViewProvider.configureWillEndDragging = { [unowned self] in
                self.configureWillEndDragging?($0, $1, $2)
            }
        }
    }
    
    open override var configureRefreshGesture: ScrollProvider? {
        didSet {
            diffableTableViewProvider.configureRefreshGesture = { [unowned self] in
                self.configureRefreshGesture?($0)
            }
        }
    }
    
    open override var heightForFooterInSection: CGFloat? {
        didSet {
            diffableTableViewProvider.heightForFooterInSection = heightForFooterInSection
        }
    }
    
    open override var heightForHeaderInSection: CGFloat? {
        didSet {
            diffableTableViewProvider.heightForHeaderInSection = heightForHeaderInSection
        }
    }
    
}

@available(iOS 13.0, *)
final class DiffableTableViewProvider<Section: Sectionable>: UITableViewDiffableDataSource<Section, Section.Item>, UITableViewDelegate where Section: Hashable, Section.Item: Hashable {
    
    // MARK: - Factories

    // MARK: - TableView Providers Definition

    typealias CellProvider = (UITableView, IndexPath, Section.Item) -> UITableViewCell?
    typealias CellHeightProvider = ( UITableView, IndexPath, Section.Item) -> CGFloat
    typealias SectionHeaderFooterProvider = (Int) -> UIView?
    typealias SectionHeaderFooterHeightProvider = (Int) -> CGFloat?
    typealias SwipeGestureProvider = (UITableView, IndexPath, Section.Item) -> ([UIContextualAction])
    typealias ItemSelectionProvider = (UITableView, IndexPath, Section.Item) -> ()
    
    // MARK: - ScrollView Providers Definition
    
    typealias ScrollProvider = (UIScrollView) -> ()
    typealias DidEndDraggingProvider = (UIScrollView, Bool) -> ()
    typealias WillEndDraggingProvider = (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> ()
    
    // MARK: - Private properties
    
    weak var tableView: UITableView!
    
    var sections: [Section] = []
    
    override init(tableView: UITableView, cellProvider: @escaping CellProvider) {
        super.init(tableView: tableView) { tv, index, item -> UITableViewCell? in
            cellProvider(tv, index, item)
        }
    }
    
    var configureCellHeight: CellHeightProvider? = nil
    var configureEstimatedCellHeight: CellHeightProvider? = nil {
        didSet {
            guard estimatedHeightForRow != nil else { return }
            assertionFailure("⚠️ *estimatedHeightForRow* already initialized. Closure property *configureEstimatedCellHeight* will be ignored.")
        }
    }
    
    var configureDidScroll: ScrollProvider? = nil
    
    var configureSectionHeader: SectionHeaderFooterProvider? = nil
    var configureSectionFooter: SectionHeaderFooterProvider? = nil
    
    var configureSectionHeaderHeight: SectionHeaderFooterHeightProvider? = nil {
        didSet {
            guard heightForHeaderInSection != nil else { return }
            assertionFailure("⚠️ *heightForHeaderInSection* already initialized. Closure property *configureSectionHeaderHeight* will be ignored.")
        }
    }
    
    var configureSectionFooterHeight: SectionHeaderFooterHeightProvider? = nil {
        didSet {
            guard heightForFooterInSection != nil else { return }
            assertionFailure("⚠️ *heightForFooterInSection* already initialized. Closure property *configureSectionFooterHeight* will be ignored.")
        }
    }
    
    var configureOnItemSelected: ItemSelectionProvider? = nil
    
    var configureTrailingSwipeGesture: SwipeGestureProvider? = nil
    var configureLeadingSwipeGesture: SwipeGestureProvider? = nil
    
    var configureRefreshGesture: ScrollProvider? = nil
    var configureDidEndDragging: DidEndDraggingProvider? = nil
    var configureWillEndDragging: WillEndDraggingProvider? = nil
    
    var estimatedHeightForRow: CGFloat? {
        didSet {
            guard configureEstimatedCellHeight != nil else { return }
            assertionFailure("⚠️ *configureEstimatedCellHeight* already initialized. Closure property *configureEstimatedCellHeight* will be ignored.")
        }
    }
    
    var heightForFooterInSection: CGFloat? {
        didSet {
            guard configureSectionHeaderHeight != nil else { return }
            assertionFailure("⚠️ *configureSectionHeaderHeight* already initialized. Closure property *configureSectionHeaderHeight* will be ignored.")
        }
    }
    
    var heightForHeaderInSection: CGFloat? {
        didSet {
            guard configureSectionHeaderHeight != nil else { return }
            assertionFailure("⚠️ *configureSectionHeaderHeight* already initialized. Closure property *configureSectionHeaderHeight* will be ignored.")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return snapshot().numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        return configureSectionHeader?(section) ?? UIView(frame: frame)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        return configureSectionFooter?(section) ?? UIView(frame: frame)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        (heightForFooterInSection ?? configureSectionFooterHeight?(section)) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (heightForHeaderInSection ?? configureSectionHeaderHeight?(section)) ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configureCellHeight?(tableView, indexPath, sections[indexPath]) ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath]
        configureOnItemSelected?(tableView, indexPath, selectedItem)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return configureEstimatedCellHeight?(tableView, indexPath, sections[indexPath]) ?? estimatedHeightForRow ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: configureTrailingSwipeGesture?(tableView, indexPath, sections[indexPath]) ?? [])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: configureLeadingSwipeGesture?(tableView, indexPath, sections[indexPath]) ?? [])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureDidScroll?(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        configureDidEndDragging?(scrollView, decelerate)
        
        if scrollView.refreshControl?.isRefreshing ?? false {
            configureRefreshGesture?(scrollView)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        configureWillEndDragging?(scrollView, velocity, targetContentOffset)
    }
    
}
