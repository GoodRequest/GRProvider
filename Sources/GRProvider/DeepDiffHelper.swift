//
//  DeepDiffHelper.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/28/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import DeepDiff

struct DeepDiffHelper {
    
    static func intersect<Section: DiffAware & Sectionable>(oldSections: [Section], newSections: [Section]) -> ([Change<Section>], [[Change<Section.Item>]], [Int]) where Section.Item: DiffAware {
        let sectionChanges = diff(old: oldSections, new: newSections)
          
        var itemsChanges: [[Change<Section.Item>]] = []
        var allSections: [Int] = []
        
        for i in 0..<max(oldSections.count, newSections.count) {
            let changes: [Change<Section.Item>]
            
            if let toIndex = sectionChanges[safe: i]?.move?.fromIndex {
                changes = diff(old: (oldSections[safe: i]?.items ?? []), new: (newSections[safe: toIndex]?.items ?? []))
            } else {
                changes = diff(old: (oldSections[safe: i]?.items ?? []), new: (newSections[safe: i]?.items ?? []))
            }
            
            if !changes.isEmpty {
                itemsChanges.append(changes)
                allSections.append(i)
            } else {
                itemsChanges.append([])
                allSections.append(i)
            }
        }
        
        return (sectionChanges, itemsChanges, allSections)
    }
    
}
