//
//  Displayable.swift
//  DPProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import Foundation

protocol Displayable: class {
    
    func willDispayCell()
    
}

extension Displayable {
    
    func willDisplayCell() {}
    
}
