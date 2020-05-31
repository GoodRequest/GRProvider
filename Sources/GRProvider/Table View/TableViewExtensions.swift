//
//  DiffableTableViewExtensions.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/18/20.
//  Copyright © 2020 Depo. All rights reserved.
//

import UIKit
import DeepDiff

extension UITableView {

    func reloadData(animated: Bool = false, completion: @escaping () -> ()) {
        UIView.transition(with: self, duration: animated ? 0.5 : 0.0, options: .transitionCrossDissolve, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
}

