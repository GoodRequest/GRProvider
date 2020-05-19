//
//  TableViewSampleController.swift
//  Sample
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import DPProvider

fileprivate struct Section: Sectionable {
        
    var title: String?
    var items: [String]
    
}

class TableViewSampleController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let tableProvider = DPTableViewProvider<Section>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Table View Provider"
        
        setupTableView()
        showItems()
    }

    private func setupTableView() {
        tableProvider.estimatedHeightForRow = 100
        
        tableProvider.configureOnItemSelected = { [unowned self] _, _, _, item in
            let alert = UIAlertController(title: "Wow!", message: "You clicked an item: \(item)", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        
        tableProvider.configureCell = { _, tv, index, title in
            guard let cell = tv.dequeueReusableCell(fromClass: SimpleTableViewCell.self, for: index) else { return UITableViewCell() }
            cell.titleLabel.text = title
            return cell
        }
        
        tableProvider.heightForHeaderInSection = UITableView.automaticDimension
        
        tableProvider.configureSectionHeader = { provider, section in
            let container = UIView()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(label)

            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 15).isActive = true
            label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15).isActive = true
            label.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -15).isActive = true

            label.text = provider.sections[section].title

            return container
        }
    }
    
    private func showItems() {
        let section1 = Section(title: "Section1", items: (1...4).map { "Item \($0)" })
        let section2 = Section(title: "Section2", items: (5...8).map { "Item \($0)" })
        tableProvider.bind(to: tableView, sections: [section1, section2])
    }
    
}

