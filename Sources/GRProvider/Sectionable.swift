//
//  Sectionable.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import Foundation

public protocol Sectionable {
    
    associatedtype Item
    
    var items: [Item] { get }
    var title: String? { get }
    
}

extension Sectionable {
    
    public var title: String? {
        return nil
    }
    
}

final public class SimpleSection<Item>: Sectionable {
    
    public var items: [Item]
    
    public init(_ items: [Item]) {
        self.items = items
    }
    
}

extension Array where Element: Sectionable {
    
    subscript(indexPath: IndexPath) -> Element.Item {
        return self[indexPath.section].items[indexPath.row]
    }
    
}
