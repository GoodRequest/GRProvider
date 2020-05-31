//
//  Displayable.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import Foundation

protocol Displayable: class {
    
    func willDisplayCell()
    func didEndDisplayCell()
    
}

extension Displayable {
    
    func willDisplayCell() {}
    
}
