//
//  TableViewProvider.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit

public class TableViewProvider<Section: Sectionable>: NSObject {
    
    // MARK: - Factories

    public typealias CellFactory = (TableViewProvider, UITableView, IndexPath, Section.Item) -> UITableViewCell?
    public typealias CellHeightFactory = (TableViewProvider, UITableView, IndexPath, Section.Item) -> CGFloat
    public typealias ScrollFactory = (UIScrollView) -> ()
    public typealias SectionHeaderFooterFactory = (TableViewProvider, Int) -> UIView?
    public typealias SectionHeaderFooterHeightFactory = (TableViewProvider, Int) -> CGFloat?
    public typealias SwipeGestureFactory = (UITableView, IndexPath, Section.Item) -> ([UIContextualAction])
    public typealias ItemSelectionFactory = (TableViewProvider, UITableView, IndexPath, Section.Item) -> ()
    
    // MARK: - Private properties

    weak var tableView: UITableView!
    
    // MARK: - Public properties

    public var sections: [Section] = []
    
    /**
     Configure cells based on the type.
     Closure property is alternative for the `func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell`
     */
    let configureCell: CellFactory
    
    ///Configure cell height based on the cell type
    public var configureCellHeight: CellHeightFactory? = nil
    public var configureEstimatedCellHeight: CellHeightFactory? = nil
    public var estimatedHeightForRow: CGFloat?

    public var configureDidScroll: ScrollFactory? = nil
    
    public var configureSectionHeader: SectionHeaderFooterFactory? = nil
    public var configureSectionFooter: SectionHeaderFooterFactory? = nil
    
    ///Configure height of the header based on the selected section
    public var configureSectionHeaderHeight: SectionHeaderFooterHeightFactory? = nil
    ///Configure height of the footer based on the selected section
    public var configureSectionFooterHeight: SectionHeaderFooterHeightFactory? = nil
    
    public var configureOnItemSelected: ItemSelectionFactory? = nil
    
    public var configureTrailingSwipeGesture: SwipeGestureFactory? = nil
    
    public var configureRefreshGesture: ScrollFactory? = nil
        
    public var heightForFooterInSection: CGFloat?
    public var heightForHeaderInSection: CGFloat?
    
    public init(configureCell: @escaping CellFactory) {
        self.configureCell = configureCell
    }
    
}
