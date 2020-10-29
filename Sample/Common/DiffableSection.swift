//
//  DiffableSection.swift
//  Sample
//
//  Created by Marek Spalek on 29/10/2020.
//

import GRProvider

struct DiffableStepConfigurator {
    let sections: [DiffableSection]
}

struct DiffableSection: Sectionable, Hashable {
    
    struct Item: Hashable {
       
        let title: String
        
        init(title: String) {
            self.title = title
        }
               
    }
    
    var items: [Item]
    var title: String?
           
    init(items: [Item], title: String?) {
        self.items = items
        self.title = title
    }
    
    static func ==(lhs: DiffableSection, rhs: DiffableSection) -> Bool {
        lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
}
