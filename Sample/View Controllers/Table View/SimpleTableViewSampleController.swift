//
//  ViewController.swift
//  Sample
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import GRProvider

class SimpleTableViewSampleController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let tableProvider = GRSimpleTableViewProvider<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Simple Table View Provider"
        
        setupTableView()
        showItems()
    }

    private func setupTableView() {
        tableProvider.estimatedHeightForRow = 100
                
        tableProvider.configureCell = { _, tv, index, title in
            guard let cell = tv.dequeueReusableCell(fromClass: SimpleTableViewCell.self, for: index) else { return UITableViewCell() }
            cell.titleLabel.text = title
            return cell
        }
    }
    
    private func showItems() {
        let items = (1...10).map { "Item \($0)" }
        tableProvider.bind(to: tableView, items: items)
    }
    
}

class CustomSimpleTableViewProvider<Section: Sectionable>: GRTableViewProvider<Section> {
    
    open var configureDidHighlightRow: ((CustomSimpleTableViewProvider, UITableView, Section.Item) -> ())?
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        configureDidHighlightRow?(self, tableView, sections[indexPath.section].items[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows for section: \(section)")
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
}

