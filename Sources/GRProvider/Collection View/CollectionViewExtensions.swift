//
//  CollectionViewExtensions.swift
//  GRProvider
//
//  Created by Dominik Pethö on 5/27/20.
//

import UIKit

extension UICollectionView {
    
    func reloadData(animated: Bool = false, completion: @escaping () -> ()) {
        UIView.transition(with: self, duration: animated ? 0.5 : 0.0, options: .transitionCrossDissolve, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
}
