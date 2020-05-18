//
//  DPSimpleTableViewProvider.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import Foundation

final public class DPSimpleTableViewProvider<Item>: DPTableViewProvider<SimpleSection<Item>> {
    
    var count: Int {
        return sections[safe: 0]?.items.count ?? 0
    }
    
}
