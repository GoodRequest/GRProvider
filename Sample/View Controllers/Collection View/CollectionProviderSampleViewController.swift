//
//  DiffableViewController.swift
//  Sample
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import GRProvider
import DeepDiff

fileprivate struct StepConfigurator {
    let sections: [Section]
}

fileprivate struct Section: Sectionable {
    
    struct Item {
        let title: String
    }
    
    var items: [Item]
    var title: String?
              
    init(items: [Item], title: String?) {
        self.items = items
        self.title = title
    }
    
}

final class CollectionProviderViewSampleController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate lazy var tableProvider = GRCollectionViewProvider<Section>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Collection View Provider"
        
        setupTableView()
        showItems()
    }
    
    private func setupTableView() {
        tableProvider.configureCellSize = { _, cv, index, item in
            return CGSize(width: (cv.frame.width - 21) / 3, height: (cv.frame.width - 21) / 3)
        }
        
        tableProvider.sectionInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
        tableProvider.minimumLineSpacingForSection = 5
        tableProvider.minInteritemSpacingForSection = 5
        
        tableProvider.configureSupplementaryElementOfKind = { provider, cv, index, type in
            debugPrint(type)
            let section = provider.sections[index.section]
            let view = cv.dequeueReusableSupplementaryView(ofKind: type, fromClass: SimpleCollectionViewSupplementaryView.self, for: index)
            view.titleLabel.text = section.title
            return view
        }
        
        tableProvider.configureCell = { _, tv, indexPath, item in
            let cell = tv.dequeueReusableCell(fromClass: SimpleCollectionViewCell.self, for: indexPath)
            cell.titleLabel.text = item.title
            return cell
        }
        
        tableProvider.configureOnItemSelected = { [unowned self] _, _, _, item in
            let alert = UIAlertController(title: "Wow!", message: "You clicked an item: \(item)", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    private func showItems() {
        let section1 = Section(items: (1...5).map { Section.Item(title: "Item \($0)") }, title: "Section 1")
        let section2 = Section(items: (10...12).map { Section.Item(title: "Item \($0)") }, title: "Section 2")
        tableProvider.bind(to: collectionView, sections: [section1, section2])
    }
    
}
