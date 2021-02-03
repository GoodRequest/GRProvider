//
//  TableViewProvider.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import UIKit

/// Basic table provider implementation.
open class TableViewProvider<Section: Sectionable>: NSObject {
    
    // MARK: - Factories

    // MARK: - TableView Providers Definition

    public typealias CellProvider = (TableViewProvider, UITableView, IndexPath, Section.Item) -> UITableViewCell?
    public typealias CellHeightProvider = (TableViewProvider, UITableView, IndexPath, Section.Item) -> CGFloat
    public typealias SectionHeaderFooterProvider = (TableViewProvider, UITableView, Int, Section) -> UIView?
    public typealias SectionHeaderFooterHeightProvider = (TableViewProvider, UITableView, Int, Section) -> CGFloat?
    public typealias SwipeGestureProvider = (TableViewProvider, UITableView, IndexPath, Section.Item) -> ([UIContextualAction])
    public typealias ItemSelectionProvider = (TableViewProvider, UITableView, IndexPath, Section.Item) -> ()
    
    // MARK: - ScrollView Providers Definition
    
    public typealias ScrollProvider = (UIScrollView) -> ()
    public typealias DidEndDraggingProvider = (UIScrollView, Bool) -> ()
    public typealias WillEndDraggingProvider = (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> ()
    
    // MARK: - Private properties

    weak var tableView: UITableView!
    
    // MARK: - Public properties
    /// List of sections
    internal (set) public var sections: [Section] = []
    
    /// Configure cells based on the section item.
    open var configureCell: CellProvider? = nil
    
    /// Configure cell height based on the cell section item
    open var configureCellHeight: CellHeightProvider? = nil
    
    /// Configure estimated cell height based on the cell section item
    open var configureEstimatedCellHeight: CellHeightProvider? = nil {
        didSet {
            guard estimatedHeightForRow != nil else { return }
            assertionFailure("⚠️ *estimatedHeightForRow* already initialized. Closure property *configureEstimatedCellHeight* will be ignored.")
        }
    }
    
    /// Return an UIView of the header in the section
    open var configureSectionHeader: SectionHeaderFooterProvider? = nil
    /// Return an UIView of the footer in the section
    open var configureSectionFooter: SectionHeaderFooterProvider? = nil
    
    /// Configure height of the header based on the selected section
    open var configureSectionHeaderHeight: SectionHeaderFooterHeightProvider? = nil {
        didSet {
            guard heightForHeaderInSection != nil else { return }
            assertionFailure("⚠️ *heightForHeaderInSection* already initialized. Closure property *configureSectionHeaderHeight* will be ignored.")
        }
    }
    
    /// Configure height of the footer based on the selected section
    open var configureSectionFooterHeight: SectionHeaderFooterHeightProvider? = nil {
        didSet {
            guard heightForFooterInSection != nil else { return }
            assertionFailure("⚠️ *heightForFooterInSection* already initialized. Closure property *configureSectionFooterHeight* will be ignored.")
        }
    }
    
    /// Configure on item selection action based on the selected item
    open var configureOnItemSelected: ItemSelectionProvider? = nil
    
    /// Configures trailing swipe gesture. Should return and array of the UIContextualAction.
    open var configureTrailingSwipeGesture: SwipeGestureProvider? = nil
    /// Configures leading swipe gesture. Should return and array of the UIContextualAction.
    open var configureLeadingSwipeGesture: SwipeGestureProvider? = nil
    
    /// Closure calls when the table view contains refresh control. When `scrollViewDidEndDragging` executes, it autmatically checks the refresh control `isRefreshing` property and fires the event.
    open var configureRefreshGesture: ScrollProvider? = nil
    
    /// Closure calls when `scrollViewWillBeginDragging` fires up.
    open var configureWillBeginDragging: ScrollProvider? = nil
    /// Closure calls when `scrollViewDidEndDragging` fires up.
    open var configureDidEndDragging: DidEndDraggingProvider? = nil
    /// Closure calls when `scrollViewDidEndDragging` fires up.
    open var configureWillEndDragging: WillEndDraggingProvider? = nil
    /// Closure calls when user scrolls in table view. It's closure of UIScrollViewDelegate method `scrollViewDidScroll`
    open var configureDidScroll: ScrollProvider? = nil
    
    /// Variable representing estimated height for the row
    open var estimatedHeightForRow: CGFloat? {
        didSet {
            guard configureEstimatedCellHeight != nil else { return }
            assertionFailure("⚠️ *configureEstimatedCellHeight* already initialized. Closure property *configureEstimatedCellHeight* will be ignored.")
        }
    }
    
    /// Variable representing the footer height in the section
    open var heightForFooterInSection: CGFloat? {
        didSet {
            guard configureSectionHeaderHeight != nil else { return }
            assertionFailure("⚠️ *configureSectionHeaderHeight* already initialized. Closure property *configureSectionHeaderHeight* will be ignored.")
        }
    }
    
    /// Variable representing the header height in the section
    open var heightForHeaderInSection: CGFloat? {
        didSet {
            guard configureSectionHeaderHeight != nil else { return }
            assertionFailure("⚠️ *configureSectionHeaderHeight* already initialized. Closure property *configureSectionHeaderHeight* will be ignored.")
        }
    }
    
}
