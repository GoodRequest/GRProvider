//
//  DiffableViewController.swift
//  Sample
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import DPProvider

class DiffableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    enum Section: Sectionable, Hashable {
                
        case sectionOne([Item])
        case sectionTwo([Item])
        
        struct Item: Hashable {
            let title: String
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(title)
            }

            static func == (lhs: Item, rhs: Item) -> Bool {
              lhs.title == rhs.title
            }
        }
        
        var items: [Item] {
            switch self {
            case .sectionOne(let items), .sectionTwo(let items):
                return items
            }
        }

        var title: String? {
            switch  self {
            case .sectionOne: return "Section number 1"
            case .sectionTwo: return "Section number 2"
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch  self {
            case .sectionOne: return hasher.combine("Section number 1")
            case .sectionTwo: return hasher.combine("Section number 2")
            }
        }
        
        static func == (lhs: Section, rhs: Section) -> Bool {
            lhs.title == rhs.title
        }
        
    }
    
    lazy var dataProvider = DPDiffableTableViewProvider<Section>.init(tableView: tableView) { _, tv, indexPath, item in
        guard let cell = tv.dequeueReusableCell(fromClass: SimpleTableViewCell.self, for: indexPath) else { return UITableViewCell() }
        cell.titleLabel.text = item.title
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        setupTableView()
        showItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func updateAction() {
        updateItems()
    }
    
    private func setupTableView() {
        dataProvider.heightForHeaderInSection = 60
        dataProvider.estimatedHeightForRow = 60

        dataProvider.configureSectionHeader = { [unowned self] _, section in
            let container = UIView()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(label)

            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 15).isActive = true
            label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15).isActive = true
            label.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -15).isActive = true

            label.text = self.dataProvider.sections[section].title

            return container
        }
    
        dataProvider.configureOnItemSelected = { _, _, _, item in
            debugPrint("Item selected --->", item)
        }
    }
    
    private func showItems() {
        let itemsForSection1 = (1...10).map { Section.Item(title: "Item for section(1) \($0)") }
        let itemsForSection2 = (11...15).map { Section.Item(title: "Item for section(2) \($0)") }
        
        let sections = [Section.sectionOne(itemsForSection1), Section.sectionTwo(itemsForSection2)]
        tableView.items(dataProvider, sections: sections, animated: false)
    }
    
    private func updateItems() {
        let itemsForSection1 = (1...5).map { Section.Item(title: "Item for section(1) \($0)") }
        let itemsForSection2 = (11...12).map { Section.Item(title: "Item for section(2) \($0)") }
        
        let sections = [Section.sectionOne(itemsForSection1), Section.sectionTwo(itemsForSection2)]
        tableView.items(dataProvider, sections: sections)
    }
    
}

