//
//  ViewController.swift
//  Sample
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import DPProvider

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let dataProvider = DPSimpleTableViewProvider<String> { _, tv, index, title in
        guard let cell = tv.dequeueReusableCell(fromClass: SimpleTableViewCell.self, for: index) else { return UITableViewCell() }
        cell.titleLabel.text = title
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        showItems()
    }

    private func setupTableView() {        
        dataProvider.configureOnItemSelected = { _, _, _, item in
            debugPrint("Item selected --->", item)
        }
    }
    
    private func showItems() {
        let items = (1...10).map { "Item \($0)" }
        tableView.items(dataProvider, items: items)
    }
    
}

