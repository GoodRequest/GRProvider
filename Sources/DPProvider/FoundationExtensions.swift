//
//  FoundationExtensions.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import Foundation

// MARK: - Array

extension Array {
    
    func contains(index: Int) -> Bool {
        return (startIndex..<endIndex).contains(index)
    }
    
    subscript(safe index: Int) -> Element? {
        self.contains(index: index) ? self[index] : nil
    }
    
    func separated(by element: Element) -> [Element] {
        return Array(map { [$0] }.joined(separator: [element]))
    }
    
}
